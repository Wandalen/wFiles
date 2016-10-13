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
  var con;
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
      return wConsequence.from( data );
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
      return wConsequence.from( err );
    }

  }

  /* exec */

  handleBegin();
  try
  {
    result = self._selectFromTree( { query : o.pathFile, getFile : 1 } );
    return handleEnd( result );
  }
  catch( err )
  {
    return handleError( err );
  }


}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;
fileReadAct.isOriginalReader = 1;

//

var fileStatAct = function( filePath )
{
  var result = null;

  return result;
}

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

  if( o.sync )
  {

      if( o.writeMode === 'rewrite' )
      self._selectFromTree( { query : o.pathFile, set : o.data, getFile : 1 } );
      else if( o.writeMode === 'append' )
      {
        var oldFile = self._selectFromTree( { query : o.pathFile, getFile : 1  } );
        var newFile = oldFile.concat( o.data );
        self._selectFromTree( { query : o.pathFile, set : newFile, getFile : 1 } );
      }
      else if( o.writeMode === 'prepend' )
      {
        var oldFile = self._selectFromTree( { query : o.pathFile, getFile : 1  } );
        var newFile = o.data.concat( oldFile );
        self._selectFromTree( { query : o.pathFile, set : newFile, getFile : 1 } );
      }
      else throw _.err( 'not implemented write mode',o.writeMode );

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
    {
      self._selectFromTree( { query : o.pathFile, set : o.data, getFile : 1 } );
      handleEnd();
    }
    else if( o.writeMode === 'append' )
    {
      try
      {
        var oldFile = self._selectFromTree( { query : o.pathFile, getFile : 1  } );
        var newFile = oldFile.concat( o.data );
        self._selectFromTree( { query : o.pathFile, set : newFile, getFile : 1 } );
        handleEnd();
      }
      catch( err )
      {
        handleEnd( err );
      }
    }
    else if( o.writeMode === 'prepend' )
    {
      try
      {
        var oldFile = self._selectFromTree( { query : o.pathFile, getFile : 1  } );
        var newFile = o.data.concat( oldFile );
        self._selectFromTree( { query : o.pathFile, set : newFile, getFile : 1 } );
        handleEnd();
      }
      catch( err )
      {
        handleEnd( err );
      }
    }
    else throw _.err( 'not implemented write mode',o.writeMode );

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
  var con = new wConsequence();

  var _isDir = function( )
  {
    //if dst ways to dir that exists throws error, else copies  src
    var dir;
    try
    {
      dir = self._selectFromTree( { query : o.dst, getDir : 1  } );
    }
    catch ( err ) { }
    if( _.objectIs( dir ) )
    {
      if( o.sync )
      throw _.err( 'Can`t rewrite dir with file, method expects file, o.dst : ' + o.dst );
      else
      return con.error( _.err( 'Can`t rewrite dir with file, method expects file, o.dst : ' + o.dst ) );
    }

    self._selectFromTree( { query : o.dst, set : src, getFile : 1 } );
    con.give();
  }

  if( o.sync  )
  {
    var src = self._selectFromTree( { query : o.src, getFile : 1  } );
    _isDir();
  }
  else
  {
    try
    {
      var src = self._selectFromTree( { query : o.src, getFile : 1  } );
    }
    catch ( err )
    {
      return con.error( _.err( err ) );
    }
    _isDir();
  }

 return con;
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
  var con = new wConsequence();
  // _.assertMapHasOnly( o,fileCopyAct.defaults );

  var dst = _.pathName( o.dst, { withExtension : 1 } );
  var src = _.pathName( o.src, { withExtension : 1 } );
  var dirPath = _.pathDir( o.dst );
  var dir = null;
  var _renameInDir = function( )
  {
    dir = self._selectFromTree( { query : dirPath , getDir : 1 } );
    dir[ dst ] = dir[ src ];
    delete dir[ src ];
  }

  if( o.sync )
  {
    //check if file exist
    self._selectFromTree( { query : o.src, getFile : 1  } );

    _renameInDir( );

    self._selectFromTree( { query : dirPath, set: dir, getDir : 1 } );
    con.give();
  }
  else
  {
    try
    {
      self._selectFromTree( { query : o.src  } );
    }
    catch( err )
    {
      return con.error( _.err( 'Can`t read from dir, method expects file, o.src : ' + o.src ) );
    }

    try
    {
      _renameInDir( );
    }
    catch( err )
    {
      return con.error( _.err( 'Folder at : ' + dirPath + ' doesn`t exist' ) );
    }

    self._selectFromTree( { query : dirPath, set: dir, getDir : 1 } );
    con.give();
  }

return con;
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

  var stat;
  if( o.sync )
  {

    if( !o.force )
    {
      try
      {
        stat = File.lstatSync( o.pathFile );
      }
      catch( err ){};
      if( !stat )
      return con.error( _.err( 'cant read ' + o.pathFile ) );
      if( stat.isSymbolicLink() )
      {
        debugger;
        //throw _.err( 'not tested' );
      }
      if( stat.isDirectory() )
      File.rmdirSync( o.pathFile );
      else
      File.unlinkSync( o.pathFile );
    }
    else
    {
      File.removeSync( o.pathFile );
    }

    con.give();

  }
  else
  {

    if( !o.force )
    {
      try
      {
        stat = File.lstatSync( o.pathFile );
      }
      catch( err ){};
      if( !stat )
      return con.error( _.err( 'cant read ' + o.pathFile ) );
      if( stat.isSymbolicLink() )
      throw _.err( 'not tested' );
      if( stat.isDirectory() )
      File.rmdir( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
      else
      File.unlink( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
    }
    else
    {
      File.remove( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
    }

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
  var con = new wConsequence();
  _.assertMapHasOnly( o,directoryMakeAct.defaults );

  var _force = function ()
  {
    var file,dir;
    try
    {
     file = self._selectFromTree( { query :  o.pathFile, getFile : 1 } );

    }
    catch ( err ){ }
    try
    {
     dir = self._selectFromTree( { query :  o.pathFile, getDir : 1 } );
    }
    catch ( err ){ }

    if( _.objectIs( dir ) )
    {
      if( !o.sync )
      return con.error( _.err( "Dir: '" + o.pathFile + "' already exist" ) );
      else
      throw  _.err( "Dir: '" + o.pathFile + "' already exist" );
    }
    self._selectFromTree( { query : o.pathFile, set : {}, getDir : 1 } );

  }

  var _mkDir = function( )
  {
    try
    {
      var dir = self._selectFromTree( { query : o.pathFile, getDir : 1  } );
    }
    catch ( err ){};

    if( dir  )
    {
      if( o.sync )
      throw  _.err( "Dir: '" + o.pathFile + "' already exist" );
      else
      return con.error( _.err( "Dir: '" + o.pathFile + "' already exist" ) );
    }

    self._selectFromTree( { query : o.pathFile,  set : {}, getDir : 1 } );

  }

  //

  if( o.sync )
  {
    self._selectFromTree( { query : _.pathDir( o.pathFile ), getDir : 1 } );

    if( o.force )
    _force();
    else
    //check if dir/file exists and create
    _mkDir();
    con.give();

  }
  else
  {
    try
    {
      self._selectFromTree( { query : _.pathDir( o.pathFile ), getDir : 1 } );
    }
    catch( err )
    {
      return con.error( _.err( 'Folder structure : ' + dirPath + ' doesn`t exist' ) );
    }

    if( o.force )
    _force();
    else
    //check if dir/file exists and create
    _mkDir();
    con.give();

  }
 return con;
}

directoryMakeAct.defaults =
{
  pathFile : null,
  force : 0,
  sync : 0,
}

//

var directoryReadAct = function( o )
{

  var sub = File.readdirSync( record.absolute );

}

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

  File.symlinkSync( o.src,o.dst );

}

linkSoftAct.defaults =
{
  pathFile : null,
}

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
{ query : null,
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
  // fileStatAct : fileStatAct,



  // write

  fileWriteAct : fileWriteAct,
  // fileTimeSetAct : fileTimeSetAct,
  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  //fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,
  // linkSoftAct : linkSoftAct,


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
