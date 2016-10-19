( function _FileProviderSimpleStructure_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

  if( !wTools.FileProvider.Abstract )
  require( './Abstract.s' );

}

var File = require( 'fs-extra' );
var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

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

var init = function( o )
{
  var self = this;
  self._tree = o.tree;
  Parent.prototype.init.call( self,o );
}

// --
// read
// --

var fileReadAct = function( o )
{
  var self = this;
  var con = new wConsequence();
  var result = null;

  _.assert( arguments.length === 1 );
  _.mapComplement( o,fileReadAct.defaults );

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  var handleBegin = function()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,o );

  }

  /* end */

  var handleEnd = function( data )
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

  var handleError = function( err )
  {

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

var fileStatAct = function( o )
{
  _.assert( arguments.length === 1 );

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.assert( _.strIs( o.pathFile ) );
  var o = _.routineOptions( fileStatAct,o );

  var result = null;
  var self = this;
  var getFileStat = function()
  {
    var file = self._select( o.pathFile );
    if( file )
    {
      var stat = new File.Stats();
      for ( var key in stat )
      {
        if( !_.isFunction( stat[ key ] ) )
        stat[ key ] = null;
      }
      result = stat;
    }

  }
  if( o.sync )
  {
    getFileStat( );
    return result;
  }
  else
  {
    getFileStat( );
    var con = new wConsequence();
    con.give( result )
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
    var makeHash = function()
    {
      try
      {
        var read = self.fileReadAct( { pathFile : o.pathFile, sync : 1 } );
        md5sum.update( read );
        result = md5sum.digest( 'hex' );
      }
      catch( err ){ }
    }
   if( o.sync )
   {
     makeHash( );
     return result;
   }
   else
   {
     var con = _.timeOut( 0 );
     con.thenDo( function()
     {
       makeHash( );
       con.give( result );
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

  _.assertMapHasOnly( o,fileTimeSetAct.defaults );

}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Parent.prototype.fileTimeSetAct.defaults;

//

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

  /* write */
  var handleError = function( err )
  {
    var err = _.err( err );
    if( o.sync )
    throw err;
    con.give( err,null );
  }

  var write = function( )
  {
    var dstName = _.pathName( o.pathFile, { withExtension : 1 } );
    var dstDir = _.pathDir( o.pathFile );
    var structure = self._select( dstDir );
    if( !structure )
    return handleError( _.err( 'Folders structure : ' , dstDir, ' doesn`t exist' ) );
    if( self._isDir( structure[ dstName ] ) )
    return handleError( _.err( "Incorrect path to file!Can`t rewrite dir:", o.pathFile ) );

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
    return handleError( _.err( 'not implemented write mode',o.writeMode ) );

    self._select( { query : dstDir, set : structure } );
  }

  if( o.sync )
  {
    write();
  }
  else
  {
    var con = _.timeOut( 0 );
    con.thenDo( function()
    {
      write();
    })
    return con;
  }

}

fileWriteAct.defaults = {};
fileWriteAct.defaults.__proto__ = Parent.prototype.fileWriteAct.defaults;

fileWriteAct.isWriter = 1;

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

  _.assertMapHasOnly( o,fileCopyAct.defaults );
  var self = this;

  var handleError = function( err )
  {
    var err = _.err( err );
    if( o.sync )
    throw err;
    con.give( err,null );
  }

  var copy = function( )
  {
    var src = self._select( o.src );
    if( !src )
    return handleError( _.err( 'File/dir : ', o.src, 'doesn`t exist!' ) );
    if( self._isDir( src ) )
    return handleError( _.err( 'Expects file, but got dir : ', o.src ) );

    var dst = self._select( o.dst );
    if( self._isDir( dst ) )
    return handleError( _.err( 'Can`t rewrite dir with file, method expects file : ', o.dst ) );

    self._select( { query : o.dst, set : src } );
  }

  if( o.sync  )
  {
    copy( );

  }
  else
  {
    var con = _.timeOut( 0 );
    con.thenDo( function()
    {
      copy();
    })
    return con;
  }
}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Parent.prototype.fileCopyAct.defaults;
fileCopyAct.defaults.sync = 0;

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

  _.assertMapHasOnly( o,fileRenameAct.defaults );

  var self = this;
  // var con = new wConsequence();
  // _.assertMapHasOnly( o,fileCopyAct.defaults );

  var dstName = _.pathName( o.dst, { withExtension : 1 } );
  var srcName = _.pathName( o.src, { withExtension : 1 } );
  var srcPath = _.pathDir( o.src );
  var dstPath = _.pathDir( o.dst );

  var handleError = function( err )
  {
    var err = _.err( err );
    if( o.sync )
    throw err;
    con.give( err,null );
  }

  /*rename*/
  var rename = function( )
  {
    var src = self._select( srcPath );
    if( !src || !src[ srcName ] )
    return handleError( _.err( 'Source path : ', o.src, 'doesn`t exist!' ) );

    var dst = self._select( dstPath );
    if( !dst )
    return handleError( _.err( 'Destination folders structure : ' + dstPath + ' doesn`t exist' ) );
    if( dst[ dstName ] )
    return handleError( _.err( 'Destination path : ', o.dst, 'already exist!' ) );

    if( dstPath === srcPath )
    {
      dst[ dstName ] = dst[ srcName ];
      delete dst[ srcName ];
    }
    else
    {
      dst[ dstName ] = src[ srcName ];
      delete src[ srcName ];
      self._select( { query : srcPath, set : src } );
    }
    self._select( { query : dstPath, set : dst } );

  }

  if( o.sync )
  {
    rename( );
  }
  else
  {
    var con = _.timeOut( 0 );
    con.thenDo( function()
    {
      rename();
    })
    return con;
  }

// return con;
}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Parent.prototype.fileRenameAct.defaults;
fileRenameAct.defaults.sync  = 1;

//

var fileDeleteAct = function( o )
{
  var con = new wConsequence();

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

  if( _.files.usingReadOnly )
  return con.give();
  var self = this;

  var handleError = function( err )
  {
    var err = _.err( err );
    if( o.sync )
    throw err;
    con.give( err,null );
  }

  var stat = self.fileStatAct( o.pathFile );

  if( stat && stat.isSymbolicLink() )
  {
    debugger;
    return handleError( _.err( 'not tested' ) );
  }

  var _delete = function( )
  { //!!!should add force option?
    if( !stat )
    {
      return handleError( _.err( 'Path : ', o.pathFile, 'doesn`t exist!' ) );
    }
    var dir  = self._select( _.pathDir( o.pathFile ) );
    var fileName = _.pathName( o.pathFile, { withExtension : 1 } );
    var file = self._select( fileName );
    if( self._isDir( file ) && Object.keys( file ).length )
    {
      return handleError( _.err( 'Directory not empty : ', o.pathFile ) );
    }
    delete dir[ fileName ];
    self._select( { query : _.pathDir( o.pathFile ), set : dir } );
  }
  if( o.sync )
  {
    _delete( );
  }
  else
  {
    var con = _.timeOut( 0 );
    con.thenDo( function()
    {
      _delete( );
    })
    return con;
  }

  return con;
}

fileDeleteAct.defaults = {};
fileDeleteAct.defaults.__proto__ = Parent.prototype.fileDeleteAct.defaults;

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

  var self = this;
  _.assertMapHasOnly( o,directoryMakeAct.defaults );

  var _mkDir = function( )
  {
    var dirPath = _.pathDir( o.pathFile );
    var structure = self._select( dirPath );
    if( !structure )
    {
      if( o.sync  )
      throw _.err( 'Folders structure : ' + dirPath + ' doesn`t exist' );
      return con.error( _.err( 'Folders structure : ' + dirPath + ' doesn`t exist' ) );
    }
    var file = self._select( o.pathFile );
    if( file )
    {
      if( o.sync )
      throw _.err( 'Path :', o.pathFile, 'already exist!' );
      return con.error( _.err( 'Path :', o.pathFile, 'already exist!' ) );
    }

    self._select( { query : o.pathFile, set : { } } );
  }

  //

  if( o.sync )
  {
    _mkDir();
  }
  else
  {
    var con = _.timeOut( 0 );
    con.thenDo( function ()
    {
      _mkDir();
      con.give( null );
    })
    return con;
  }
}

directoryMakeAct.defaults = {}
directoryMakeAct.defaults.__proto__ = Parent.prototype.directoryMakeAct.defaults;


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
    con.thenDo( function ()
    {
      readDir();
      con.give( result );
    })
    return con;
  }
}

directoryReadAct.defaults = {}
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

//

var linkSoftAct = function( o )
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

    _.assert( _.bufferNodeIs( data ) );
    _.assert( !_.bufferIs( data ) );
    _.assert( !_.bufferRawIs( data ) );

    var result = _.bufferRawFrom( data );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
  },

}

fileReadAct.encoders = encoders;

// --
// special
// --

var _selectFromTree = function( o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var self = this;
  o.container = self._tree;
  var getDir = o.getDir;
  var getFile = o.getFile;
  delete o.getDir;
  delete o.getFile;

  _.routineOptions( _selectFromTree,o );

  var result =null;

  result = _.entitySelect( o );

  if( _.objectIs( result ) && !getDir )
  {
    throw  _.err( "Can`t read from dir : '" + o.query + "' method expects file");
  }
  else if( !result && getFile )
  {
    throw  _.err( "File :'" + o.query + "' doesn't exist");
  }
  else if( !result && getDir )
  {
    throw  _.err( "Folder/struct : '" + o.query +"' doesn't exist");
  }

  return result;
}

_selectFromTree.defaults =
{
  query : null,
  set : null,
  container : null,
  delimeter : [ '/' ],
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
  tree : null,
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

  linkSoftAct : linkSoftAct,
  //linkHardAct : linkHardAct,


  // special

  _selectFromTree : _selectFromTree,


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
