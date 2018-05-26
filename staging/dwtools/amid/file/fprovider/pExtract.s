( function _Extract_s_() {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../FileMid.s' );

}

var _ = _global_.wTools;
var Partial = _.FileProvider.Partial;
var FileRecord = _.FileRecord;
var Find = _.FileProvider.Find;

_.assert( Partial );
_.assert( FileRecord );
_.assert( Find );
_.assert( !_.FileProvider.Extract );

//

var Parent = Partial;
var Self = function wFileProviderExtract( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Extract';

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
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con = new _.Consequence();
  var result = null;

  _.assert( arguments.length === 1 );
  _.assertRoutineOptions( fileReadAct,o );

  var encoder = fileReadAct.encoders[ o.encoding ];

  if( o.encoding )
  if( !encoder )
  return handleError( _.err( 'Encoding: ' + o.encoding + ' is not supported!' ) )

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,o );

  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,o,data );

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
      err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err );
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

  /* exec */

  handleBegin();

  // if( o.filePath === '/staging/common.external/Buzz.js' )
  // debugger;

  // o.filePath = self.pathResolveLinkTollerant( o );

  var result = self._descriptorRead( o.filePath );

  if( self._descriptorIsLink( result ) )
  {
    result = self._descriptorResolve({ descriptor : result });
    if( result === undefined )
    return handleError( _.err( 'Cant resolve :', result ) );
  }

  if( result === undefined || result === null )
  {
    debugger;
    result = self._descriptorRead( o.filePath );
    return handleError( _.err( 'File at :', o.filePath, 'doesn`t exist!' ) );
  }

  if( self._descriptorIsDir( result ) )
  return handleError( _.err( 'Can`t read from dir : ' + _.strQuote( o.filePath ) + ' method expects file' ) );
  if( self._descriptorIsLink( result ) )
  return handleError( _.err( 'Can`t read from link : ' + _.strQuote( o.filePath ) + ', without link resolving enabled' ) );
  if( !_.strIs( result ) )
  return handleError( _.err( 'Can`t read file : ' + _.strQuote( o.filePath ) ) );

  var time = _.timeNow();
  self._fileTimeSet({ filePath : o.filePath, atime : time, ctime : time });

  return handleEnd( result );
}

var defaults = fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
var having = fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );

//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertRoutineOptions( fileStatAct,o );

  /* */

  function _fileStatAct( filePath )
  {
    var file = self._descriptorRead( filePath );

    var result = new _.FileStat();

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
      result.size = file.length;
    }
    else if( self._descriptorIsSoftLink( file ) )
    {
      file = file[ 0 ];

      if( self.resolvingSoftLink )
      {
        var r = _fileStatAct( file.softLink );
        if( r )
        return r;
      }

      result.isSymbolicLink = function() { return true; };

    }
    else if( self._descriptorIsHardLink( file ) )
    {
      file = file[ 0 ];

      if( self.resolvingHardLink )
      {
        var r = _fileStatAct( file.hardLink );
        if( r )
        return r;
      }

    }
    else if( self._descriptorIsScript( file ) )
    {
    }
    else
    {
      _.assert( !file );
      result = null;
      if( o.throwing )
      throw _.err( 'Path :', filePath, 'doesn`t exist!' );
    }

    return result;
  }

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

}

fileStatAct.defaults = Object.create( Parent.prototype.fileStatAct.defaults );
fileStatAct.having = Object.create( Parent.prototype.fileStatAct.having );

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
//     _.assert( arguments.length === 1 );

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

  _.assert( arguments.length === 1 );
  _.assertRoutineOptions( directoryReadAct,o );

  var result;
  function readDir()
  {
    var file = self._descriptorRead( o.filePath );
    if( file !== undefined )
    {
      if( _.objectIs( file ) )
      {
        result = Object.keys( file );
        _.assert( _.arrayIs( result ),'readdirSync returned not array' );
      }
      else
      {
        result = [ _.pathName({ path : o.filePath, withExtension : 1 }) ];
      }
    }
    else
    {
      if( o.throwing )
      throw _.err( 'Path : ', o.filePath, 'doesn`t exist!' );;
      result = null;
    }
  }

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
}

var defaults = directoryReadAct.defaults = Object.create( Parent.prototype.directoryReadAct.defaults );
var having = directoryReadAct.having = Object.create( Parent.prototype.directoryReadAct.having );

// --
// write
// --

function fileTimeSetAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,fileTimeSetAct.defaults );

  var file = self._descriptorRead( o.filePath );
  if( !file )
  throw _.err( 'File:', o.filePath, 'doesn\'t exist. Can\'t set time stats.' );

  self._fileTimeSet( o );
}

var defaults = fileTimeSetAct.defaults = Object.create( Parent.prototype.fileTimeSetAct.defaults );
var having = fileTimeSetAct.having = Object.create( Parent.prototype.fileTimeSetAct.having );

//

function fileWriteAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertRoutineOptions( fileWriteAct,o );
  _.assert( _.strIs( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  /* o.data */

  // if( _.bufferTypedIs( o.data ) )
  // {
  //   o.data = _.bufferToNodeBuffer( o.data );
  // }

  _.assert( _.strIs( o.data ) || _.bufferRawIs( o.data ),'expects string or ArrayBuffer, but got',_.strTypeOf( o.data ) );

  if( _.bufferRawIs( o.data ) )
  o.data = _.bufferToStr( o.data );

  /* write */

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }

  //

  function write()
  {

    var filePath =  o.filePath;
    var file = self._descriptorRead( filePath );

    if( self._descriptorIsLink( file ) )
    {
      var resolved = self._descriptorResolve({ descriptor : file });
      if( self._descriptorIsLink( resolved ) )
      {
        file = '';
      }
      else
      {
        file = resolved.result;
        filePath = resolved.filePath;

        if( file === undefined )
        throw _.err( 'Link refers to file ->', filePath, 'that doesn`t exist' );
      }
    }

    if( file === undefined )
    {
      file = '';
    }

    var dstName = _.pathName({ path : filePath, withExtension : 1 });
    var dstDir = _.pathDir( filePath );

    if( !self._descriptorRead( dstDir ) )
    throw _.err( 'Directories structure :' , dstDir, 'doesn`t exist' );

    if( self._descriptorIsDir( file ) )
    throw _.err( 'Incorrect path to file!\nCan`t rewrite dir :', filePath );

    var data;

    _.assert( _.strIs( file ) );
    _.assert( _.arrayHas( self.WriteMode, o.writeMode ), 'not implemented write mode ' + o.writeMode );

    if( o.writeMode === 'rewrite' )
    {
      data = o.data
    }
    if( o.writeMode === 'append' )
    {
      data = file + o.data;
    }
    else if( o.writeMode === 'prepend' )
    {
      data = o.data + file;
    }

    self._descriptorWrite( filePath, data );

    /* what for is that needed ??? */
    /*self._descriptorRead({ query : dstDir, set : structure });*/
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

}

var defaults = fileWriteAct.defaults = Object.create( Parent.prototype.fileWriteAct.defaults );
var having = fileWriteAct.having = Object.create( Parent.prototype.fileWriteAct.having );

//

function fileCopyAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,fileCopyAct.defaults );

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }

  function copy( )
  {
    var srcPath = self._descriptorRead( o.srcPath );
    if( !srcPath )
    throw _.err( 'File/dir : ', o.srcPath, 'doesn`t exist!' );
    if( self._descriptorIsDir( srcPath ) )
    throw _.err( o.srcPath,' is not a terminal file!' );

    var dstPath = self._descriptorRead( o.dstPath );
    if( self._descriptorIsDir( dstPath ) )
    throw _.err( 'Can`t rewrite dir with file, method expects file : ', o.dstPath );

    self._descriptorWrite( o.dstPath, srcPath );
  }

  if( o.sync  )
  {
    copy( );
  }
  else
  {
    return _.timeOut( 0, () => copy() );
  }
}

var defaults = fileCopyAct.defaults = Object.create( Parent.prototype.fileCopyAct.defaults );

defaults.sync = 0;

var having = fileCopyAct.having = Object.create( Parent.prototype.fileCopyAct.having );

//

function fileRenameAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  _.assertMapHasOnly( o,fileRenameAct.defaults );

  // var con = new _.Consequence();
  // _.assertMapHasOnly( o,fileCopyAct.defaults );

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }

  /* rename */

  function rename( )
  {
    var dstName = _.pathName({ path : o.dstPath, withExtension : 1 });
    var srcName = _.pathName({ path : o.srcPath, withExtension : 1 });
    var srcDirPath = _.pathDir( o.srcPath );
    var dstDirPath = _.pathDir( o.dstPath );

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

// return con;
}

var defaults = fileRenameAct.defaults = Object.create( Parent.prototype.fileRenameAct.defaults );

defaults.sync = 1;

var having = fileRenameAct.having = Object.create( Parent.prototype.fileRenameAct.having );

//

function fileDeleteAct( o )
{
  var self = this;

  _.assertRoutineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  function _delete()
  {
    var stat = self.fileStatAct
    ({
      filePath : o.filePath,
      resolvingSoftLink : 0,
      sync : 1,
      throwing : 0,
    });

    if( stat && stat.isSymbolicLink && stat.isSymbolicLink() )
    {
      // debugger;
      // throw _.err( 'not tested' );
    }

    if( !stat )
    throw _.err( 'Path : ', o.filePath, 'doesn`t exist!' );

    var file = self._descriptorRead( o.filePath );
    if( self._descriptorIsDir( file ) && Object.keys( file ).length )
    throw _.err( 'Directory not empty : ', o.filePath );

    var dir  = self._descriptorRead( _.pathDir( o.filePath ) );

    if( !dir )
    throw _.err( 'Not defined behavior' );

    var fileName = _.pathName({ path : o.filePath, withExtension : 1 });
    delete dir[ fileName ];

    for( var k in self.timeStats[ o.filePath ] )
    self.timeStats[ o.filePath ][ k ] = null;

    self._descriptorWrite( _.pathDir( o.filePath ), dir );
  }

  if( o.sync )
  {
    _delete();
  }
  else
  {
    return _.timeOut( 0, () => _delete() );
  }

  // return con;
}

var defaults = fileDeleteAct.defaults = Object.create( Parent.prototype.fileDeleteAct.defaults );
var having = fileDeleteAct.having = Object.create( Parent.prototype.fileDeleteAct.having );

//

function directoryMakeAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertRoutineOptions( directoryMakeAct,o );

  function _mkDir( )
  {
    if( self._descriptorRead( o.filePath ) )
    throw _.err( 'Path :', o.filePath, 'already exists!' );

    _.assert( self._descriptorRead( _.pathDir( o.filePath ) ), 'Folder structure before: ', _.strQuote( o.filePath ), ' doesn\'t exist!' );

    self._descriptorWrite( o.filePath, {} );
  }

  //

  if( o.sync )
  {
    _mkDir();
  }
  else
  {
    return _.timeOut( 0, () => _mkDir() );
  }
}

var defaults = directoryMakeAct.defaults = Object.create( Parent.prototype.directoryMakeAct.defaults );
var having = directoryMakeAct.having = Object.create( Parent.prototype.directoryMakeAct.having );

//

function linkSoftAct( o )
{
  var self = this;

  _.assertMapHasOnly( o, linkSoftAct.defaults );

  _.assert( _.pathIsAbsolute( o.dstPath ) );

  if( o.sync )
  {
    if( o.dstPath === o.srcPath )
    return true;

    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkSoftAct',o.dstPath,'already exists' );

    self._descriptorWrite( o.dstPath, self._descriptorSoftLinkMake( o.srcPath ) );

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

  _.assertMapHasOnly( o, linkHardAct.defaults );

  if( o.sync )
  {
    if( o.dstPath === o.srcPath )
    return true;

    if( self.fileStat( o.dstPath ) )
    throw _.err( 'linkHardAct',o.dstPath,'already exists' );

    if( !self.fileIsTerminal( o.srcPath ) )
    throw _.err( 'linkHardAct',o.srcPath,' is not a terminal file' );

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

      if( !self.fileIsTerminal( o.srcPath ) )
      throw _.err( 'linkHardAct',o.srcPath,' is not a terminal file' );

      self._descriptorWrite( o.dstPath, self._descriptorHardLinkMake( o.srcPath ) );

      return true;
    })
  }
}

var defaults = linkHardAct.defaults = Object.create( Parent.prototype.linkHardAct.defaults );
var having = linkHardAct.having = Object.create( Parent.prototype.linkHardAct.having );

//

function pathResolveSoftLinkAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.pathIsAbsolute( o.filePath ) );

  /* cause problems in pathResolveLink */
  if( /*!self.resolvingSoftLink ||*/ !self.fileIsSoftLink( o.filePath ) )
  return o.filePath;

  var descriptor = self._descriptorRead( o.filePath );
  var resolved = self._descriptorResolveSoftLinkPath( descriptor );

  _.assert( _.strIs( resolved ) )

  return resolved;
}

//

function pathResolveHardLinkAct( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( _.pathIsAbsolute( filePath ) );

  if( !self.resolvingHardLink || !self.fileIsHardLink( filePath ) )
  return filePath;

  var descriptor = self._descriptorRead( filePath );
  var resolved = self._descriptorResolveHardLinkPath( descriptor );

  _.assert( _.strIs( resolved ) )

  return resolved;
}

//

var linkSoft = Parent.prototype._link_functor({ nameOfMethod : 'linkSoftAct' });

var defaults = linkSoft.defaults = Object.create( Parent.prototype.linkSoftAct.defaults );

defaults.rewriting = 1;
defaults.verbosity = null;
defaults.throwing = null;
defaults.allowMissing = 0;

var having = linkSoft.having = Object.create( Parent.prototype.linkSoftAct.having );

having.bare = 0;

//

function hardLinkTerminateAct( o )
{
  var self = this;

  var descriptor = self._descriptorRead( o.filePath );

  _.assert( self._descriptorIsHardLink( descriptor ) );

  var read = self._descriptorResolve({ descriptor : descriptor });

  _.assert( _.strIs( read ) );

  self._descriptorWrite( o.filePath, read );

  // descriptor = descriptor[ 0 ];
  //
  // var url = _.urlParse( descriptor.hardLink );
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

var defaults = hardLinkTerminateAct.defaults = Object.create( Parent.prototype.hardLinkTerminateAct.defaults );

// --
// etc
// --

function linksRebase( o )
{
  var self = this;

  _.routineOptions( linksRebase,o );
  _.assert( arguments.length === 1 );

  function onUp( file )
  {
    var descriptor = self._descriptorRead( file.absolute );

    if( self._descriptorIsHardLink( descriptor ) )
    {
      debugger;
      descriptor = descriptor[ 0 ];
      var was = descriptor.hardLink;
      var url = _.urlParsePrimitiveOnly( descriptor.hardLink );
      url.localPath = _.pathRebase( url.localPath, o.oldPath, o.newPath );
      descriptor.hardLink = _.urlStr( url );
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

function _fileTimeSet( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ] };

  _.assert( _.pathIsAbsolute( o.filePath ), o.filePath );

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
    var parentPath = _.pathDir( o.filePath );
    if( parentPath === '/' )
    return;

    timeStats.birthtime = null;

    _.assert( o.atime && o.mtime && o.ctime );
    _.assert( o.atime === o.mtime && o.mtime === o.ctime );

    o.filePath = parentPath;

    self._fileTimeSet( o );
  }

  return timeStats;
}

_fileTimeSet.defaults =
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

  if( _.strIs( o ) )
  o = { globIn : o };

  _.routineOptions( filesTreeRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.globIn ) || _.strsAre( o.globIn ) || o.srcPath );
  _.assert( o.srcProvider );
  _.assert( o.filePath === undefined );

  o.filePath = o.srcPath;
  delete o.srcPath;

  // o.outputFormat = 'record';

  if( self.verbosity >= 2 )
  logger.log( 'filesTreeRead at ' + ( o.globIn || o.filePath ) );

  /* */

  o.onUp = _.arrayPrepend( _.arrayAs( o.onUp ), function( record )
  {

    var element;
    _.assert( record.stat,'file does not exists',record.absolute );
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
    path = _.pathUndot( path );

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
  var found = o.srcProvider.filesGlob( _.mapScreen( o.srcProvider.filesGlob.defaults,o ) );
  o.srcProvider.fieldReset( 'resolvingSoftLink',1 );

  return result;
}

var defaults = filesTreeRead.defaults = Object.create( Find.prototype._filesFindMasksAdjust.defaults );
var defaults2 =
{

  srcProvider : null,
  srcPath : null,
  basePath : null,

  recursive : 1,
  ignoringNonexistent : 0,
  includingTerminals : 1,
  includingDirectories : 1,
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

  maskAll : _.pathRegexpMakeSafe ? _.pathRegexpMakeSafe() : null,

}

_.mapExtend( defaults, defaults2 );

var having = filesTreeRead.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function rewriteFromProvider( o )
{
  var self = this;

  if( arguments[ 1 ] !== undefined )
  {
    o = { srcProvider : arguments[ 0 ], srcPath : arguments[ 1 ] }
    _.assert( arguments.length === 2 );
  }
  else
  {
    _.assert( arguments.length === 1 );
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

  if( arguments[ 1 ] !== undefined )
  {
    o = { dstProvider : arguments[ 0 ], dstPath : arguments[ 1 ] }
    _.assert( arguments.length === 2 );
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  if( !o.filesTree )
  o.filesTree = self.filesTree;

  _.routineOptions( readToProvider,o );

  _.assert( _.strIs( o.dstPath ) );
  _.assert( o.dstProvider );

  o.basePath = o.basePath || o.dstPath;
  o.basePath = _.pathRelative( o.dstPath,o.basePath );

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
    o.dstProvider.fileTimeSet( dstPath, stat.atime, stat.mtime );
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

    var terminating = descriptor.terminating || o.terminatingSoftLinks;

    if( o.allowWrite && !exists )
    {
      var contentPath = descriptor.softLink;
      contentPath = _.pathJoin( o.basePath, contentPath );
      if( o.absolutePathForLink || descriptor.absolute )
      contentPath = _.urlResolve( dstPath,'..',descriptor.hardLink );
      dstPath = o.dstProvider.localFromUrl( dstPath );
      if( terminating )
      {
        o.dstProvider.fileCopy( dstPath, contentPath );
      }
      else
      {
        var srcPathResolved = _.pathResolve( srcPath, contentPath );
        var srcStat = self.fileStat( srcPathResolved );
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
      var contentPath = descriptor.hardLink;
      contentPath = _.pathJoin( o.basePath, contentPath );
      if( o.absolutePathForLink || descriptor.absolute )
      contentPath = _.urlResolve( dstPath,'..',descriptor.hardLink );
      contentPath = o.dstProvider.localFromUrl( contentPath );
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
    _.assert( _.strIs( descriptor ) || _.objectIs( descriptor ) || _.arrayIs( descriptor ) );

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
        var isSoftLink = self._descriptorIsSoftLink( descriptor );
        if( isSoftLink )
        {
          o.dstProvider.filesDelete( dstPath );
          stat = false;
        }
      }
    }

    /* */

    if( _.strIs( descriptor ) )
    {
      if( o.allowWrite && !stat )
      o.dstProvider.fileWrite( dstPath,descriptor );
      handleWritten( dstPath );
    }
    else if( _.objectIs( descriptor ) )
    {
      if( o.allowWrite && !stat )
      o.dstProvider.directoryMake({ filePath : dstPath, force : 1 });
      handleWritten( dstPath );
      for( var t in descriptor )
      {
        write( _.pathJoin( dstPath,t ),_.pathJoin( srcPath, t ),descriptor[ t ]  );
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

  terminatingSoftLinks : 0,
  terminatingHardLinks : 0,
}

var having = readToProvider.having = Object.create( null );

having.writing = 1;
having.reading = 0;
having.bare = 0;

// --
// special
// --

function fileIsTerminalAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var d = self._descriptorRead( o.filePath );
  if( d === undefined )
  return false;

  var filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( filePath !== o.filePath )
  {
    d = self._descriptorRead( o.filePath );
    if( d === undefined )
    return false;
  }

  // var d = self._descriptorResolve
  // ({
  //   descriptor : d,
  //   resolvingSoftLink : o.resolvingSoftLink,
  //   resolvingTextLink : o.resolvingTextLink,
  // });

  if( self._descriptorIsLink( d ) )
  return false;

  if( self._descriptorIsDir( d ) )
  return false;

  return true;
}

var defaults = fileIsTerminalAct.defaults = Object.create( Parent.prototype.fileIsTerminalAct.defaults );
var paths = fileIsTerminalAct.paths = Object.create( Parent.prototype.fileIsTerminalAct.paths );
var having = fileIsTerminalAct.having = Object.create( Parent.prototype.fileIsTerminalAct.having );

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

  _.assert( arguments.length === 1 );

  var descriptor = self._descriptorRead( filePath )

  return self._descriptorIsHardLink( descriptor );
}

var having = fileIsHardLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

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

  _.assert( arguments.length === 1 );

  var descriptor = self._descriptorRead( filePath );

  return self._descriptorIsSoftLink( descriptor );
}

var having = fileIsSoftLink.having = Object.create( null );

having.writing = 0;
having.reading = 1;
having.bare = 0;

//

function filesAreHardLinkedAct( ins1Path,ins2Path )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var res1Path = self.pathResolveHardLinkAct( ins1Path );
  var res2Path = self.pathResolveHardLinkAct( ins2Path );

  if( res1Path === ins2Path )
  return true;

  if( ins1Path === res2Path )
  return true;

  if( res1Path === res2Path )
  return true;

  return false;
}

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
  _.assert( arguments.length === 1 );

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

  _.assert( arguments.length === 1 );
  _.assert( o.descriptor );
  _.routineOptions( _descriptorResolve,o );
  self._providerOptions( o );
  _.assert( !o.resolvingTextLink );

  if( self._descriptorIsHardLink( o.descriptor ) && self.resolvingHardLink )
  {
    o.descriptor = self._descriptorResolveHardLink( o.descriptor );
    return self._descriptorResolve
    ({
      descriptor : o.descriptor,
      resolvingHardLink : o.resolvingHardLink,
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
      resolvingHardLink : o.resolvingHardLink,
      resolvingSoftLink : o.resolvingSoftLink,
      resolvingTextLink : o.resolvingTextLink,
    });
  }

  return o.descriptor;
}

_descriptorResolve.defaults =
{
  descriptor : null,
  resolvingHardLink : null,
  resolvingSoftLink : null,
  resolvingTextLink : null,
}

//

// function _descriptorResolvePath( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//   _.assert( o.descriptor );
//   _.routineOptions( _descriptorResolve,o );
//   self._providerOptions( o );
//   _.assert( !o.resolvingTextLink );
//
//   if( self._descriptorIsHardLink( o.descriptor ) && self.resolvingHardLink )
//   {
//     o.descriptor = self._descriptorResolveHardLink( o.descriptor );
//     return self._descriptorResolve
//     ({
//       descriptor : o.descriptor,
//       resolvingHardLink : o.resolvingHardLink,
//       resolvingSoftLink : o.resolvingSoftLink,
//       resolvingTextLink : o.resolvingTextLink,
//     });
//   }
//
//   if( self._descriptorIsSoftLink( o.descriptor ) && self.resolvingSoftLink )
//   {
//     o.descriptor = self._descriptorResolveSoftLink( o.descriptor );
//     return self._descriptorResolve
//     ({
//       descriptor : o.descriptor,
//       resolvingHardLink : o.resolvingHardLink,
//       resolvingSoftLink : o.resolvingSoftLink,
//       resolvingTextLink : o.resolvingTextLink,
//     });
//   }
//
//   return o.descriptor;
// }
//
// _descriptorResolve.defaults =
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
  _.assert( descriptor.hardLink );
  return descriptor.hardLink;
}

//

function _descriptorResolveHardLink( descriptor )
{
  var self = this;
  var result;
  var filePath = self._descriptorResolveHardLinkPath( descriptor );
  var url = _.urlParse( filePath );

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
  _.assert( descriptor.softLink );
  return descriptor.softLink;
}

//

function _descriptorResolveSoftLink( descriptor )
{
  var self = this;
  var result;
  var filePath = self._descriptorResolveSoftLinkPath( descriptor );
  var url = _.urlParse( filePath );

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
  return _.strIs( file );
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
  _.assert( file );
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
  _.assert( file );
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
  _.assert( file );
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
  _.assert( file );
  return !!file.code;
}

// --
// descriptor write
// --

function _descriptorWrite( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };

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

  o.filePath = _.pathJoin( '/', o.filePath );

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
  self._fileTimeSet( timeOptions );

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

function _descriptorScriptMake( filePath,data )
{
  _.assert( arguments.length === 2 );
  var name = _.strVarNameFor( _.pathNameWithExtension( filePath ) );
  try
  {
    var code = _.routineMake({ name : name, code : data, prependingReturn : 0 });
  }
  catch( err )
  {
    throw _.err( 'Cant make routine for file :\n' + filePath + '\n', err );
  }
  return [ { filePath : filePath, code : code } ];
}

//

function _descriptorSoftLinkMake( filePath )
{
  _.assert( arguments.length === 1 );
  return [ { softLink : filePath } ];
}

//

function _descriptorHardLinkMake( filePath )
{
  _.assert( arguments.length === 1 );
  return [ { hardLink : filePath } ];
}

// --
// encoders
// --

var encoders = {};

fileReadAct.encoders = encoders;

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

encoders[ 'jstruct' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( '( fileRead.encoders.jstruct.onEnd ) expects string' );
    var result = _.exec({ code : e.data, filePath : e.transaction.filePath });
    return result;
  },

}

encoders[ 'js' ] = encoders[ 'jstruct' ];


if( !isBrowser )
encoders[ 'buffer-raw' ] =
{

  onBegin : function( e )
  {
    _.assert( e.encoding === 'buffer-raw' );
  },

  onEnd : function( e, data )
  {
    _.assert( _.strIs( data ) );

    var nodeBuffer = Buffer.from( data )
    var result = _.bufferRawFrom( nodeBuffer );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
  },

}

if( !isBrowser )
encoders[ 'buffer-node' ] =
{

  onBegin : function( e )
  {
    _.assert( e.encoding === 'buffer-node' );
  },

  onEnd : function( e, data )
  {
    _.assert( _.strIs( data ) );

    var result = Buffer.from( data );

    _.assert( _.bufferNodeIs( result ) );
    _.assert( !_.bufferRawIs( result ) );

    return result;
  },

}

encoders[ 'utf8' ] =
{

  onBegin : function( o )
  {
    _.assert( o.encoding === 'utf8' );
  },

  onEnd : function( o,data )
  {
    var result = data;
    _.assert( _.strIs( result ) );
    return result;
  },

}

// if( !isBrowser )
// {
//   encoders[ 'buffer-raw' ] =
//   {
//
//     onBegin : function( o )
//     {
//       _.assert( o.encoding === 'buffer-raw' );
//       o.encoding = 'buffer-raw';
//     },
//
//     onEnd : function( o,data )
//     {
//       data = new Buffer( data );
//
//       _.assert( _.bufferNodeIs( data ) );
//       _.assert( !_.bufferTypedIs( data ) );
//       _.assert( !_.bufferRawIs( data ) );
//
//       var result = _.bufferRawFrom( data );
//
//       _.assert( !_.bufferNodeIs( result ) );
//       _.assert( _.bufferRawIs( result ) );
//
//       return result;
//     },
//
//   }
//
//   encoders[ 'buffer-node' ] =
//   {
//
//     onBegin : function( o )
//     {
//       _.assert( o.encoding === 'buffer-node' );
//       o.encoding = 'buffer-node';
//     },
//
//     onEnd : function( o,data )
//     {
//       _.assert( _.strIs( data ) );
//
//       var result = new Buffer( data );
//
//       _.assert( _.bufferNodeIs( result ) );
//
//       return result;
//     },
//
//   }
//
//   var knownToStringEncodings = [ 'ascii','utf8','utf16le','ucs2','base64','latin1','binary','hex' ];
//
//   for( var i = 0,l = knownToStringEncodings.length; i < l; ++i )
//   {
//     encoders[ knownToStringEncodings[ i ] ] =
//     {
//       onBegin : function( o )
//       {
//         _.assert( knownToStringEncodings.indexOf( o.encoding ) != -1 );
//       },
//
//       onEnd : function( o,data )
//       {
//         _.assert( _.strIs( data ) );
//         return new Buffer( data ).toString( o.encoding );
//       },
//     }
//   }
// }

// --
// relationship
// --

var Composes =
{
  protocols : [],
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
  timeStats : Object.create( null )
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

}

// --
// prototype
// --

var Proto =
{

  init : init,


  // read

  fileReadAct : fileReadAct,
  fileReadStreamAct : null,
  fileStatAct : fileStatAct,
  // fileHashAct : fileHashAct,
  directoryReadAct : directoryReadAct,


  // write

  fileWriteAct : fileWriteAct,
  fileWriteStreamAct : null,

  fileDeleteAct : fileDeleteAct,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,

  linkSoft : linkSoft,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,

  pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  pathResolveHardLinkAct : pathResolveHardLinkAct,

  hardLinkTerminateAct : hardLinkTerminateAct,


  // etc

  linksRebase : linksRebase,
  _fileTimeSet : _fileTimeSet,

  filesTreeRead : filesTreeRead,
  rewriteFromProvider : rewriteFromProvider,
  readToProvider : readToProvider,


  // checker

  fileIsTerminalAct : fileIsTerminalAct,
  fileIsHardLink : fileIsHardLink,
  fileIsSoftLink : fileIsSoftLink,

  filesAreHardLinkedAct : filesAreHardLinkedAct,


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

// --
// export
// --

_.FileProvider = _.FileProvider || {};
_.FileProvider[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
