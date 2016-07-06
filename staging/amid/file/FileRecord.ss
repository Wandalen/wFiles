(function(){

'use strict';

if( typeof module !== 'undefined' )
{

  try
  {
    require( 'wTools' );
  }
  catch( err )
  {
    require( '../../abase/wTools.s' );
  }

  var Path = require( 'path' );
  var File = require( 'fs-extra' );

}

/*

!!! add test case to avoid

var r = _.FileRecord( "/pro/app/file/model/car", { relative : '/pro/app' } );
expected r.absolute === "/pro/app/file/model/car"
got r.absolute === "/pro/app/car"
gave spoiled absolute path

*/

//

var _ = wTools;
var Parent = null;
var Self = function wFileRecord( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function( pathFile,o )
{
  var self = this;

/*
  _.mapExtendFiltering( _.filter.notAtomicCloningOwn(),self,Composes );

  if( o )
  self.copy( o );
*/

  //
  //if( arguments.length === 2 )
  //debugger;

  if( _.objectIs( pathFile ) )
  {
    debugger;
    _.assert( arguments.length === 1 );
    o = pathFile;
    pathFile = o.pathFile;
    delete o.pathFile;
  }

  var o = o || {};
  var defaults =
  {
    dir : null,
    relative : null,
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapOnly( o,_fileRecord.defaults );

  if( !_.strIsNotEmpty( pathFile ) )
  throw _.err( 'FileRecord :','pathFile argument must be a string' );

  pathFile = _.pathNormalize( pathFile );

  if( o.dir )
  {
    if( o.dir instanceof Self )
    o.dir = o.dir.absolute;
    o.dir = _.pathNormalize( o.dir );
  }

  if( o.relative )
  {
    if( o.relative instanceof Self )
    o.relative = o.relative.absolute;
    o.relative = _.pathNormalize( o.relative );
  }

  if( !o.relative )
  if( o.dir )
  {
    o.relative = o.dir;
  }
  else
  {
    if( !_.pathIsAbsolute( pathFile ) )
    throw _.err( 'FileRecord needs dir parameter or relative parameter or absolute path' );
    o.relative = _.pathDir( pathFile );
  }

  if( o.dir )
  if( !_.pathIsAbsolute( o.dir ) )
  throw _.err( 'o.dir should be absolute path' );

  if( o.relative )
  if( !_.pathIsAbsolute( o.relative ) )
  throw _.err( 'o.relative should be absolute path' );

  return self._fileRecord( pathFile,o );
}

//

var _fileRecord = function( pathFile,o )
{
  var self = this;
  var record = this;

  if( !_.strIs( pathFile ) )
  throw _.err( '_fileRecord :','pathFile must be string' );

  if( !_.strIs( o.relative ) && !_.strIs( o.dir ) )
  throw _.err( '_fileRecord :','expects o.relative or o.dir' );

  _.assertMapOnly( o,_fileRecord.defaults );
  _.assert( arguments.length === 2 );

  //record.constructor = null;

  //record.file = pathFile;
  //record.file = _.pathName( _.pathNormalize( pathFile ), { withoutExtension : false } );
  //record.file = _.pathName( pathFile,{ withoutExtension : false } );;

  // !!! did not work :
  // var r = _.FileRecord( "/pro/app/file/model/car", { relative : '/pro/app' } );

  if( o.dir )
  pathFile = _.pathJoin( o.dir,pathFile );
  else if( o.relative )
  pathFile = _.pathJoin( o.relative,pathFile );
  else if( !_.pathIsAbsolute( pathFile ) )
  throw _.err( 'FileRecord needs dir parameter or relative parameter or absolute path' );

  pathFile = _.pathNormalize( pathFile );

  record.relative = _.pathRelative( o.relative,pathFile );

  if( record.relative[ 0 ] !== '.' )
  record.relative = './' + record.relative;

  record.absolute = Path.resolve( o.relative,record.relative );
  record.absolute = _.pathNormalize( record.absolute );

  record.ext = _.pathExt( record.absolute );
  record.extWithDot = record.ext ? '.' + record.ext : '';
  record.name = _.pathName( record.absolute );
  record.dir = _.pathDir( record.absolute );
  record.file = _.pathName( record.absolute,{ withoutExtension : false } );

  //

  _.accessorForbid( record,{ path :'path' },'FileRecord :', 'record.path is deprecated' );

  //

  try
  {
    record.stat = File.statSync( pathFile );
  }
  catch( err )
  {
    try
    {
      record.stat = File.lstatSync( pathFile );
    }
    catch( err )
    {
      record.inclusion = false;
      if( File.existsSync( pathFile ) )
      {
        debugger;
        throw _.err( 'cant read :',pathFile );
      }
    }
  }

  if( record.stat )
  record.isDirectory = record.stat.isDirectory(); /* isFile */

  //

/*
  if( record.relative.indexOf( 'FileCommon' ) !== -1 )
  {
    console.log( 'record.relative :',record.relative );
    debugger;
  }
*/

  //

  if( record.inclusion === undefined )
  {

    record.inclusion = true;

    _.assert( o.exclude === undefined, 'o.exclude is deprecated, please use mask.excludeAny' );
    _.assert( o.excludeFiles === undefined, 'o.excludeFiles is deprecated, please use mask.maskFiles.excludeAny' );
    _.assert( o.excludeDirs === undefined, 'o.excludeDirs is deprecated, please use mask.maskDirs.excludeAny' );

    var pathFile = record.relative;
    if( record.relative === '.' )
    pathFile = record.file;

    if( record.relative !== '.' || !record.isDirectory )
    if( record.isDirectory )
    {
      if( record.inclusion && o.maskAnyFile ) record.inclusion = _.regexpObjectTest( o.maskAnyFile,pathFile );
      if( record.inclusion && o.maskDir ) record.inclusion = _.regexpObjectTest( o.maskDir,pathFile );
    }
    else
    {
      if( record.inclusion && o.maskAnyFile ) record.inclusion = _.regexpObjectTest( o.maskAnyFile,pathFile );
      if( record.inclusion && o.maskStoreFile ) record.inclusion = _.regexpObjectTest( o.maskStoreFile,pathFile );
    }

  }

  //

  _.assert( record.file.indexOf( '/' ) === -1,'something wrong with filename' );

  if( o.safe || o.safe === undefined )
  if( record.stat && record.inclusion )
  if( !_.pathIsSafe( record.absolute ) )
  {
    debugger;
    throw _.err( 'Unsafe record :',record.absolute );
  }

  if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
  throw _.err( 'Unsafe record ( unknown kind of file ) :',record.absolute );

  //

  if( o.onRecord )
  {
    var onRecord = _.arrayAs( o.onRecord );
    for( var o = 0 ; o < onRecord.length ; o++ )
    onRecord[ o ].call( record );
  }

  //

  if( o.verboseCantAccess )
  {

    if( !record.stat )
    logger.log( '!','cant access file :',record.absolute );

  }

  return record;
}

_fileRecord.defaults =
{
  dir : null,
  relative : null,
  maskAnyFile : null,
  maskStoreFile : null,
  maskDir : null,
  onRecord : null,

  safe : 1,
  verboseCantAccess : 0,
}

//

var fileRecords = function( records,options )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.strIs( records ) || _.arrayIs( records ) || _.objectIs( records ) );

  if( !_.arrayIs( records ) )
  records = [ records ];

  for( var r = 0 ; r < records[ r ] ; r++ )
  {

    if( _.strIs( records[ r ] ) )
    records[ r ] = Self( records[ r ],options );

  }

  /**/

  records = records.map( function( record )
  {

    if( _.strIs( record ) )
    return Self( record,options );
    else if( _.objectIs( record ) )
    return record;
    else throw _.err( 'expects record or path' );

  });

  return records;
}

fileRecords.defaults = _fileRecord.defaults;

//

var fileRecordsFiltered = function( records,options )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var records = fileRecords( records );

  records = records.filter( function( record )
  {

    return record.inclusion && record.stat;

  });

  return records;
}

fileRecordsFiltered.defaults = _fileRecord.defaults;

//

var fileRecordToAbsolute = function( record )
{

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  var result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

// --
//
// --

var Composes =
{

  relative : null,
  absolute : null,

  dir : null,
  safe : true,
  maskAnyFile : null,
  maskStoreFile : null,
  maskDir : null,
  onRecord : null,

}

var Aggregates =
{

  /* derived */

  ext : null,
  name : null,
  file : null,

}

// --
// prototype
// --

var Proto =
{

  init : init,

  _fileRecord : _fileRecord,
  fileRecordToAbsolute : fileRecordToAbsolute,

  fileRecords : fileRecords,
  fileRecordsFiltered : fileRecordsFiltered,

  /**/

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,

};

//

var Static =
{
}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
  static : Static,
});

//

if( _global_.wCopyable )
wCopyable.mixin( Self.prototype );

//

_.accessorForbid( Self.prototype,
{
});

//

_.mapExtendFiltering( _.filter.atomicSrcOwn(),Self.prototype,Composes );

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

_global_.wFileRecord = wTools.FileRecord = Self;
return Self;

})();
