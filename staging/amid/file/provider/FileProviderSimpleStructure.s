( function _FileProviderSimpleStructure_s_() {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  require( '../FileBase.s' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

  if( !wTools.FileProvider.Abstract )
  require( './Abstract.s' );

}

if( wTools.FileProvider.SimpleStructure )
return;

var _ = wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderSimpleStructure( o )
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
  // self._tree = o.filesTree;
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

    var err = _.err( err );
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
  result = self._select( o.pathFile );
  if( !result )
  {
    return handleError( _.err( 'File at :', o.pathFile, 'doesn`t exist!' ) );
  }
  if( self._isDir( result ) )
  {
    return handleError( _.err( "Can`t read from dir : '" + o.pathFile + "' method expects file") );
  }
  return handleEnd( result );
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;
fileReadAct.isOriginalReader = 1;

//

function fileStatAct( o )
{
  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( _.strIs( o.pathFile ) );
  var o = _.routineOptions( fileStatAct,o );

  var result = null;
  var self = this;
  function Stats()
  {
    var self = this;
    var keys =
    [
      "dev", "mode", "nlink", "uid", "gid",
      "rdev", "blksize", "ino", "size", "blocks",
      "atime", "mtime", "ctime", "birthtime"
    ];
    var methods =
    [
      "_checkModeProperty", "isDirectory",
      "isFile", "isBlockDevice", "isCharacterDevice",
      "isSymbolicLink", "isFIFO", "isSocket"
    ];

    for ( var key in keys )
    self[ keys[ key ] ] = null;

    for ( var key in methods )
    self[ methods[ key ] ] = function() { };
  }

  /* */

  function getFileStat()
  {
    var file = self._select( o.pathFile );
    if( file )
    {
      var stat = new Stats();
      result = stat;
    }
    else if( o.throwing )
    {
      throw _.err( 'Path :', o.pathFile, 'doesn`t exist!' );
    }
  }

  /* */

  if( o.sync )
  {
    getFileStat( );
    return result;
  }
  else
  {
    var con = new wConsequence();
    try
    {
      getFileStat( );
      con.give( result );
    }
    catch ( err )
    {
      con.error( err );
    }
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
    var result=NaN;
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
    function makeHash()
    {
      try
      {
        var read = self.fileReadAct( { pathFile : o.pathFile, sync : 1 } );
        md5sum.update( read );
        result = md5sum.digest( 'hex' );
      }
      catch( err )
      {
        if( o.throwing )
        {
          var err = _.err( err );
          throw err;
        }
      }
    }

   if( o.sync )
   {
     makeHash( );
     return result;
   }
   else
   {
     var con = _.timeOut( 0 );
     con.doThen( function()
     {
       try
       {
         makeHash( );
         return con.give( result );
       }
       catch ( err )
       {
         return con.error( err );
       }
     });
     return con;
   }
  }
})();

fileHashAct.defaults = {};
fileHashAct.defaults.__proto__ = Parent.prototype.fileHashAct.defaults;

// --
// write
// --

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

  _.assertMapHasOnly( o,fileTimeSetAct.defaults );

}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Parent.prototype.fileTimeSetAct.defaults;

//

function fileWriteAct( o )
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

  /* write */

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }

  function write( )
  {

    var dstName = _.pathName({ path : o.pathFile, withExtension : 1 });
    var dstDir = _.pathDir( o.pathFile );

    // console.log( 'o.pathFile',o.pathFile );
    // console.log( 'dstName',dstName );
    // console.log( 'dstDir',dstDir );

    var structure = self._select( dstDir );
    if( !structure )
    throw _.err( 'Directories structure :' , dstDir, 'doesn`t exist' );
    if( self._isDir( structure[ dstName ] ) )
    throw _.err( 'Incorrect path to file!\nCan`t rewrite dir :', o.pathFile );

    if( o.writeMode === 'rewrite' )
    {
      structure[ dstName ] = o.data;
    }
    else if( o.writeMode === 'append' )
    {
      var oldFile = structure[ dstName ];
      var newFile = oldFile ? oldFile.concat( o.data ) : o.data;
      structure[ dstName ] = newFile;
    }
    else if( o.writeMode === 'prepend' )
    {
      var oldFile = structure[ dstName ];
      var newFile = oldFile ? o.data.concat( oldFile ) : o.data;
      structure[ dstName ] = newFile;
    }
    else
    throw _.err( 'not implemented write mode',o.writeMode );

    /* what for is that needed ??? */
    /*self._select({ query : dstDir, set : structure });*/
  }

  /* */

  if( o.sync )
  {
    write();
  }
  else
  {
    var con = _.timeOut( 0 );
    con.doThen( function()
    {
      try
      {
        write();
      }
      catch ( err )
      {
        return con.error( err );
      }

    })
    return con;
  }

}

fileWriteAct.defaults = {};
fileWriteAct.defaults.__proto__ = Parent.prototype.fileWriteAct.defaults;

fileWriteAct.isWriter = 1;

//

function fileCopyAct( o )
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

  _.assertMapHasOnly( o,fileCopyAct.defaults );
  var self = this;

  // function handleError( err )
  // {
  //   var err = _.err( err );
  //   if( o.sync )
  //   throw err;
  //   return con.error( err );
  // }

  function copy( )
  {
    var pathSrc = self._select( o.pathSrc );
    if( !pathSrc )
    throw _.err( 'File/dir : ', o.pathSrc, 'doesn`t exist!' );
    if( self._isDir( pathSrc ) )
    throw _.err( o.pathSrc,' is not a terminal file!' );

    var pathDst = self._select( o.pathDst );
    if( self._isDir( pathDst ) )
    throw _.err( 'Can`t rewrite dir with file, method expects file : ', o.pathDst );

    self._select({ query : o.pathDst, set : pathSrc, usingSet : 1 });
  }

  if( o.sync  )
  {
    copy( );
  }
  else
  {
    var con = _.timeOut( 0 );
    con.doThen( function()
    {
      try
      {
        copy( );
      }
      catch ( err )
      {
        return con.error( err );
      }
    })
    return con;
  }
}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;
fileCopyAct.defaults.sync = 0;

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

  _.assertMapHasOnly( o,fileRenameAct.defaults );

  var self = this;
  // var con = new wConsequence();
  // _.assertMapHasOnly( o,fileCopyAct.defaults );

  var dstName = _.pathName({ path : o.pathDst, withExtension : 1 });
  var srcName = _.pathName({ path : o.pathSrc, withExtension : 1 });
  var srcPath = _.pathDir( o.pathSrc );
  var dstPath = _.pathDir( o.pathDst );

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
    var pathSrc = self._select( srcPath );
    if( !pathSrc || !pathSrc[ srcName ] )
    throw _.err( 'Source path : ', o.pathSrc, 'doesn`t exist!' );

    var pathDst = self._select( dstPath );
    if( !pathDst )
    throw _.err( 'Destination folders structure : ' + dstPath + ' doesn`t exist' );
    if( pathDst[ dstName ] )
    throw _.err( 'Destination path : ', o.pathDst, 'already exist!' );

    if( dstPath === srcPath )
    {
      pathDst[ dstName ] = pathDst[ srcName ];
      delete pathDst[ srcName ];
    }
    else
    {
      pathDst[ dstName ] = pathSrc[ srcName ];
      delete pathSrc[ srcName ];
      self._select({ query : srcPath, set : pathSrc, usingSet : 1 });
    }
    self._select({ query : dstPath, set : pathDst, usingSet : 1 });

  }

  if( o.sync )
  {
    rename( );
  }
  else
  {
    var con = _.timeOut( 0 );
    con.doThen( function()
    {
      try
      {
        rename( );
      }
      catch ( err )
      {
        return con.error( err );
      }
    })
    return con;
  }

// return con;
}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;
fileRenameAct.defaults.sync  = 1;

//

function fileDeleteAct( o )
{
  // var con = new wConsequence();

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

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

    var stat = self.fileStatAct( o.pathFile );

    if( stat && stat.isSymbolicLink() )
    {
      debugger;
      throw _.err( 'not tested' );
    }

    if( !stat )
    {
      throw  _.err( 'Path : ', o.pathFile, 'doesn`t exist!' );
    }
    var file = self._select( o.pathFile );
    if( self._isDir( file ) && Object.keys( file ).length )
    {
      throw _.err( 'Directory not empty : ', o.pathFile );
    }
    var dir  = self._select( _.pathDir( o.pathFile ) );
    var fileName = _.pathName({ path : o.pathFile, withExtension : 1 });
    delete dir[ fileName ];

    self._select({ query : _.pathDir( o.pathFile ), set : dir, usingSet : 1 });
  }

  if( o.sync )
  {
    _delete( );
  }
  else
  {
    var con = _.timeOut( 0 );
    con.doThen( function()
    {
      try
      {
        _delete();
      }
      catch ( err )
      {
        return con.error( err );
      }
    })
    return con;
  }

  // return con;
}

fileDeleteAct.defaults = {};
fileDeleteAct.defaults.__proto__ = Parent.prototype.fileDeleteAct.defaults;

//

function directoryMakeAct( o )
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

  var self = this;
  var o = _.routineOptions( directoryMakeAct, o);

  function _mkDir( )
  {
    var dirPath = _.pathDir( o.pathFile );
    var structure = self._select( dirPath );
    if( !structure )
    {
      if( !o.force )
      throw _.err( 'Directories structure : ', dirPath, ' doesn`t exist' );
    }
    var file = self._select( o.pathFile );
    if( file )
    {
      if( o.rewritingTerminal )
      self.fileDeleteAct( o.pathFile );
      else
      throw _.err( 'Path :', o.pathFile, 'already exist!' );
    }

    self._select({ query : o.pathFile, set : { }, usingSet : 1 });
  }

  //

  if( o.sync )
  {
    _mkDir();
  }
  else
  {
    var con = _.timeOut( 0 );
    con.doThen( function ()
    {
      try
      {
        _mkDir();
      }
      catch ( err )
      {
        return con.error( err );
      }
    })
    return con;
  }
}

directoryMakeAct.defaults = {}
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;


//

function directoryReadAct( o )
{

  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }

  _.assert( arguments.length === 1 );
  _.routineOptions( directoryReadAct,o );

  var result;
  var self = this;
  var readDir = function ()
  {
    var file = self._select( o.pathFile );
    if( file )
    {
      //var stat = self.fileStatAct( o.pathFile );
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
        result = [ _.pathName({ path : o.pathFile, withExtension : 1 }) ];
      }
    }
    else
    {
      if( o.throwing )
      {
        throw _.err( "Path : ", o.pathFile, 'doesn`t exist!' );;
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
    var con = _.timeOut( 0 );
    con.doThen( function ()
    {
      try
      {
        readDir();
        return con.give( result );
      }
      catch ( err )
      {
        return con.error( err );
      }
    })
    return con;
  }
}

directoryReadAct.defaults = {}
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

//

function linkSoftAct( o )
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

  _.assertMapHasOnly( o,linkSoftAct.defaults );

  throw _.err( 'not implemented' );

}

linkSoftAct.defaults = {}
linkSoftAct.defaults.__proto__ = Parent.prototype.linkSoftAct.defaults;

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( o )
  {
    throw _.err( 'not tested' );
    _.assert( o.encoding === 'json' );
    o.encoding = 'utf8';
  },

  onEnd : function( o,data )
  {
    throw _.err( 'not tested' );
    _.assert( _.strIs( data ) );
    var result = JSON.parse( data );
    return result;
  },

}

encoders[ 'arraybuffer' ] =
{

  onBegin : function( o )
  {
    _.assert( o.encoding === 'arraybuffer' );
    o.encoding = 'buffer';
  },

  onEnd : function( o,data )
  {
    _.assert( _.strIs( data ) );

    var result = _.bufferRawFrom( data );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
  },

}

if( !isBrowser )
{
  encoders[ 'arraybuffer' ] =
  {

    onBegin : function( o )
    {
      _.assert( o.encoding === 'arraybuffer' );
      o.encoding = 'buffer';
    },

    onEnd : function( o,data )
    {
      data = new Buffer( data );

      _.assert( _.bufferNodeIs( data ) );
      _.assert( !_.bufferIs( data ) );
      _.assert( !_.bufferRawIs( data ) );

      var result = _.bufferRawFrom( data );

      _.assert( !_.bufferNodeIs( result ) );
      _.assert( _.bufferRawIs( result ) );

      return result;
    },

  }

  encoders[ 'buffer' ] =
  {

    onBegin : function( o )
    {
      _.assert( o.encoding === 'buffer' );
      o.encoding = 'buffer';
    },

    onEnd : function( o,data )
    {
      _.assert( _.strIs( data ) );

      var result = new Buffer( data );

      _.assert( _.bufferNodeIs( result ) );

      return result;
    },

  }

  var knownToStringEncodings = [ 'ascii','utf8','utf16le','ucs2','base64','latin1','binary','hex' ];

  for( var i = 0,l = knownToStringEncodings.length; i < l; ++i )
  {
    encoders[ knownToStringEncodings[ i ] ] =
    {
      onBegin : function( o )
      {
        _.assert( knownToStringEncodings.indexOf( o.encoding ) != -1 );
      },

      onEnd : function( o,data )
      {
        _.assert( _.strIs( data ) );
        return new Buffer( data ).toString( o.encoding );
      },
    }
  }
}


fileReadAct.encoders = encoders;

// --
// special
// --

function _select( o )
{
  _.assert( arguments.length === 1 );

  if( _.strIs( arguments[ 0 ] ) )
  var o = { query : arguments[ 0 ] };

  if( o.query === '.' )
  o.query = '';

  var self = this;
  o.container = self.filesTree;

  if( o.set )
  o.usingSet = 1;

  _.routineOptions( _select,o );

  var result = null;
  result = _.entitySelect( o );
  return result;
}

_select.defaults =
{
  query : null,
  set : null,
  usingSet : 0,
  container : null,
  delimeter : [ './', '/' ],
}

//

function _isDir( file )
{
  return _.objectIs( file );
}

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
  fileStatAct : fileStatAct,
  fileHashAct : fileHashAct,
  directoryReadAct : directoryReadAct,


  // write

  fileWriteAct : fileWriteAct,

  fileDeleteAct : fileDeleteAct,

  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileTimeSetAct : fileTimeSetAct,

  directoryMakeAct : directoryMakeAct,

  // linkSoftAct : linkSoftAct,
  //linkHardAct : linkHardAct,


  // special

  _select : _select,
  _isDir : _isDir,


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
_.FileProvider.SimpleStructure = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
