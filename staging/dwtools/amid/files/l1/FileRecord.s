( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecord( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  {
    _.assert( arguments.length === 1, 'expects single argument' );
    return o;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileRecord';

_.assert( !_.FileRecord );

//

function init( filePath, c )
{
  let record = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordContext ) || arguments[ 1 ] instanceof _.FileRecordContext );
  _.assert( _.strIs( filePath ),'expects string {-filePath-}, but got', _.strTypeOf( filePath ) );

  _.instanceInit( record );

  if( c.strict )
  Object.preventExtensions( record );

  if( c === undefined )
  {
    debugger;
    c = new _.FileRecordContext();
  }
  else if( _.mapIs( c ) )
  {
  if( !c.basePath && !c.dirPath && !c.branchPath )
  {
    c.basePath = _.uri.dir( filePath );
    c.branchPath = c.basePath;
  }
    c = new _.FileRecordContext( c );
  }

  record.context = c;

  Object.freeze( record.context );

  record.input = filePath;

  _.assert( record.isActual === null );

  record.form();

  return record;
}

//

function form()
{
  let record = this;

  _.assert( Object.isFrozen( record.context ) );
  _.assert( !!record.context.formed, 'Record context is not formed' );
  // _.assert( record.fileProvider );
  _.assert( record.context.fileProvider instanceof _.FileProvider.Abstract );
  _.assert( record.context.fileProviderEffective instanceof _.FileProvider.Abstract );
  // _.assert( record.input );

  _.assert( _.strIs( record.input ),'{ record.input } must be a string' );
  _.assert( record.context instanceof _.FileRecordContext,'expects instance of { FileRecordContext }' );
  // _.assert( record.fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );

  record._pathsForm();
  record._statRead();

  _.assert( record.fullName.indexOf( '/' ) === -1,'something wrong with filename' );

  return record;
}

//

function clone( src )
{
  let record = this;
  let c = record.context;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( src === undefined || _.strIs( src ) );

  let result = _.FileRecord( src, c );

  return result;
}

//

function From( src )
{
  return Self( src );
}

//

function FromMany( src )
{
  let result = [];

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( src ) );

  for( let s = 0 ; s < src.length ; s++ )
  result[ s ] = Self.From( src[ s ] );

  return result;
}

//

function toAbsolute( record )
{

  if( record === undefined )
  record = this;

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  let result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

function _pathsForm()
{
  let record = this;
  let c = record.context;
  let fileProvider = c.fileProviderEffective;
  let path = record.path
  let filePath = record.input;
  let isAbsolute = path.isAbsolute( filePath );

  _.assert( arguments.length === 0 );
  _.assert( _.strIs( c.basePath ) );

  /* path */

  if( !isAbsolute )
  if( c.dirPath )
  filePath = path.join( c.basePath, c.dirPath, filePath );
  else if( c.basePath )
  filePath = path.join( c.basePath,filePath );
  else if( !path.isAbsolute( filePath ) )
  _.assert( 0, 'FileRecordContext expects defined fields {-dirPath-} or {-basePath-} or absolute path' );

  filePath = path.normalize( filePath );

  /* relative */

  record.relative = fileProvider.path.relative( c.basePath, filePath );
  _.assert( record.relative[ 0 ] !== '/' );
  record.relative = path.dot( record.relative );

  /*  */

  if( c.basePath )
  record.absolute = fileProvider.path.resolve( c.basePath, record.relative );
  else
  record.absolute = filePath;

  record.absolute = path.normalize( record.absolute );

  c.fileProvider._fileRecordFormBegin( record );

  _.assert( _.strIs( c.originPath ) );

  record.absoluteEffective = record.absolute;

  record.real = record.absolute;
  record.realEffective = record.real;

  /* */

  record.context.fileProvider._fileRecordPathForm( record );

  return record;
}

//

function _statRead()
{
  let record = this;
  let c = record.context;

  _.assert( arguments.length === 0 );

  /* resolve link */

  record.real = c.fileProviderEffective.pathResolveLink
  ({
    filePath : record.real,
    resolvingSoftLink : c.resolvingSoftLink,
    resolvingTextLink : c.resolvingTextLink,
    hub : c.fileProvider,
  });

  record.realEffective = record.real;

  // if( c.fileProviderEffective.verbosity >= 8 )
  // logger.log( 'Record', record.absolute,'->', record.real );

  /* get stat */

  if( !c.stating )
  {
    //record.isTransient = false;
    record.isActual = false
  }

  if( c.stating )
  {
    let provider = _.uri.isGlobal( record.real ) ? c.fileProvider : c.fileProviderEffective;

    record.stat = provider.fileStat
    ({
      filePath : record.real,
      resolvingSoftLink : 0,
      resolvingTextLink : 0,
      throwing : 0,
      sync : 1,
    });

    if( !record.stat )
    if( record.real !== record.absolute )
    {
      debugger;
      throw _.err( 'Bad link', record.absolute, '->', record.real );
    }

  }

  /* analyze stat */

  _.assert( record.stat === null || _.fileStatIs( record.stat ) );
  record._statAnalyze();

  return record;
}

//

function _statAnalyze()
{
  let record = this;
  let c = record.context;
  let fileProvider = c.fileProviderEffective;
  let path = record.path;

  _.assert( c instanceof _.FileRecordContext,'_fileRecord expects instance of ( FileRecordContext )' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract,'expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 );

  /* */

  if( !record.stat )
  {
    record.isTransient = false;
    record.isActual = false;
  }

  /* */

  if( fileProvider.verbosity > 2 )
  if( !record.stat )
  {
    logger.log( '!','Cant access file :',record.absolute );
  }

  /* */

  if( record.isTransient === null )
  record.isTransient = true;
  if( record.isActual === null )
  record.isActual = true;

  if( c.filter )
  c.filter.test( record );

  /* */

  if( fileProvider.safe || fileProvider.safe === undefined )
  {
    if( record.isActual )
    if( !path.isSafe( record.absolute ) )
    {
      debugger;
      throw _.err( 'Unsafe record :', record.absolute, '\nUse options ( safe:0 ) if intention was to access system files.' );
    }
    if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
    throw _.err( 'Unsafe record, unknown kind of file :',record.absolute );
  }

  /* */

  record.context.fileProvider._fileRecordFormEnd( record );

  if( c.onRecord )
  {
    if( c.onRecord.length )
    debugger;
    _.assert( fileProvider );
    _.routinesCall( c,c.onRecord,[ record ] );
  }

}

//

function restat()
{
  let record = this;

  _.assert( arguments.length === 0 );

  record.isActual = null;
  record.isTransient = null;

  return record._statRead();
}

//

function changeExt( ext )
{
  let record = this;
  let path = record.path;
  _.assert( arguments.length === 1, 'expects single argument' );
  record.input = path.changeExt( record.input,ext );
  record.form();
}

//

function hashGet()
{
  let record = this;
  let c = record.context;

  _.assert( arguments.length === 0 );

  if( record.hash !== null )
  return record.hash;

  record.hash = c.fileProviderEffective.fileHash
  ({
    filePath : record.absolute,
    verbosity : 0,
  });

  return record.hash;
}

//

function _isBranchGet()
{
  let record = this;
  let c = record.context;
  return c.branchPath === record.absolute;
  // return c.branchPath === record.absoluteEffective;
}

//

function _isDirGet()
{
  let record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDirectory ) );

  if( !record.stat.isDirectory )
  return false;

  return record.stat.isDirectory();
}

//

function _isTerminalGet()
{
  let record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDirectory ) );

  if( !record.stat.isDirectory )
  return false;

  return !record.stat.isDirectory();
}

//

function _isSoftLinkGet()
{
  let record = this;
  let c = record.context;

  if( !c.usingSoftLink )
  return false;

  if( !record.stat )
  return false;

  return record.stat.isSymbolicLink();
}

//

function _isTextLinkGet()
{
  let record = this;
  let c = record.context;

  if( !c.usingTextLink )
  return false;

  if( c.resolvingTextLink )
  return false;

  debugger;

  if( !record.stat )
  return false;

  // debugger; xxx

  // return c.fileProvider.fileIsTextLink( c.real );
  return c.fileProvider.fileIsTextLink( record.real );
}

//

function _isLinkGet()
{
  let record = this;
  let c = record.context;

  debugger;

  return record._isSoftLinkGet() || record._isTextLinkGet();
}

//

function _pathGet()
{
  let record = this;
  let c = record.context;
  let fileProvider = c.fileProvider;
  return fileProvider.path;
}

//

function _absoluteUriGet()
{
  let record = this;
  let c = record.context;
  return c.originPath + record.absolute;
}

//

function _realUriGet()
{
  let record = this;
  let c = record.context;
  return c.originPath + record.real;
}

//

function _dirGet()
{
  let record = this;
  let c = record.context;
  let path = record.path;
  return path.dir( record.absolute );
}

//

function _extsGet()
{
  let record = this;
  let c = record.context;
  let path = record.path;
  return path.exts( record.absolute );
}

//

function _extGet()
{
  let record = this;
  let c = record.context;
  let path = record.path;
  return path.ext( record.absolute );
}

//

function _extWithDotGet()
{
  let record = this;
  let c = record.context;
  let ext = record.ext;
  return ext ? '.' + ext : '';
}

//

function _nameGet()
{
  let record = this;
  let c = record.context;
  let path = record.path;
  return path.name( record.absolute );
}

//

function _fullNameGet()
{
  let record = this;
  let c = record.context;
  let path = record.path;
  return path.fullName( record.absolute );
}

// --
// statics
// --

function statCopier( it )
{
  let record = this;
  if( it.technique === 'data' )
  return _.mapFields( it.src );
  else
  return it.src;
}

// --
//
// --

let Composes =
{

  input : null,
  relative : null,
  // superRelative : null,

  absolute : null,
  absoluteEffective : null,

  real : null,
  realEffective : null,

  /* */

  // isBranch : 0,
  isTransient : null,
  isActual : null,
  hash : null,
  stat : null,

}

let Aggregates =
{
}

let Associates =
{
  context : null,
}

let Restricts =
{
}

let Statics =
{
  From : From,
  FromMany : FromMany,
  toAbsolute : toAbsolute,
}

let Copiers =
{
  stat : statCopier,
}

let Forbids =
{

  // path : 'path',
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
  full : 'full',
  superRelative : 'superRelative',
  inclusion : 'inclusion',

  isBase : 'isBase',

}

let Accessors =
{

  absoluteUri : { readOnly : 1 },
  realUri : { readOnly : 1 },
  dir : { readOnly : 1 },
  exts : { readOnly : 1 },
  ext : { readOnly : 1 },
  extWithDot : { readOnly : 1 },
  name : { readOnly : 1 },
  fullName : { readOnly : 1 },
  path : { readOnly : 1 },

  // isDir : { readOnly : 1 },
  // isTerminal : { readOnly : 1 },

  isBranch : { readOnly : 1 },
  isDir : { readOnly : 1 },
  isTerminal : { readOnly : 1 },
  isSoftLink : { readOnly : 1 },
  isTextLink : { readOnly : 1 },
  isLink : { readOnly : 1 },

}

// --
// declare
// --

let Proto =
{

  init : init,
  form : form,
  clone : clone,
  From : From,
  FromMany : FromMany,
  toAbsolute : toAbsolute,

  _pathsForm : _pathsForm,
  _statRead : _statRead,
  _statAnalyze : _statAnalyze,

  restat : restat,
  changeExt : changeExt,
  hashGet : hashGet,

  _isBranchGet : _isBranchGet,
  _isDirGet : _isDirGet,
  _isTerminalGet : _isTerminalGet,
  _isSoftLinkGet : _isSoftLinkGet,
  _isTextLinkGet : _isTextLinkGet,
  _isLinkGet : _isLinkGet,

  _pathGet : _pathGet,
  _absoluteUriGet : _absoluteUriGet,
  _realUriGet : _realUriGet,
  _dirGet : _dirGet,
  _extsGet : _extsGet,
  _extGet : _extGet,
  _extWithDotGet : _extWithDotGet,
  _nameGet : _nameGet,
  _fullNameGet : _fullNameGet,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Copiers : Copiers,
  Forbids : Forbids,
  Accessors : Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

_.assert( !_global_.wFileRecord && !_.FileRecord, 'wFileRecord already defined' );

//

if( typeof module !== 'undefined' )
require( './FileRecordContext.s' );

// --
// export
// --

_[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
