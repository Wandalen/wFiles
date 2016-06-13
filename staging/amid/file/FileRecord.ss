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

//

var _ = wTools;
var Parent = null;
var Self = function wFileRecord( options )
{
  if( !( this instanceof Self ) )
  if( options instanceof Self )
  return options;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function( file,options )
{
  var self = this;

/*
  _.mapExtendFiltering( _.filter.notAtomicCloningOwn(),self,Composes );

  if( options )
  self.copy( options );
*/

  //
  //if( arguments.length === 2 )
  //debugger;

  if( _.objectIs( file ) )
  {

    debugger;
    throw _.err( 'not tested' );
    if( options )
    throw _.err( 'not tested' );
    _.assert( arguments.length === 1,'not tested' );
    _.mapExtend( self,file );
    return;
  }

  var options = options || {};
  var defaults =
  {
    dir : null,
    relative : null,
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapOnly( options,_fileRecord.defaults );

  if( !_.strIs( file ) )
  throw _.err( 'FileRecord :','file argument must be a string' );

  file = _.pathNormalize( file );

  if( options.dir )
  {
    if( options.dir instanceof Self )
    options.dir = options.dir.absolute;
    options.dir = _.pathNormalize( options.dir );
  }

  if( options.relative )
  {
    if( options.relative instanceof Self )
    options.relative = options.relative.absolute;
    options.relative = _.pathNormalize( options.relative );
  }

  if( !options.relative )
  if( options.dir )
  options.relative = options.dir;
  else
  options.relative = _.pathDir( file );

/*
  if( options.dir === undefined ) options.dir = Path.dirname( file );
  else if( _.objectIs( options.dir ) ) options.dir = _.pathNormalize( options.dir.absolute );
  else options.dir = _.pathNormalize( options.dir );

  if( options.relative === undefined ) options.relative = options.dir;
  else if( _.objectIs( options.relative ) ) options.relative = _.pathNormalize( options.relative.absolute );
  else options.relative = _.pathNormalize( options.relative );
*/

  //file = _.pathRelative( options.dir,file );

  return self._fileRecord( file,options );
}

//

var _fileRecord = function( file,options )
{
  var self = this;
  var record = this;
  var pathFile;

  if( !_.strIs( file ) )
  throw _.err( '_fileRecord :','file must be string' );

  if( !_.strIs( options.relative ) && !_.strIs( options.dir ) )
  throw _.err( '_fileRecord :','expects options.relative or options.dir' );

  _.assertMapOnly( options,_fileRecord.defaults );
  _.assert( arguments.length === 2 );

  //record.constructor = null;
  record.file = file;

  if( options.dir )
  pathFile = _.pathJoin( options.dir,record.file );
  else
  pathFile = _.pathJoin( options.relative,record.file );

  pathFile = _.pathNormalize( pathFile );

  record.relative = _.pathRelative( options.relative,pathFile );

  if( record.relative[ 0 ] !== '.' )
  record.relative = './' + record.relative;

  record.absolute = Path.resolve( options.relative,record.relative );
  record.absolute = _.pathNormalize( record.absolute );

  record.ext = _.pathExt( record.absolute );
  record.name = _.pathName( record.absolute );
  record.file = _.pathName( record.absolute,{ withoutExtension : false } );
  record.dir = _.pathDir( record.absolute );

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

    _.assert( options.exclude === undefined, 'options.exclude is deprecated, please use mask.excludeAny' );
    _.assert( options.excludeFiles === undefined, 'options.excludeFiles is deprecated, please use mask.maskFiles.excludeAny' );
    _.assert( options.excludeDirs === undefined, 'options.excludeDirs is deprecated, please use mask.maskDirs.excludeAny' );

    var pathFile = record.relative;
    if( record.relative === '.' )
    pathFile = record.file;

    if( record.relative !== '.' || !record.isDirectory )
    if( record.isDirectory )
    {
      if( record.inclusion && options.maskAnyFile ) record.inclusion = _.regexpObjectTest( options.maskAnyFile,pathFile );
      if( record.inclusion && options.maskDir ) record.inclusion = _.regexpObjectTest( options.maskDir,pathFile );
    }
    else
    {
      if( record.inclusion && options.maskAnyFile ) record.inclusion = _.regexpObjectTest( options.maskAnyFile,pathFile );
      if( record.inclusion && options.maskStoreFile ) record.inclusion = _.regexpObjectTest( options.maskStoreFile,pathFile );
    }

  }

  //

  _.assert( record.file.indexOf( '/' ) === -1,'something wrong with filename' );

  if( options.safe || options.safe === undefined )
  if( record.stat && record.inclusion )
  if( !_.pathIsSafe( record.absolute ) )
  {
    debugger;
    throw _.err( 'Unsafe record :',record.absolute );
  }

  if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
  throw _.err( 'Unsafe record ( unknown kind of file ) :',record.absolute );

  //

  if( options.onRecord )
  {
    var onRecord = _.arrayAs( options.onRecord );
    for( var o = 0 ; o < onRecord.length ; o++ )
    onRecord[ o ].call( record );
  }

  //

  if( options.verboseCantAccess )
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

_.accessorForbid( Self.prototype,{
});

//

_.mapExtendFiltering( _.filter.atomicOwn(),Self.prototype,Composes );

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

_global_.wFileRecord = wTools.FileRecord = Self;
return Self;

})();
