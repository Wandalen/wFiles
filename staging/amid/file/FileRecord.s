( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
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

var init = function( o )
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( arguments.length === 2 )
  {
    o = arguments[ 1 ];
    o.pathFile = arguments[ 0 ];
  }

  if( _.strIs( o ) )
  {
    o = { pathFile : o };
  }

  var o = o || {};
  var defaults =
  {
    dir : null,
    relative : null,
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapHasOnly( o,_fileRecord.defaults );

  if( !_.strIsNotEmpty( o.pathFile ) )
  throw _.err( 'FileRecord :','expects string o.pathFile' );

  o.pathFile = _.pathNormalize( o.pathFile );

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
    if( !_.pathIsAbsolute( o.pathFile ) )
    throw _.err( 'FileRecord needs dir parameter or relative parameter or absolute path' );
    o.relative = _.pathDir( o.pathFile );
  }

  if( o.dir )
  if( !_.pathIsAbsolute( o.dir ) )
  throw _.err( 'o.dir should be absolute path',o.dir );

  if( o.relative )
  if( !_.pathIsAbsolute( o.relative ) )
  throw _.err( 'o.relative should be absolute path',o.relative );

  return self._fileRecord( o );
}

//

var _fileRecord = function( o )
{
  var self = this;
  var record = this;

  if( !_.strIs( o.pathFile ) )
  throw _.err( '_fileRecord :','o.pathFile must be string' );

  if( !_.strIs( o.relative ) && !_.strIs( o.dir ) )
  throw _.err( '_fileRecord :','expects o.relative or o.dir' );

  _.routineOptions( _fileRecord,o );
  _.assert( arguments.length === 1 );

  /* path */

  if( o.dir )
  o.pathFile = _.pathJoin( o.dir,o.pathFile );
  else if( o.relative )
  o.pathFile = _.pathJoin( o.relative,o.pathFile );
  else if( !_.pathIsAbsolute( o.pathFile ) )
  throw _.err( 'FileRecord needs dir parameter or relative parameter or absolute path' );

  o.pathFile = _.pathNormalize( o.pathFile );

  /* record */

  record.relative = _.pathRelative( o.relative,o.pathFile );

  if( record.relative[ 0 ] !== '.' )
  record.relative = './' + record.relative;

  record.absolute = Path.resolve( o.relative,record.relative );
  record.absolute = _.pathNormalize( record.absolute );
  record.real = record.absolute;

  //console.log( 'record.absolute :',record.absolute );

  record.ext = _.pathExt( record.absolute );
  record.extWithDot = record.ext ? '.' + record.ext : '';
  record.name = _.pathName( record.absolute );
  record.dir = _.pathDir( record.absolute );
  record.file = _.pathName( record.absolute,{ withoutExtension : false } );

  //

  // if( o.usingResolvingTextLink )
  // {
  //   o.pathFile = _.pathResolveTextLink( o.pathFile );
  //   record.absolute = _.pathNormalize( o.pathFile );
  // }

  //

  _.accessorForbid( record,{ path :'path' },'FileRecord :', 'record.path is deprecated' );

  // if( record.relative.indexOf( 'include' ) !== -1 )
  // {
  //   console.log( 'record.relative :',record.relative );
  //   console.log( 'o.pathFile :',o.pathFile );
  //   console.log( 'o.usingResolvingTextLink :',o.usingResolvingTextLink );
  //   debugger;
  // }

  //

  if( o.usingResolvingTextLink )
  {
    record.real = _.pathResolveTextLink( record.real );
  }

  try
  {
    if( o.usingResolvingLink )
    record.stat = File.statSync( record.real );
    else
    record.stat = File.lstatSync( record.real );
  }
  catch( err )
  {

    record.inclusion = false;
    if( File.existsSync( record.real ) )
    {
      debugger;
      throw _.err( 'cant read :',record.real );
    }

  }

  if( record.stat )
  record.isDirectory = record.stat.isDirectory(); /* isFile */

  //
/*
  if( record.relative.indexOf( 'MasterDependencies' ) !== -1 && o.maskTerminal.includeAll.length > 0 )
  {
    console.log( 'record.relative :',record.relative );
    console.log( 'o.maskTerminal :',_.toStr( o.maskTerminal ) );
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

    var r = record.relative;
    if( record.relative === '.' )
    r = record.file;

    if( record.relative !== '.' || !record.isDirectory )
    if( record.isDirectory )
    {
      if( record.inclusion && o.maskAll ) record.inclusion = _.RegexpObject.test( o.maskAll,r );
      if( record.inclusion && o.maskDir ) record.inclusion = _.RegexpObject.test( o.maskDir,r );
    }
    else
    {
      if( record.inclusion && o.maskAll ) record.inclusion = _.RegexpObject.test( o.maskAll,r );
      if( record.inclusion && o.maskTerminal ) record.inclusion = _.RegexpObject.test( o.maskTerminal,r );
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

  if( o.usingLogging )
  {

    if( !record.stat )
    logger.log( '!','cant access file :',record.absolute );

  }

  //

  // debugger;
  // console.log( 'record',_.toStr( record,{ levels : 3 } ) );
  // debugger;

  return record;
}

_fileRecord.defaults =
{
  pathFile : null,
  dir : null,
  relative : null,

  maskAll : null,
  maskTerminal : null,
  maskDir : null,
  onRecord : null,

  safe : 1,
  usingLogging : 0,

  usingResolvingLink : 0,
  usingResolvingTextLink : 0,
}

//

var fileRecords = function( records,o )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.strIs( records ) || _.arrayIs( records ) || _.objectIs( records ) );

  if( !_.arrayIs( records ) )
  records = [ records ];

  /**/

  for( var r = 0 ; r < records.length ; r++ )
  {

    if( _.strIs( records[ r ] ) )
    records[ r ] = Self( records[ r ],o );

  }

  /**/

  records = records.map( function( record )
  {

    if( _.strIs( record ) )
    return Self( record,o );
    else if( _.objectIs( record ) )
    return record;
    else throw _.err( 'expects record or path' );

  });

  return records;
}

fileRecords.defaults = _fileRecord.defaults;

//

var fileRecordsFiltered = function( records,o )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var records = fileRecords( records,o );

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

//

var changeExt = function( ext )
{
  var record = this;

  _.assert( arguments.length === 1 );

  var was = record.absolute;

  record.relative = _.pathChangeExt( record.relative,ext );
  record.absolute = _.pathChangeExt( record.absolute,ext );

  record.ext = ext;
  record.extWithDot = '.' + ext;
  record.file = _.pathChangeExt( record.file,ext );

  /*logger.log( 'pathChangeExt : ' + was + ' -> ' + record.absolute );*/

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
  maskAll : null,
  maskTerminal : null,
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

var Associates =
{
}

var Restricts =
{
}

var Static =
{
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

  changeExt : changeExt,

  /**/

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Static : Static,

};

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

if( _global_.wCopyable )
wCopyable.mixin( Self );

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
