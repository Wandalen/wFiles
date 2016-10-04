( function _FileProviderSimpleStructure_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './AdvancedMixin.s' );
  require( './Abstract.s' );

  require( './FileBase.s' );

  if( !wTools.FileRecord )
  require( './FileRecord.s' );

  // require( './Files.ss' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

//

var Parent = _.FileProvider.Abstract;
var DefaultsFor = Parent.DefaultsFor;
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

/* should be syncronous, no callback */

var _selectFromTree = function( o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var self = this;
  o.container = self._tree;
  var getDir = o.getDir;
  var getFile = o.getFile;
  delete o.getDir;
  delete o.getFile;

  _.mapComplement( o,_selectFromTree.defaults );

  var result =null;

  result = _.entitySelect( o );

  if( _.objectIs( result ) && !getDir )
  {
    throw  _.err( "Can`t read from dir : '" + o.query + "' method expects file");
  }
  else if( !result && getFile )
  {
    throw  _.err( "File :'" + o.query +"' doesn't exist");
  }
  else if( !result && getDir )
  {
    throw  _.err( "Folder/struct : '" + o.query +"' doesn't exist");
  }

  return result;
}

_selectFromTree.defaults =
{
  delimeter : [ '/' ],
}

//

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

fileReadAct.defaults = DefaultsFor.fileReadAct;
fileReadAct.isOriginalReader = 1;

//

var fileStat = function( filePath )
{
  var result = null;

  return result;
}

// --
// write
// --

var fileTimeSet = function( o )
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

  _.assertMapHasOnly( o,fileTimeSet.defaults );

}

fileTimeSet.defaults = DefaultsFor.fileTimeSet;

//

var fileCopy = function( o )
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

  var self = this;

  _.assertMapHasOnly( o,fileCopy.defaults );

  var src = self._selectFromTree( { query : o.src  } );

  self._selectFromTree( { query : o.dst, set : src } );


}

fileCopy.defaults = DefaultsFor.fileCopy;

//

var fileRename = function( o )
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

  _.assertMapHasOnly( o,fileRename.defaults );

  var self = this;
  var con = new wConsequence();
  // _.assertMapHasOnly( o,fileCopy.defaults );

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
    self._selectFromTree( { query : o.src  } );

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

fileRename.defaults = DefaultsFor.fileRename;
fileRename.defaults.sync  = 1;

//

var fileDelete = function( o )
{
  var con = new wConsequence();

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDelete,o );
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

fileDelete.defaults = DefaultsFor.fileDelete;

//

var directoryMake = function( o )
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
  _.assertMapHasOnly( o,directoryMake.defaults );


  if( o.force )
  {
   var dir = self._selectFromTree( { query : o.pathFile, getDir : 1, sync : 1 } );
   if( dir === undefined )
   {
     self._selectFromTree( { query : o.pathFile, set : { }, getDir : 1, sync : 1 } );
   }

  }
  // else
  // {
  //
  // }

}

directoryMake.defaults =
{
  pathFile : null,
  force : 0,
}

//

var directoryRead = function( o )
{

  var sub = File.readdirSync( record.absolute );

}

//

var linkSoftMake = function( o )
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

  _.assertMapHasOnly( o,linkSoftMake.defaults );

  File.symlinkSync( o.src,o.dst );

}

linkSoftMake.defaults =
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
  _selectFromTree : _selectFromTree,
  // fileStat : fileStat,



  // write

  // fileTimeSet : fileTimeSet,
  fileCopy : fileCopy,
  fileRename : fileRename,

  //fileDelete : fileDelete,

  directoryMake : directoryMake,
  // linkSoftMake : linkSoftMake,


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
