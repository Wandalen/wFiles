( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

var _ = _global_.wTools;
_.assert( !_.FileRecord );

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecord( c )
{
  if( !( this instanceof Self ) )
  if( c instanceof Self )
  {
    _.assert( arguments.length === 1 );
    return c;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileRecord';

//

function init( filePath, c )
{
  var record = this;

  _.instanceInit( record );

  if( c.strict )
  Object.preventExtensions( record );

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordContext ) || arguments[ 1 ] instanceof _.FileRecordContext );
  _.assert( _.strIs( filePath ),'expects string ( filePath ), but got',_.strTypeOf( filePath ) );

  if( c === undefined )
  {
    debugger;
    c = new _.FileRecordContext();
  }
  else if( _.mapIs( c ) )
  {
    if( !c.basePath && !c.dir )
    {
      // c.basePath = filePath;
      c.basePath = _.pathDir( filePath );
    }

    c = new _.FileRecordContext( c );
  }

  record.context = c;
  Object.freeze( record.context );

  // record.fileProvider = c.fileProvider;
  // record.fileProviderEffective = c.fileProvider;
  record.input = filePath;

  _.assert( record.inclusion === null );

  record.form();

  return record;
}

//

function form()
{
  var record = this;

  _.assert( Object.isFrozen( record.context ) )
  // _.assert( record.fileProvider );
  _.assert( record.context.fileProvider instanceof _.FileProvider.Abstract );
  _.assert( record.context.fileProviderEffective instanceof _.FileProvider.Abstract );
  _.assert( record.input );

  // record.fileProvider._fileRecordFormBegin( record );

  _.assert( _.strIs( record.input ),'{ record.input } must be a string' );
  _.assert( record.context instanceof _.FileRecordContext,'expects instance of { FileRecordContext }' );
  // _.assert( record.fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );

  // if( record.input === 'a' )
  // debugger;

  record._pathsForm();
  record._statRead();

  _.assert( record.nameWithExt.indexOf( '/' ) === -1,'something wrong with filename' );

  return record;
}

//

function clone( src )
{
  var record = this;
  var c = record.context;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( src === undefined || _.strIs( src ) );

  var result = _.FileRecord( src, c );

  // {
  //   // fileProvider : record.fileProvider,
  //   // context : record.context,
  //   // basePath : record.base,
  // });

  return result;
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

function _pathsForm()
{
  var record = this;
  var c = record.context;
  var fileProvider = c.fileProviderEffective;
  var filePath = record.input;

  _.assert( arguments.length === 0 );

  var isAbsolute = _.pathIsAbsolute( filePath );
  if( !isAbsolute )
  _.assert( _.strIs( c.basePath ) || _.strIs( c.dir ),'( FileRecordContext ) expects ( dir ) or ( basePath ) option or absolute path' );
  _.assert( c.basePath );

  /* path */

  if( !isAbsolute )
  if( c.dir )
  filePath = _.pathJoin( c.basePath, c.dir, filePath );
  else if( c.basePath )
  filePath = _.pathJoin( c.basePath,filePath );
  else if( !_.pathIsAbsolute( filePath ) )
  _.assert( 0,'FileRecordContext expects { dir } or { basePath } or absolute path' );

  filePath = _.pathNormalize( filePath );

  // if( filePath === '/dst/a1' )
  // debugger;

  /* record */

  // record.base = c.basePath;

  if( c.basePath )
  record.relative = _.urlRelative( c.basePath,filePath );
  else
  record.relative = _.pathName({ path : filePath, withExtension : 1 });

  _.assert( record.relative[ 0 ] !== '/' );

  record.relative = _.pathDot( record.relative );

  if( c.basePath )
  record.absolute = fileProvider.pathResolve( c.basePath,record.relative );
  else
  record.absolute = filePath;

  record.absolute = _.pathNormalize( record.absolute );

  c.fileProvider._fileRecordFormBegin( record );

  _.assert( c.originPath );

  record.full = c.originPath + record.absolute;
  record.real = record.absolute;
  record.absoluteEffective = record.absolute;

  /* */

  record.exts = _.pathExts( record.absolute );
  record.ext = _.pathExt( record.absolute ).toLowerCase();
  record.extWithDot = record.ext ? '.' + record.ext : '';

  record.dir = _.pathDir( record.absolute );
  record.name = _.pathName( record.absolute );
  record.nameWithExt = record.name + record.extWithDot;

  return record;
}

//

function _statRead()
{
  var record = this;
  var c = record.context;
  var fileProvider = c.fileProviderEffective;

  _.assert( c instanceof _.FileRecordContext,'expects instance of ( FileRecordContext )' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 );

  /* resolve link */

  try
  {

    record.real = fileProvider.pathResolveLink
    ({
      filePath : record.real,
      resolvingHardLink : null,
      resolvingSoftLink : c.resolvingSoftLink,
      resolvingTextLink : c.resolvingTextLink,
    });

    // record.real = fileProvider.pathResolveTextLink( record.real );
    record.absoluteEffective = record.real;

  }
  catch( err )
  {
    record.inclusion = false;
  }

  /* get stat */

  if( !c.stating )
  record.inclusion = false;

  if( record.inclusion !== false )
  try
  {

    record.stat = fileProvider.fileStat
    ({
      filePath : record.real,
      // resolvingSoftLink : c.resolvingSoftLink,
      resolvingSoftLink : 0,
      resolvingTextLink : 0,
      sync : c.sync,
    });

    if( !c.sync )
    debugger;
    if( !c.sync )
    record.stat.ifNoErrorThen( ( arg ) => record.stat = arg );

  }
  catch( err )
  {

    record.inclusion = false;
    if( fileProvider.fileStat( record.real ) )
    {
      throw _.err( 'Cant read :',record.real,'\n',err );
    }

  }

  /* analyze stat */

  if( record.stat instanceof _.Consequence )
  record.stat.doThen( function( err,arg )
  {
    debugger;
    record._statAnalyze();
    this.give( err,arg );
  });
  else
  {
    record._statAnalyze();
  }

  return record;
}

//

function _statAnalyze()
{
  var record = this;
  var c = record.context;
  var fileProvider = c.fileProviderEffective;

  _.assert( c instanceof _.FileRecordContext,'_fileRecord expects instance of ( FileRecordContext )' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 );

  /* */

  if( !record.stat )
  {
    record.inclusion = false;
  }

  /* */

  if( fileProvider.verbosity > 1 )
  if( !record.stat )
  {
    logger.log( '!','Cant access file :',record.absolute );
  }

  /* */

  if( record.inclusion === null )
  record.inclusion = true;

  /* age */

  if( !record._isDir() )
  {
    var time;
    if( record.inclusion === true )
    {
      time = record.stat.mtime;
      if( record.stat.birthtime > record.stat.mtime )
      time = record.stat.birthtime;
    }

    if( record.inclusion === true )
    if( c.notOlder !== null )
    {
      debugger;
      record.inclusion = time >= c.notOlder;
    }

    if( record.inclusion === true )
    if( c.notNewer !== null )
    {
      debugger;
      record.inclusion = time <= c.notNewer;
    }

    if( record.inclusion === true )
    if( c.notOlderAge !== null )
    {
      debugger;
      record.inclusion = _.timeNow() - c.notOlderAge - time <= 0;
    }

    if( record.inclusion === true )
    if( c.notNewerAge !== null )
    {
      debugger;
      record.inclusion = _.timeNow() - c.notNewerAge - time >= 0;
    }
  }

  /* */

  if( record.inclusion !== false )
  {

    _.assert( c.exclude === undefined, 'c.exclude is deprecated, please use mask.excludeAny' );
    _.assert( c.excludeFiles === undefined, 'c.excludeFiles is deprecated, please use mask.maskFiles.excludeAny' );
    _.assert( c.excludeDirs === undefined, 'c.excludeDirs is deprecated, please use mask.maskDirs.excludeAny' );

    var r = record.relative;

    if( record.relative === '.' )
    r = _.pathDot( record.nameWithExt );

    if( this._isDir() )
    {
      if( record.inclusion && c.maskAll )
      record.inclusion = c.maskAll.test( r );
      if( record.inclusion && c.maskDir )
      record.inclusion = c.maskDir.test( r );
    }
    else
    {
      if( record.inclusion && c.maskAll )
      record.inclusion = c.maskAll.test( r );
      if( record.inclusion && c.maskTerminal )
      record.inclusion = c.maskTerminal.test( r );
    }

  }

  /* */

  if( fileProvider.safe || fileProvider.safe === undefined )
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

  if( c.onRecord )
  {
    if( c.onRecord.length )
    debugger;

    _.assert( fileProvider );
    _.routinesCall( c,c.onRecord,[ record ] );

  }

  /* */

  record.context.fileProvider._fileRecordFormEnd( record );
}

//

function changeExt( ext )
{
  var record = this;

  _.assert( arguments.length === 1 );

  record.input = _.pathChangeExt( record.input,ext );
  record.form();
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

// function _originPathGet()
// {
//   var self = this;
//
//   if( self.context.originPath )
//   return self.context.originPath;
//   else if( self.fileProviderEffective )
//   return self.fileProviderEffective.originPath;
//   else
//   return self.fileProvider.originPath;
//
// }

//

function _isDir()
{
  var record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDirectory ) );

  if( !record.stat.isDirectory )
  return false;

  return record.stat.isDirectory();
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

  input : null,
  relative : null,
  absolute : null,
  real : null,
  full : null,
  absoluteEffective : null,

  // base : null,
  dir : null,

  exts : null,
  ext : null,
  extWithDot : null,
  name : null,
  nameWithExt : null,

  /* */

  inclusion : null,
  hash : null,

}

var Aggregates =
{
}

var Associates =
{
  stat : null,
  context : null,
  // fileProvider : null,
  // fileProviderEffective : null,
}

var Restricts =
{
}

var Statics =
{
  toAbsolute : toAbsolute,
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
  basePath : 'basePath',
  base : 'base',

  resolvingSoftLink : 'resolvingSoftLink',
  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',
  stating : 'stating',
  effective : 'effective',

  fileProvider : 'fileProvider',
  fileProviderEffective : 'fileProviderEffective',
  originPath : 'originPath',
  base : 'base',

}

var Accessors =
{
  // originPath : 'originPath',
}

// --
// prototype
// --

var Proto =
{

  init : init,
  form : form,
  clone : clone,

  _pathsForm : _pathsForm,

  _statRead : _statRead,
  _statAnalyze : _statAnalyze,

  changeExt : changeExt,

  hashGet : hashGet,

  // _originPathGet : _originPathGet,

  _isDir : _isDir,

  toAbsolute : toAbsolute,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.mapExtend( _,Globals );

if( _global_.wCopyable )
_.Copyable.mixin( Self );

if( typeof module !== 'undefined' )
require( './FileRecordContext.s' );

_.assert( !_global_.wFileRecord,'wFileRecord already defined' );

// --
// export
// --

_[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
