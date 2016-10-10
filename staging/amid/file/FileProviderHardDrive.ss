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
  _.routineOptions( fileReadAct,o );

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  var handleBegin = function()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,{ transaction : o, encoder : encoder })

  }

  /* end */

  var handleEnd = function( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,{ data : data, transaction : o, encoder : encoder })

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

    if( encoder && encoder.onError )
    err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })

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

  if( o.sync )
  {

    result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );

    return handleEnd( result );
  }
  else
  {
    con = new wConsequence();

    File.readFile( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
    {

      if( err )
      return handleError( err );
      else
      return handleEnd( data );

    });

    return con;
  }

}

fileReadAct.defaults = DefaultsFor.fileReadAct;
fileReadAct.isOriginalReader = 1;

//

var fileStatAct = function( filePath )
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

  _.routineOptions( fileTimeSet,o );

  File.utimesSync( o.filePath, o.atime, o.mtime );

}

fileTimeSet.defaults = DefaultsFor.fileTimeSet;

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

  _.routineOptions( fileCopyAct,o );

  if( o.sync )
  {
    File.copySync( o.src, o.dst );
  }
  else
  {
    var con = new wConsequence();
    File.copy( o.src, o.dst, function( err, data )
    {
      //if( err )
      con._giveWithError( err, data );
    });
    return con;
  }

}

fileCopyAct.defaults = DefaultsFor.fileCopyAct;
//fileCopyAct.defaults.sync = 0;

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

  _.routineOptions( fileRenameAct,o );

  if( o.sync )
  {
    File.renameSync( o.src, o.dst );
  }
  else
  {
    var con = new wConsequence();
    File.rename( o.src, o.dst, function( err,data )
    {
      //if( err )
      con._giveWithError( err,data );
    } );
    return con;
  }

}

fileRenameAct.defaults = DefaultsFor.fileRenameAct;
//fileRenameAct.defaults.sync = 0;

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
   var con = wTools.fileDeleteAct( delOptions );

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
 * @method fileDeleteAct
 * @memberof wTools
 */

var fileDeleteAct = function( o )
{

  if( _.strIs( o ) )
  o = { pathFile : o };

  var o = _.routineOptions( fileDeleteAct,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

  if( _.files.usingReadOnly )
  return o.synce ? undefined : con.give();

  var stat;
  if( o.sync )
  {

    if( !o.force )
    {
      stat = self.fileStatAct( o.pathFile );
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

  }
  else
  {
    var con = new wConsequence();

    if( !o.force )
    {
      stat = self.fileStatAct( o.pathFile );
      if( !stat )
      return con.error( _.err( 'cant read ' + o.pathFile ) );
      if( stat.isSymbolicLink() )
      throw _.err( 'not tested' );
      if( stat.isDirectory() )
      File.rmdir( o.pathFile,function( err,data ){ con.give( err,data ) } );
      else
      File.unlink( o.pathFile,function( err,data ){ con.give( err,data ) } );
    }
    else
    {
      File.remove( o.pathFile,function( err,data ){ con.give( err,data ) } );
    }

    return con;
  }

}

fileDeleteAct.defaults = DefaultsFor.fileDeleteAct;

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

  _.routineOptions( fileTimeSet,o );

  var stat;

  debugger;
  throw _.err( 'not tested' );

  if( o.sync )
  {
    if( o.force )
    {
      var stat = _.fileStatAct( o.pathFile );
      if( stat && !stat.isDirectory() )
      {
        File.unlinkSync( o.pathFile );
      }
    }

    File.mkdirSync( o.pathFile );

    con.give();
  }
  else
  {
    var con = new wConsequence().give();

    if( o.force )
    {
      var stat = _.fileStatAct( o.pathFile );
      if( stat && !stat.isDirectory() )
      {
        File.unlink( o.pathFile, function( err ) {
          con.give( err,null );
        });
      }
    }

    con.ifNoErrorThen( function( data ) {

      File.mkdir( o.pathFile, function( err, data )
      {
        con.give( err, data );
      } );

    });

    return con;
  }

}

directoryMakeAct.defaults = DefaultsFor.directoryMakeAct;

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

  if( o.sync )
  {
    var result = File.readdirSync( o.pathFile );
    return result
  }
  else
  {
    throw _.err( 'not implemented' );
  }

  return result;
}

directoryReadAct.defaults = DefaultsFor.directoryReadAct;

//

var linkSoftMakeAct = function( o )
{

  if( _.strIs( o ) )
  o =
  {
    pathFile : arguments[ 0 ],
  }

  _.assert( arguments.length === 1 );
  _.routineOptions( linkSoftMakeAct,o );

  File.symlinkSync( o.src,o.dst );

}

linkSoftMakeAct.defaults =
{
  pathFile : null,
}

// --
// encoders
// --

var encoders = {};

encoders[ 'json' ] =
{

  onBegin : function( e )
  {
    throw _.err( 'not tested' );
    _.assert( e.transaction.encoding === 'json' );
    e.transaction.encoding = 'utf8';
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
    _.assert( e.transaction.encoding === 'arraybuffer' );
    e.transaction.encoding = 'buffer';
  },

  onEnd : function( e )
  {

    _.assert( _.bufferNodeIs( e.data ) );
    _.assert( !_.bufferIs( e.data ) );
    _.assert( !_.bufferRawIs( e.data ) );

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
  fileStatAct : fileStatAct,


  // write

  fileTimeSet : fileTimeSet,
  fileCopyAct : fileCopyAct,
  fileRenameAct : fileRenameAct,

  fileDeleteAct : fileDeleteAct,

  directoryMakeAct : directoryMakeAct,
  directoryReadAct : directoryReadAct,

  linkSoftMakeAct : linkSoftMakeAct,


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
