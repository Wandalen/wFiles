( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

var _ = _global_.wTools;
_.assert( !_.FileRecord );
// debugger;
// if( _.FileRecord )
// return;

//

/*

- rethink real field
- remove isDirectory field

*/

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecord( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  {
    _.assert( arguments.length === 1 );
    return o;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileRecord';

//

function init( filePath, o )
{
  var record = this;

  _.instanceInit( record );

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordOptions ) || arguments[ 1 ] instanceof _.FileRecordOptions );
  _.assert( _.strIs( filePath ),'_fileRecord expects string ( filePath ), but got',_.strTypeOf( filePath ) );

  if( _.FileProvider.Hub && o.fileProvider instanceof _.FileProvider.Hub )
  {
    o.fileProvider =  o.fileProvider.providerForPath( filePath );
    filePath = o.fileProvider.localFromUrl( filePath );
  }

  if( o === undefined )
  {
    debugger;
    o = new _.FileRecordOptions();
  }
  else if( _.mapIs( o ) )
  {
    o = new _.FileRecordOptions( o );
  }

  if( o.strict )
  Object.preventExtensions( record );

  return record._fileRecord( filePath,o );
}

//

function clone( src )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( src === undefined || _.strIs( src ) );

  var result = _.FileRecord( src,
  {
    fileProvider : self.fileProvider,
    relative : self.base,
  });

  return result;
}

//

function _fileRecordAdjust( filePath, o )
{
  var record = this;
  var isAbsolute = _.pathIsAbsolute( filePath );
  if( !isAbsolute )
  _.assert( _.strIs( o.relative ) || _.strIs( o.dir ),'( FileRecordOptions ) expects ( dir ) or ( relative ) option or absolute path' );

  /* path */

  if( !isAbsolute )
  if( o.dir )
  filePath = _.pathJoin( o.dir,filePath );
  else if( o.relative )
  filePath = _.pathJoin( o.relative,filePath );
  else if( !_.pathIsAbsolute( filePath ) )
  _.assert( 0,'FileRecord expects ( dir ) or ( relative ) option or absolute path' );

  filePath = _.pathNormalize( filePath );

  /* record */

  record.base = o.relative;
  record.fileProvider = o.fileProvider;

  if( o.relative )
  record.relative = _.urlRelative( o.relative,filePath );
  else
  record.relative = _.pathName({ path : filePath, withExtension : 1 });

  _.assert( record.relative[ 0 ] !== '/' );

  record.relative = _.pathDot( record.relative );

  if( o.relative )
  record.absolute = _.pathResolve( o.relative,record.relative );
  else
  record.absolute = filePath;

  record.absolute = _.pathNormalize( record.absolute );

  _.assert( o.originPath );

  record.full = o.originPath + record.absolute;

  record.real = record.absolute;

  return record;
}

//

function from( src )
{
  return Self( src );
}

//

function manyFrom( src )
{
  var result = [];

  _.assert( arguments.length === 1 );
  _.assert( _.arrayIs( src ) );

  for( var s = 0 ; s < src.length ; s++ )
  result[ s ] = Self.from( src[ s ] );

  return result;
}

//

function _fileRecord( filePath,o )
{

  o = o || Object.create( null );

  if( !o.fileProvider )
  o.fileProvider = record.fileProvider;

  o = _.FileRecordOptions( o );

  _.assert( _.strIs( filePath ),'_fileRecord :','( filePath ) must be a string' );
  _.assert( arguments.length === 2 );
  _.assert( o instanceof _.FileRecordOptions,'_fileRecord expects instance of ( FileRecordOptions )' );
  _.assert( o.fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );

  var record = this._fileRecordAdjust( filePath, o );

  record.exts = _.pathExts( record.absolute );
  record.ext = _.pathExt( record.absolute ).toLowerCase();
  record.extWithDot = record.ext ? '.' + record.ext : '';

  record.dir = _.pathDir( record.absolute );
  record.name = _.pathName( record.absolute );
  record.nameWithExt = record.name + record.extWithDot;

  /* */

  _.assert( record.inclusion === null );

  /* */

  record._statRead( o );

  /* */

  _.assert( record.nameWithExt.indexOf( '/' ) === -1,'something wrong with filename' );

  return record;
}

_.accessorForbid( _fileRecord, { defaults : 'defaults' } );

//

function _statRead( o )
{
  var record = this;

  o = o || Object.create( null );

  if( !o.fileProvider )
  o.fileProvider = record.fileProvider;

  o = _.FileRecordOptions( o );

  _.assert( o instanceof _.FileRecordOptions,'_fileRecord expects instance of ( FileRecordOptions )' );
  _.assert( o.fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  /* textlink */

  if( o.resolvingTextLink ) try
  {
    record.real = _.pathResolveTextLink( record.real );
  }
  catch( err )
  {
    record.inclusion = false;
  }

  /* softlink */

  // debugger
  // if( o.resolvingSoftLink ) try
  // {
  //   record.real = o.fileProvider.pathResolveSoftLink( record.real );
  // }
  // catch( err )
  // {
  //   record.inclusion = false;
  // }

  /* */

  if( !o.stating )
  record.inclusion = false;

  if( record.inclusion !== false )
  try
  {

    record.stat = record.fileProvider.fileStat
    ({
      filePath : record.real,
      resolvingSoftLink : o.resolvingSoftLink,
      sync : o.sync,
    });

    if( !o.sync )
    debugger;
    if( !o.sync )
    record.stat.ifNoErrorThen( ( arg ) => record.stat = arg );

  }
  catch( err )
  {

    record.inclusion = false;
    if( record.fileProvider.fileStat( record.real ) )
    {
      throw _.err( 'Cant read :',record.real,'\n',err );
    }

  }

  /* */

  // _.assert( o.fileProvider );
  // if( o.fileProvider.safe || o.fileProvider.safe === undefined )
  // {
  //
  //   if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
  //   throw _.err( 'Unsafe record, unknown kind of file :',record.absolute );
  //
  // }

  if( record.stat instanceof _.Consequence )
  record.stat.doThen( function( err,arg ) {
    debugger;
    record._statAnalyze( o );
    this.give( err,arg );
  });
  else
  record._statAnalyze( o );

  return record;
}

//

function _statAnalyze( o )
{
  var record = this;

  _.assert( o instanceof _.FileRecordOptions,'_fileRecord expects instance of ( FileRecordOptions )' );
  _.assert( o.fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );
  // _.assert( record.stat );
  _.assert( arguments.length === 1 );

  /* */

  if( !record.stat )
  {
    record.inclusion = false;
  }
  // if( record.stat )
  // {
  //   // _.assert( record.stat.isDirectory );
  //   if( record.stat.isDirectory )
  //   record.isDirectory = record.stat.isDirectory();
  //   else
  //   record.isDirectory = false;
  // }

  /* */

  if( o.fileProvider.verbosity )
  {
    if( !record.stat )
    debugger;
    if( !record.stat )
    logger.log( '!','Cant access file :',record.absolute );
  }

  /* */

  if( record.inclusion === null )
  record.inclusion = true;  /* xxx */

  /* age */

  var time;
  if( record.inclusion === true )
  {
    time = record.stat.mtime;
    if( record.stat.birthtime > record.stat.mtime )
    time = record.stat.birthtime;
  }

  if( record.inclusion === true )
  if( o.notOlder !== null )
  {
    debugger;
    record.inclusion = time >= o.notOlder;
  }

  if( record.inclusion === true )
  if( o.notNewer !== null )
  {
    debugger;
    record.inclusion = time <= o.notNewer;
  }

  if( record.inclusion === true )
  if( o.notOlderAge !== null )
  {
    debugger;
    record.inclusion = _.timeNow() - o.notOlderAge - time <= 0;
  }

  if( record.inclusion === true )
  if( o.notNewerAge !== null )
  {
    debugger;
    record.inclusion = _.timeNow() - o.notNewerAge - time >= 0;
  }

  /* */

  if( record.inclusion !== false )
  {

    _.assert( o.exclude === undefined, 'o.exclude is deprecated, please use mask.excludeAny' );
    _.assert( o.excludeFiles === undefined, 'o.excludeFiles is deprecated, please use mask.maskFiles.excludeAny' );
    _.assert( o.excludeDirs === undefined, 'o.excludeDirs is deprecated, please use mask.maskDirs.excludeAny' );

    var r = record.relative;

    if( record.relative === '.' )
    r = _.pathDot( record.nameWithExt );

    // if( !( record.relative !== '.' || !this._isDir() ) )
    // debugger;

    // what is this extra condition for???
    // if( record.relative !== '.' || !this._isDir() )

    if( this._isDir() )
    {
      if( record.inclusion && o.maskAll )
      record.inclusion = _.RegexpObject.test( o.maskAll,r );
      if( record.inclusion && o.maskDir )
      record.inclusion = _.RegexpObject.test( o.maskDir,r );
    }
    else
    {
      if( record.inclusion && o.maskAll )
      record.inclusion = _.RegexpObject.test( o.maskAll,r );
      if( record.inclusion && o.maskTerminal )
      record.inclusion = _.RegexpObject.test( o.maskTerminal,r );
    }

  }

  /* */

  if( o.fileProvider.safe || o.fileProvider.safe === undefined )
  {
    if( record.inclusion )
    if( !_.pathIsSafe( record.absolute ) )
    {
      debugger;
      throw _.err( 'Unsafe record :',record.absolute,'\nUse options ( safe:0 ) if intention was to access system files.' );
    }
    if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
    throw _.err( 'Unsafe record, unknown kind of file :',record.absolute );

  }

  /* */

  if( o.onRecord )
  {
    if( o.onRecord.length )
    debugger;

    _.assert( o.fileProvider );
    _.routinesCall( o,o.onRecord,[ record ] );

    // var onRecord = _.arrayAs( o.onRecord );
    // for( var r = 0 ; r < onRecord.length ; r++ )
    // onRecord[ r ].call( o.fileProvider,record );

  }

}

//

function changeExt( ext )
{
  var record = this;

  _.assert( arguments.length === 1 );

  var was = record.absolute;

  record.ext = ext;
  record.extWithDot = '.' + ext;

  record.relative = _.pathChangeExt( record.relative,ext );
  record.absolute = _.pathChangeExt( record.absolute,ext );
  record.nameWithExt = _.pathChangeExt( record.nameWithExt,ext );

  /*logger.log( 'pathChangeExt : ' + was + ' -> ' + record.absolute );*/

}

//

function hashGet()
{
  var record = this;

  _.assert( arguments.length === 0 );

  if( record.hash !== null )
  return record.hash;

  record.hash = record.fileProvider.fileHash
  ({
    filePath : record.absolute,
    verbosity : 0,
  });

  return record.hash;
}

//

function _isDir()
{
  var self = this;

  if( !self.stat )
  return false;

  // _.assert( _.routineIs( self.stat.isDirectory ) );

  if( !self.stat.isDirectory )
  return false;

  return self.stat.isDirectory();
}

// --
// statics
// --

function toAbsolute( record )
{

  if( record === undefined )
  record = this;

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  var result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

/**
 * Returns absolute path to file. Accepts file record object. If as argument passed string, method returns it.
 * @example
 * var pathStr = 'foo/bar/baz',
    fileRecord = FileRecord( pathStr );
   var path = wTools.pathGet( fileRecord ); // '/home/user/foo/bar/baz';
 * @param {string|wFileRecord} src file record or path string
 * @returns {string}
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If type of argument is not string or wFileRecord.
 * @method pathGet
 * @memberof wTools
 */

function pathGet( src )
{

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) )
  return src;
  else if( src instanceof _.FileRecord )
  return src.absolute;
  else _.assert( 0, 'pathGet : unexpected type of argument', _.strTypeOf( src ) );

}

//

function pathsGet( src )
{

  debugger;
  throw _.err( 'not tested' );
  _.assert( arguments.length === 1 );

  if( _.arrayIs( src ) )
  {
    var result = [];
    for( var s = 0 ; s < src.length ; s++ )
    result.push( pathGet( src[ s ] ) );
    return result;
  }

  return pathGet( src );
}

// --
//
// --

var Composes =
{

  relative : null,
  absolute : null,
  full : null,

  base : null,
  real : null,
  dir : null,

  exts : null,
  ext : null,
  extWithDot : null,
  name : null,
  nameWithExt : null,

  /* */

  // isDirectory : null,
  inclusion : null,

  hash : null,

}

var Aggregates =
{
  stat : null,
}

var Associates =
{
  fileProvider : null,
}

var Restricts =
{
}

var Statics =
{
  toAbsolute : toAbsolute,
  _fileRecordAdjust : _fileRecordAdjust,
  from : from,
  manyFrom : manyFrom,

  pathGet : pathGet,
  pathsGet : pathsGet,
}

var Globals =
{
  pathGet : pathGet,
  pathsGet : pathsGet,
}

var Forbids =
{
  path : 'path',
  file : 'file',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',
  safe : 'safe',
  isDirectory : 'isDirectory',
}

// --
// prototype
// --

var Proto =
{

  init : init,
  clone : clone,

  _fileRecord : _fileRecord,
  _statRead : _statRead,
  _statAnalyze : _statAnalyze,

  changeExt : changeExt,

  hashGet : hashGet,

  _isDir : _isDir,

  toAbsolute : toAbsolute,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.accessorForbid( Self.prototype,Forbids );
_.mapExtend( _,Globals );

//

if( _global_.wCopyable )
_.Copyable.mixin( Self );

//

if( typeof module !== 'undefined' )
{

  require( './FileRecordOptions.s' );

}

//

_.assert( !_global_.wFileRecord,'wFileRecord already defined' );
_[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
