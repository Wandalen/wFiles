( function _SimpleStructure_s_() {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  require( '../FileMid.s' );

}

// if( wTools.FileProvider.SimpleStructure )
// return;

var _ = wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Partial;
var Self = function wFileProviderSimpleStructure( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'SimpleStructure';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con = new wConsequence();
  var result = null;

  _.assert( arguments.length === 1 );
  _.mapComplement( o,fileReadAct.defaults );

  var encoder = fileReadAct.encoders[ o.encoding ];

  if( o.encoding )
  if( !encoder )
  return handleError( _.err( 'Provided encoding: ' + o.encoding + ' is not supported!' ) )
  // _.assert( encoder, 'Provided encoding: ' + o.encoding + ' is not supported!' );


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

  result = self._descriptorRead( o.filePath );

  if( self._descriptorIsLink( result ) )
  result = self._descriptorResolve( result );

  if( !result )
  {
    return handleError( _.err( 'File at :', o.filePath, 'doesn`t exist!' ) );
  }
  if( self._descriptorIsDir( result ) )
  {
    return handleError( _.err( 'Can`t read from dir : ' + _.strQuote( o.filePath ) + ' method expects file') );
  }
  if( self._descriptorIsLink( result ) )
  {
    return handleError( _.err( 'Can`t read from link : ' + _.strQuote( o.filePath ) + ', without link resolving enabled') );
  }

  return handleEnd( result );
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileReadAct.having = {};
fileReadAct.having.__proto__ = Parent.prototype.fileReadAct.having;

//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileStatAct,o );
  self._providerOptions( o );

  function Stats()
  {
    var self = this;
    var keys =
    [
      'dev', 'mode', 'nlink', 'uid', 'gid',
      'rdev', 'blksize', 'ino', 'size', 'blocks',
      'atime', 'mtime', 'ctime', 'birthtime'
    ];
    var methods =
    [
      '_checkModeProperty', 'isDirectory',
      'isFile', 'isBlockDevice', 'isCharacterDevice',
      'isSymbolicLink', 'isFIFO', 'isSocket'
    ];

    for ( var key in keys )
    self[ keys[ key ] ] = null;

    for ( var key in methods )
    self[ methods[ key ] ] = function() { };
  }

  /* */

  function getFileStat( filePath )
  {
    var result;
    var file = self._descriptorRead( filePath );

    if( self._descriptorIsDir( file ) )
    {
      result = new Stats();

      result.isDirectory = function() { return true; };
      result.isFile = function() { return false; };

    }
    else if( self._descriptorIsTerminal( file ) )
    {
      result = new Stats();

      result.isDirectory = function() { return false; };
      result.isFile = function() { return true; };

    }
    else if( self._descriptorIsSoftLink( file ) )
    {
      file = file[ 0 ];

      if( self.resolvingSoftLink )
      return getFileStat( file.softLink );

      result = new Stats();
      result.isSymbolicLink = function() { return true; };

    }
    else if( self._descriptorIsHardLink( file ) )
    {
      file = file[ 0 ];

      if( self.resolvingHardLink )
      return getFileStat( file.hardLink );

      result = new Stats();

    }
    else if( o.throwing )
    {
      throw _.err( 'Path :', filePath, 'doesn`t exist!' );
    }

    return result;
  }

  /* */

  if( o.sync )
  {
    return getFileStat( o.filePath );
  }
  else
  {
    return _.timeOut( 0, function()
    {
      return getFileStat( o.filePath );
    })
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
//     var result=NaN;
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
  _.routineOptions( directoryReadAct,o );

  var result;
  function readDir()
  {
    // debugger;
    var file = self._descriptorRead( o.filePath );
    // debugger;
    if( file )
    {
      //var stat = self.fileStatAct( o.filePath );
      //if(stat && stat.isDirectory() )
      if( _.objectIs( file ) )
      {
        result = Object.keys( file );
        _.assert( _.arrayIs( result ),'readdirSync returned not array' );

        result.sort( function( a, b )
        {
          a = a.toLowerCase();
          b = b.toLowerCase();
          if( a < b ) return -1;
          if( a > b ) return +1;
          return 0;
        });
      }
      else
      {
        result = [ _.pathName({ path : o.filePath, withExtension : 1 }) ];
      }
    }
    else
    {
      if( o.throwing )
      {
        throw _.err( 'Path : ', o.filePath, 'doesn`t exist!' );;
      }
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
    // throw _.err( 'not implemented' );
    return _.timeOut( 0, function()
    {
      readDir();
      return result;
    });
  }
}

directoryReadAct.defaults = {}
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

directoryReadAct.having = {};
directoryReadAct.having.__proto__ = Parent.prototype.directoryReadAct.having;

// --
// write
// --

function fileTimeSetAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assertMapHasOnly( o,fileTimeSetAct.defaults );

  throw _.err( 'not implemented' );
}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Parent.prototype.fileTimeSetAct.defaults;

fileTimeSetAct.having = {};
fileTimeSetAct.having.__proto__ = Parent.prototype.fileTimeSetAct.having;

//

function fileWriteAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( fileWriteAct,o );
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
    // debugger
    var filePath =  o.filePath;
    var file = self._descriptorRead( filePath );

    if( self._descriptorIsLink( file ) )
    {
      var resolved = self._descriptorResolveWithPath( file );
      if( self._descriptorIsLink( resolved ) )
      {
        file = '';
      }
      else
      {
        file = resolved.result;
        filePath = resolved.filePath;
      }
    }

    if( file === undefined )
    file = '';

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

fileWriteAct.defaults = {};
fileWriteAct.defaults.__proto__ = Parent.prototype.fileWriteAct.defaults;

fileWriteAct.having = {};
fileWriteAct.having.__proto__ = Parent.prototype.fileWriteAct.having;

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

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;
fileCopyAct.defaults.sync = 0;

fileCopyAct.having = {};
fileCopyAct.having.__proto__ = Parent.prototype.fileCopyAct.having;

//

function fileRenameAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );

  _.assertMapHasOnly( o,fileRenameAct.defaults );

  // var con = new wConsequence();
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

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;
fileRenameAct.defaults.sync  = 1;

fileRenameAct.having = {};
fileRenameAct.having.__proto__ = Parent.prototype.fileRenameAct.having;

//

function fileDelete( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  _.routineOptions( fileDelete,o );
  self._providerOptions( o );
  var optionsAct = _.mapScreen( self.fileDeleteAct.defaults,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  // o.filePath = self.pathNativize( o.filePath );

  if( _.files.usingReadOnly )
  return o.sync ? undefined : new wConsequence().give();

  function _fileDelete()
  {
    var stat = self.fileStat( o.filePath );

    if( !stat )
    return;

    var dir  = self._descriptorRead( _.pathDir( o.filePath ) );
    if( !dir )
    throw _.err( 'Not defined behavior' );
    var fileName = _.pathName({ path : o.filePath, withExtension : 1 });
    delete dir[ fileName ];
    self._descriptorWrite( _.pathDir( o.filePath ), dir );
  }

  if( !o.force )
  {
    return self.fileDeleteAct( optionsAct );
  }
  else
  {
    if( o.sync )
    return _fileDelete();

    return _.timeOut( 0, () => _fileDelete() );
  }
}

fileDelete.defaults = {}
fileDelete.defaults.__proto__ = Parent.prototype.fileDelete.defaults;

fileDelete.having = {};
fileDelete.having.__proto__ = Parent.prototype.fileDelete.having;

//

function fileDeleteAct( o )
{
  // var con = new wConsequence();

  _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  // if( _.files.usingReadOnly )
  // return con.give();
  var self = this;

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }



  function _delete( )
  { //!!!should add force option?

    var stat = self.fileStatAct({ filePath :  o.filePath });

    if( stat && stat.isSymbolicLink() )
    {
      debugger;
      throw _.err( 'not tested' );
    }

    if( !stat )
    {
      throw  _.err( 'Path : ', o.filePath, 'doesn`t exist!' );
    }
    var file = self._descriptorRead( o.filePath );
    if( self._descriptorIsDir( file ) && Object.keys( file ).length )
    {
      throw _.err( 'Directory not empty : ', o.filePath );
    }
    var dir  = self._descriptorRead( _.pathDir( o.filePath ) );

    if( !dir )
    throw _.err( 'Not defined behavior' );

    var fileName = _.pathName({ path : o.filePath, withExtension : 1 });
    delete dir[ fileName ];

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

fileDeleteAct.defaults = {};
fileDeleteAct.defaults.__proto__ = Parent.prototype.fileDeleteAct.defaults;

fileDeleteAct.having = {};
fileDeleteAct.having.__proto__ = Parent.prototype.fileDeleteAct.having;

//

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
  self._providerOptions( o );
  // o.filePath = self.pathNativize( o.filePath );

  function handleError( err )
  {
    if( o.sync )
    throw err;
    else
    return new wConsequence().error( err );
  }

  if( o.rewritingTerminal )
  if( self.fileIsTerminal( o.filePath ) )
  {
    self.fileDelete( o.filePath );
  }

  var structure = self._descriptorRead( _.pathDir( o.filePath ) );
  if( !structure && !o.force )
  {
    return handleError( _.err( 'Folder structure before: ', o.filePath, ' not exist!. Use force option to create it.' ) );
  }

  var exists = self._descriptorRead( o.filePath );

  if( _.strIs( exists ) && !o.rewritingTerminal )
  {
    return handleError( _.err( 'Cant rewrite terminal file: ', o.filePath, 'use rewritingTerminal option!' ) );
  }

  if( exists && o.force )
  {
    if( o.sync )
    return;
    else
    return new wConsequence().give();
  }
  else
  {
    delete o.force;
    delete o.rewritingTerminal;
    return self.directoryMakeAct( o );
  }
}

directoryMake.defaults = {};
directoryMake.defaults.__proto__ = Parent.prototype.directoryMake.defaults;

directoryMake.having = {};
directoryMake.having.__proto__ = Parent.prototype.directoryMake.having;

//

function directoryMakeAct( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.routineOptions( directoryMakeAct,o );

  function _mkDir( )
  {
    // var dirPath = _.pathDir( o.filePath );
    // var structure = self._descriptorRead( dirPath );
    // if( !structure )
    // {
    //   // !!! no force in act version
    //   // if( !o.force )
    //   throw _.err( 'Directories structure : ', dirPath, ' doesn`t exist' );
    // }
    var file = self._descriptorRead( o.filePath );
    if( file )
    {
      // if( o.rewritingTerminal )
      // self.fileDeleteAct( o.filePath );
      // else
      throw _.err( 'Path :', o.filePath, 'already exist!' );
    }

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

directoryMakeAct.defaults = {}
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;

directoryMakeAct.having = {};
directoryMakeAct.having.__proto__ = Parent.prototype.directoryMakeAct.having;

//

// function linkSoftAct( o )
// {
//   var self = this;
//
//   _.assertMapHasOnly( o,linkSoftAct.defaults );
//
//   throw _.err( 'not implemented' );
//
// }
//
// linkSoftAct.defaults = {}
// linkSoftAct.defaults.__proto__ = Parent.prototype.linkSoftAct.defaults;
//
// linkSoftAct.having = {};
// linkSoftAct.having.__proto__ = Parent.prototype.linkSoftAct.having;

//

function hardLinkTerminateAct( o )
{
  var self = this;

  var descriptor = self._descriptorRead( o.filePath );

  _.assert( self._descriptorIsHardLink( descriptor ) );

  var read = self._descriptorResolve( descriptor );

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
  return new wConsequence().give();
}

hardLinkTerminateAct.defaults = {};
hardLinkTerminateAct.defaults.__proto__ = Parent.prototype.hardLinkTerminateAct.defaults;

//

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

// --
// special
// --

function fileIsTerminal( filePath )
{
  var self = this;

  _.assert( arguments.length === 1 );

  var stat = self.fileStat( filePath );

  if( !stat )
  return false;

  // if( stat.isSymbolicLink() )
  // {
  //   throw _.err( 'Not tested' );
  //   return false;
  // }

  var file = self._descriptorRead( filePath );
  return !self._descriptorIsDir( file );
}

//

/**
 * Return True if file at `filePath` is a hard link.
 * @param filePath
 * @returns {boolean}
 * @method fileIsHardLink
 * @memberof wFileProviderSimpleStructure
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

// function _descriptorRead( o )
// {
//   var self = this;
//
//   _.assert( arguments.length === 1 );
//
//   if( _.strIs( arguments[ 0 ] ) )
//   var o = { query : arguments[ 0 ] };
//
//   if( o.query === '.' )
//   o.query = '';
//
//   o.container = self.filesTree;
//
//   if( o.set )
//   o.usingSet = 1;
//
//   _.routineOptions( _descriptorRead,o );
//
//   var result = null;
//   result = _.entitySelect( o );
//   return result;
// }
//
// _descriptorRead.defaults =
// {
//   query : null,
//   set : null,
//   usingSet : 0,
//   container : null,
//   delimeter : [ './', '/' ],
// }

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

function _descriptorWrite( o )
{
  var self = this;

  if( _.strIs( arguments[ 0 ] ) )
  var o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };

  if( o.filePath === '.' )
  o.filePath = '';
  if( !o.filesTree )
  o.filesTree = self.filesTree;

  _.routineOptions( _descriptorWrite,o );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var optionsSelect = Object.create( null );

  optionsSelect.usingSet = 1;
  optionsSelect.set = o.data;
  optionsSelect.query = o.filePath;
  optionsSelect.container = o.filesTree;
  optionsSelect.delimeter = o.delimeter;

  var result = _.entitySelect( optionsSelect );
  return result;
}

_descriptorWrite.defaults =
{
  filePath : null,
  filesTree : null,
  data : null,
  delimeter : [ './', '/' ],
}

//

function _descriptorResolve( descriptor )
{
  var self = this;

  if( self._descriptorIsHardLink( descriptor ) && self.resolvingHardLink )
  {
    descriptor = self._descriptorResolveHardLink( descriptor );
    return self._descriptorResolve( descriptor );
  }

  if( self._descriptorIsSoftLink( descriptor ) && self.resolvingSoftLink )
  {
    descriptor = self._descriptorResolveSoftLink( descriptor );
    return self._descriptorResolve( descriptor );
  }

  return descriptor;
}

//

function _descriptorResolveWithPath( descriptor )
{
  var self = this;

  if( self._descriptorIsHardLink( descriptor ) && self.resolvingHardLink )
  {
    descriptor = self._descriptorResolveHardLink( descriptor, true );
    return self._descriptorResolveWithPath( descriptor );
  }

  if( self._descriptorIsSoftLink( descriptor ) && self.resolvingSoftLink )
  {
    descriptor = self._descriptorResolveSoftLink( descriptor, true );
    return self._descriptorResolveWithPath( descriptor );
  }

  return descriptor;
}

//

function _descriptorResolveHardLink( descriptor, withPath )
{
  var self = this;
  var result;

  descriptor = descriptor[ 0 ];

  var url = _.urlParse( descriptor.hardLink );

  if( url.protocol )
  {
    _.assert( url.protocol === 'file','can handle only "file" protocol, but got',url.protocol );
    result = _.fileProvider.fileRead( url.localPath );
    _.assert( _.strIs( result ) );
    // self._descriptorWrite( o.filePath, result );
  }
  else
  {
    debugger;
    result = self._descriptorRead( url.localPath );
  }

  if( withPath )
  return { result : result, filePath : url.localPath };

  return result;
}

//

function _descriptorResolveSoftLink( descriptor, withPath )
{
  var self = this;

  descriptor = descriptor[ 0 ];

  debugger;
  throw _.err( 'not imeplemented' );
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

// --
// encoders
// --

var encoders = {};

fileReadAct.encoders = encoders;

// encoders[ 'json' ] =
// {
//
//   onBegin : function( o )
//   {
//     throw _.err( 'not tested' );
//     _.assert( o.encoding === 'json' );
//     o.encoding = 'utf8';
//   },
//
//   onEnd : function( o,data )
//   {
//     throw _.err( 'not tested' );
//     _.assert( _.strIs( data ) );
//     var result = JSON.parse( data );
//     return result;
//   },
//
// }

// encoders[ 'buffer-raw' ] =
// {
//
//   onBegin : function( o )
//   {
//     _.assert( o.encoding === 'buffer-raw' );
//     o.encoding = 'buffer-raw';
//   },
//
//   onEnd : function( o,data )
//   {
//     _.assert( _.strIs( data ) );
//
//     var result = _.bufferRawFrom( data );
//
//     _.assert( !_.bufferNodeIs( result ) );
//     _.assert( _.bufferRawIs( result ) );
//
//     return result;
//   },
//
// }

// if( isBrowser )
encoders[ 'utf8' ] =
{

  onBegin : function( o )
  {
    _.assert( o.encoding === 'utf8' );
  },

  onEnd : function( o,data )
  {
    // _.assert( _.routineIs( data.toString ) );
    // var result = data.toString();
    // _.assert( _.strIs( result ) );
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

  fileDelete : fileDelete,
  fileDeleteAct : fileDeleteAct,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMake : directoryMake,
  directoryMakeAct : directoryMakeAct,

  //linkSoftAct : linkSoftAct,
  //linkHardAct : linkHardAct,

  hardLinkTerminateAct : hardLinkTerminateAct,

  linksRebase : linksRebase,


  // checker

  fileIsTerminal : fileIsTerminal,
  fileIsHardLink : fileIsHardLink,


  // descriptor

  _descriptorRead : _descriptorRead,
  _descriptorWrite : _descriptorWrite,

  _descriptorResolve : _descriptorResolve,
  _descriptorResolveWithPath : _descriptorResolveWithPath,
  _descriptorResolveHardLink : _descriptorResolveHardLink,
  _descriptorResolveSoftLink : _descriptorResolveSoftLink,

  _descriptorIsDir : _descriptorIsDir,
  _descriptorIsTerminal : _descriptorIsTerminal,
  _descriptorIsLink : _descriptorIsLink,
  _descriptorIsSoftLink : _descriptorIsSoftLink,
  _descriptorIsHardLink : _descriptorIsHardLink,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

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

//

_.FileProvider = _.FileProvider || {};

_.FileProvider[ Self.nameShort ] = Self;
if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
