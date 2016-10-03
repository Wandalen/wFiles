( function _FileProviderHardDrive_s_() {

'use strict';

require( './AdvancedMixin.s' );
require( './Abstract.s' );
require( './FileRecord.s' );
require( './Files.ss' );

var Path = require( 'path' );
var File = require( 'fs-extra' );

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

//

var Parent = _.FileProvider.Abstract;
var DefaultsFor = Parent.DefaultsFor;
var Self = function wFileProviderHardDrive( o )
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

  if( o.sync )
  {

    result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );

    return handleEnd( result );
  }
  else
  {

    File.readFile( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
    {

      if( err )
      return handleError( err );
      else
      return handleEnd( data );

    });

  }

  /* done */

  return con;
}

fileReadAct.defaults = DefaultsFor.fileReadAct;
fileReadAct.isOriginalReader = 1;

//

var fileStat = function( filePath )
{
  var result = null;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( filePath ) );

  try
  {
    result = File.statSync( filePath );
  }
  catch( err )
  {
  }

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

  File.utimesSync( o.filePath, o.atime, o.mtime );

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

  _.assertMapHasOnly( o,fileCopy.defaults );

  File.copySync( o.src,o.dst );

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


  var con = new wConsequence();

  if( o.sync )
  {
    File.renameSync( o.src, o.dst );
    con.give();
  }
  else
  {
    File.rename( o.src, o.dst, function( err,data )
    {
        if( err )
        con._giveWithError( err,data );
    } );
  }

 return con;
}

fileRename.defaults = DefaultsFor.fileRename;
fileRename.defaults.sync = 0;

//

/**
 * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
 * @example
 * var fs = require('fs');

   var path = 'tmp/fileSize/data',
   textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
   delOptions = {
     pathFile : path,
     sync : 0
   };

   wTools.fileWrite( { pathFile : path, data : textData } ); // create test file

   console.log( fs.existsSync( path ) ); // true (file exists)
   var con = wTools.fileDelete( delOptions );

   con.got( function(err)
   {
     console.log( fs.existsSync( path ) ); // false (file does not exist)
   } );
 * @param {string|Object} o - options object.
 * @param {string} o.pathFile path to file/directory for deleting.
 * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
    content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
 * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
 * @returns {wConsequence}
 * @throws {Error} If missed argument, or pass more than 1.
 * @throws {Error} If pathFile is not string.
 * @throws {Error} If options object has unexpected property.
 * @method fileDelete
 * @memberof wTools
 */

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
  var con = new wConsequence();
  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.assertMapHasOnly( o,directoryMake.defaults );


var stat;

if( o.sync )
{
  //if no structure to o.pathFile throws error
  File.lstatSync( _.pathDir( o.pathFile ) );

  try
  {
    stat = File.lstatSync( o.pathFile );
  }
  catch ( err ) {};

  if( o.force )
  {
    if( stat && stat.isFile() )
    {
      File.unlinkSync( o.pathFile );
    }
  }

  File.mkdirSync( o.pathFile );

  con.give();
}
else
{
  File.lstat( _.pathDir( o.pathFile ), function( err, stats )
  {
     if( err )
    con._giveWithError( err, stats )
  } );

  try
  {
    stat = File.lstatSync( o.pathFile );
  }
  catch ( err ) {};

  if( o.force )
  {
    if( stat && stat.isFile() )
    {
      File.unlink( o.pathFile, function( err, data )
      {
        if( err )
        con._giveWithError( err, data )
      } );
    }
  }

  File.mkdir( o.pathFile, function( err, data )
  {
    if( err )
    con._giveWithError( err, data );
  } );
}

 return con;
}

directoryMake.defaults =
{
  pathFile : null,
  force : 0,
  sync : 0,
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
  fileStat : fileStat,


  // write

  fileTimeSet : fileTimeSet,
  fileCopy : fileCopy,
  fileRename : fileRename,

  fileDelete : fileDelete,

  directoryMake : directoryMake,
  linkSoftMake : linkSoftMake,


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
_.FileProvider.HardDrive = Self;

if( typeof module !== 'undefined' )
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
