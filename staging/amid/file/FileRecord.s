( function _FileRecord_s_() {

'use strict'; //

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' )

  var File = require( 'fs-extra' );

}

if( _global_.wFileRecord )
return;

/*

!!! add test case to avoid

var r = _.FileRecord( "/pro/app/file/deck/car", { relative : '/pro/app' } );
expected r.absolute === "/pro/app/file/deck/car"
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

function init( o )
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
    var o = Object.create( null );
    o.pathFile = arguments[ 0 ];
  }

  var o = o || Object.create( null );
  // var defaults =
  // {
  //   dir : null,
  //   relative : null,
  // }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapHasOnly( o,_fileRecord.defaults );

  if( !_.strIsNotEmpty( o.pathFile ) )
  throw _.err( 'FileRecord :','expects string o.pathFile' );

  o.pathFile = _.pathRegularize( o.pathFile );

  if( o.dir )
  {
    if( o.dir instanceof Self )
    o.dir = o.dir.absolute;
    o.dir = _.pathRegularize( o.dir );
  }

  if( o.relative )
  {
    if( o.relative instanceof Self )
    o.relative = o.relative.absolute;
    o.relative = _.pathRegularize( o.relative );
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

// init.defaults =
// {
//   dir : null,
//   relative : null,
// }

//

function _fileRecord( o )
{
  var self = this;
  var record = this;

  _.assert( _.strIs( o.pathFile ),'_fileRecord :','o.pathFile must be string' );
  _.assert( _.strIs( o.relative ) || _.strIs( o.dir ),'_fileRecord :','expects o.relative or o.dir' );
  _.routineOptions( _fileRecord,o );
  _.assert( arguments.length === 1 );
  _.assert( o.fileProvider instanceof _.FileProvider.Abstract,'FileRecords expects instance of FileProvider' );

  /* path */

  if( o.dir )
  o.pathFile = _.pathJoin( o.dir,o.pathFile );
  else if( o.relative )
  o.pathFile = _.pathJoin( o.relative,o.pathFile );
  else if( !_.pathIsAbsolute( o.pathFile ) )
  throw _.err( 'FileRecord needs dir parameter or relative parameter or absolute path' );

  o.pathFile = _.pathRegularize( o.pathFile );

  /* record */

  record.fileProvider = o.fileProvider;
  record.relative = _.pathRelative( o.relative,o.pathFile );

  if( record.relative[ 0 ] !== '.' )
  record.relative = './' + record.relative;

  record.absolute = _.pathResolve( o.relative,record.relative );
  record.absolute = _.pathRegularize( record.absolute );
  record.real = record.absolute;

  record.ext = _.pathExt( record.absolute );
  record.extWithDot = record.ext ? '.' + record.ext : '';
  record.name = _.pathName( record.absolute );
  record.dir = _.pathDir( record.absolute );
  record.file = _.pathName({ path : record.absolute, withExtension : 1 });

  /* */

  _.accessorForbid( record,{ path :'path' },'FileRecord :', 'record.path is deprecated' );
  _.assert( record.inclusion === undefined );

  // if( 0 )
  // if( record.absolute.indexOf( '.scenario.coffee' ) !== -1 )
  // {
  //   console.log( 'record.absolute :',record.absolute );
  //   console.log( 'record.relative :',record.relative );
  // //   console.log( 'o.pathFile :',o.pathFile );
  // //   console.log( 'o.usingResolvingTextLink :',o.usingResolvingTextLink );
  //   debugger;
  // }

  /* */

  if( o.usingResolvingTextLink ) try
  {
    record.real = _.pathResolveTextLink( record.real );
  }
  catch( err )
  {
    record.inclusion = false;
  }

  /* */

  if( record.inclusion !== false )
  try
  {
    record.stat = o.fileProvider.fileStat({ pathFile : record.real, resolvingSymbolLink : o.usingResolvingLink });
  }
  catch( err )
  {

    record.inclusion = false;
    if( o.fileProvider.fileStat( record.real ) )
    {
      throw _.err( 'Cant read :',record.real );
    }

  }

  /* */

  if( record.stat )
  record.isDirectory = record.stat.isDirectory(); /* isFile */

  // if( record.relative.indexOf( 'file' ) !== -1 )
  // {
  //   console.log( 'record.relative :',record.relative );
  //   debugger;
  // }

  /* */

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

  /* */

  // if( record.inclusion === true )
  // {
  //
  //   if( record.stat. )
  //
  // }

  /* */

  _.assert( record.file.indexOf( '/' ) === -1,'something wrong with filename' );

  if( o.safe || o.safe === undefined )
  if( record.stat && record.inclusion )
  if( !_.pathIsSafe( record.absolute ) )
  {
    debugger;
    throw _.err( 'Unsafe record :',record.absolute,'\nUse options ( safe:0 ) if intention was to access system files.' );
  }

  if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
  throw _.err( 'Unsafe record ( unknown kind of file ) :',record.absolute );

  /* */

  if( o.onRecord )
  {
    var onRecord = _.arrayAs( o.onRecord );
    for( var o = 0 ; o < onRecord.length ; o++ )
    onRecord[ o ].call( record );
  }

  /* */

  if( o.verbosity )
  {

    if( !record.stat )
    logger.log( '!','cant access file :',record.absolute );

  }

  return record;
}

_fileRecord.defaults =
{
  fileProvider : null,

  pathFile : null,
  dir : null,
  relative : null,

  maskAll : null,
  maskTerminal : null,
  maskDir : null,
  onRecord : null,

  safe : 1,
  verbosity : 0,

  usingResolvingLink : 0,
  usingResolvingTextLink : 0,
}

//

function fileRecords( records,o )
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

function fileRecordsFiltered( records,o )
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

function fileRecordToAbsolute( record )
{

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  var result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

function changeExt( ext )
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

  fileProvider : null,

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

var Statics =
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
  Statics : Statics,

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

_.assert( !_global_.wFileRecord,'wFileRecord already defined' );

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

_global_.wFileRecord = wTools.FileRecord = Self;
return Self;

})();
