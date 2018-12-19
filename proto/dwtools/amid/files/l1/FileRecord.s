( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

// --
//
// --

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecord( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileRecord';

_.assert( !_.FileRecord );

// --
//
// --

function init( o )
{
  let record = this;

  if( _.strIs( o ) )
  o = { input : o }

  _.assert( arguments.length === 1 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordFactory ) );
  _.assert( _.strIs( o.input ), () => 'Expects string {-o.input-}, but got ' + _.strType( o.input ) );
  _.assert( _.objectIs( o.factory ) );

  _.instanceInit( record );

  record[ isTransientSymbol ] = null;
  record[ isActualSymbol ] = null;
  record[ statSymbol ] = 0;
  record[ realSymbol ] = 0;

  record.copy( o );

  let f = record.factory;
  if( f.strict )
  Object.preventExtensions( record );

  if( !f.formed )
  {
    if( !f.basePath && !f.dirPath && !f.stemPath )
    {
      f.basePath = _.uri.dir( o.input );
      f.stemPath = f.basePath;
    }
    f.form();
  }

  record.form();

  return record;
}

//

function form()
{
  let record = this;

  _.assert( Object.isFrozen( record.factory ) );
  _.assert( !!record.factory.formed, 'Record factory is not formed' );
  _.assert( record.factory.fileProvider instanceof _.FileProvider.Abstract );
  _.assert( record.factory.effectiveFileProvider instanceof _.FileProvider.Abstract );
  _.assert( _.strIs( record.input ), '{ record.input } must be a string' );
  _.assert( record.factory instanceof _.FileRecordFactory, 'Expects instance of { FileRecordFactory }' );

  record._pathsForm();
  // record._filterApply();
  // record._statRead();
  // record._statAnalyze();

  _.assert( record.fullName.indexOf( '/' ) === -1, 'something wrong with filename' );

  return record;
}

//

function clone( src )
{
  let record = this;
  let f = record.factory;

  src = src || record.input;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.strIs( src ) );

  let result = _.FileRecord({ input : src, factory : f });

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

  _.assert( arguments.length === 1, 'Expects single argument' );
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
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  let path = record.path
  let filePath = record.input;
  let isAbsolute = path.isAbsolute( filePath );

  _.assert( arguments.length === 0 );
  _.assert( _.strIs( f.basePath ) );

  /* path */

  if( !isAbsolute )
  if( f.dirPath )
  filePath = path.join( f.basePath, f.dirPath, filePath );
  else if( f.basePath )
  filePath = path.join( f.basePath, filePath );
  else if( !path.isAbsolute( filePath ) )
  _.assert( 0, 'FileRecordFactory expects defined fields {-dirPath-} or {-basePath-} or absolute path' );

  filePath = path.normalize( filePath );

  /* relative */

  record.relative = fileProvider.path.relative( f.basePath, filePath );
  _.assert( record.relative[ 0 ] !== '/' );
  record.relative = path.dot( record.relative );

  /*  */

  if( f.basePath )
  record.absolute = fileProvider.path.resolve( f.basePath, record.relative );
  else
  record.absolute = filePath;

  record.absolute = path.normalize( record.absolute );

  f.fileProvider._recordFormBegin( record );

  // record.absoluteGlobalMaybe = record.absolute;
  // record.real = record.absolute;
  // record.realGlobalMaybe = record.absolute;

  /* */

  record.factory.fileProvider._recordPathForm( record );

  return record;
}

//

function _filterApply()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( record[ isTransientSymbol ] === null )
  record[ isTransientSymbol ] = true;
  if( record[ isActualSymbol ] === null )
  record[ isActualSymbol ] = true;

  if( f.filter )
  {
    _.assert( f.filter.formed === 5, 'Expects formed filter' );
    f.filter.applyTo( record );
  }

}

//

function _isSafe()
{
  let record = this;
  let path = record.path;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( f.safe )
  {
    if( record.stat )
    if( !path.isSafe( record.absolute, f.safe ) )
    {
      debugger;
      throw path.ErrorNotSafe( 'Making record', record.absolute, f.safe );
    }
    if( record.stat && !record.stat.isTerminal() && !record.stat.isDir() && !record.stat.isSymbolicLink() )
    {
      debugger;
      throw path.ErrorNotSafe( 'Making record. Unknown kind of file', record.absolute, f.safe );
    }
  }

  return true;
}

//

function _statRead()
{
  let record = this;
  let f = record.factory;
  let stat;

  _.assert( arguments.length === 0 );

  // if( _.strEnds( record.absolute, '/dst/link' ) )
  // debugger;

  record[ realSymbol ] = record.absolute;

  if( f.resolvingSoftLink || f.resolvingTextLink )
  {

    let o2 =
    {
      hub : f.fileProvider,
      filePath : record.absolute,
      resolvingSoftLink : f.resolvingSoftLink,
      resolvingTextLink : f.resolvingTextLink,
      resolvingHeadDirect : 1,
      resolvingHeadReverse : 1,
      allowingMissed : f.allowingMissed,
      allowingCycled : f.allowingCycled,
      throwing : 1,
    }

    record[ realSymbol ] = f.effectiveFileProvider.pathResolveLinkFull( o2 );

    stat = o2.stat;

  }

  /* read and set stat */

  if( f.stating )
  {

    if( stat === undefined )
    stat = f.effectiveFileProvider.statReadAct
    ({
      filePath : record.real,
      throwing : 0,
      resolvingSoftLink : 0,
      sync : 1,
    });

    record[ statSymbol ] = stat;

  }

  /* analyze stat */

  return record;
}

//

function _statAnalyze()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  let path = record.path;
  let logger = fileProvider.logger || _global.logger;

  _.assert( record.stat === null || _.fileStatIs( record.stat ) );
  _.assert( f instanceof _.FileRecordFactory, '_record expects instance of ( FileRecordFactory )' );
  _.assert( fileProvider instanceof _.FileProvider.Abstract, 'Expects file provider instance of FileProvider' );
  _.assert( arguments.length === 0 );

  record._isSafe();

  record.factory.fileProvider._recordFormEnd( record );

}

//

function reval()
{
  let record = this;

  _.assert( arguments.length === 0 );

  record[ Symbo.for( 'isActual' ) ] = null;
  record[ Symbo.for( 'isTransient' ) ] = null;

  record[ statSymbol ] = 0;
  record[ realSymbol ] = 0;

  record._statRead();
  record._statAnalyze();

}

//

function changeExt( ext )
{
  let record = this;
  let path = record.path;
  _.assert( arguments.length === 1, 'Expects single argument' );
  record.input = path.changeExt( record.input, ext );
  record.form();
}

//

function hashRead()
{
  let record = this;
  let f = record.factory;

  _.assert( arguments.length === 0 );

  if( record.hash !== null )
  return record.hash;

  record.hash = f.effectiveFileProvider.hashRead
  ({
    filePath : record.absolute,
    verbosity : 0,
  });

  return record.hash;
}

//

function _isTransientGet()
{
  let record = this;
  let result = record[ isTransientSymbol ];
  if( result === null )
  {
    record._filterApply();
    result = record[ isTransientSymbol ];
  }
  return result;
}

//

function _isActualGet()
{
  let record = this;
  let result = record[ isActualSymbol ];
  if( result === null )
  {
    record._filterApply();
    result = record[ isActualSymbol ];
  }
  return result;
}

//

function _isStemGet()
{
  let record = this;
  let f = record.factory;
  return f.stemPath === record.absolute;
}

//

function _isDirGet()
{
  let record = this;

  // debugger;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDir ) );

  return record.stat.isDir();
}

//

function _isTerminalGet()
{
  let record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isTerminal ) );

  return record.stat.isTerminal();
}

//

function _isHardLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !record.stat )
  return false;

  return record.stat.isHardLink();
}

//

function _isSoftLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !f.usingSoftLink )
  return false;

  if( !record.stat )
  return false;

  return record.stat.isSoftLink();
}

//

function _isTextLinkGet()
{
  let record = this;
  let f = record.factory;

  if( !f.usingTextLink )
  return false;

  if( f.resolvingTextLink )
  return false;

  debugger;

  if( !record.stat )
  return false;

  return record.stat.isTextLink();
}

//

function _isLinkGet()
{
  let record = this;
  let f = record.factory;

  debugger;

  return record._isSoftLinkGet() || record._isTextLinkGet();
}

//

function _pathGet()
{
  let record = this;
  let f = record.factory;
  _.assert( !!f );
  let fileProvider = f.fileProvider;
  return fileProvider.path;
}

//

function _statGet()
{
  let record = this;
  if( record[ statSymbol ] === 0 )
  {
    record._statRead();
    record._statAnalyze();
  }
  return record[ statSymbol ];
}

//

function _realGet()
{
  let record = this;
  if( record[ realSymbol ] === 0 )
  {
    record._statRead();
    record._statAnalyze();
  }
  return record[ realSymbol ];
}

//

function _absoluteGlobalGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  return fileProvider.globalFromLocal( record.absolute );
}

//

function _realGlobalGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.effectiveFileProvider;
  return fileProvider.globalFromLocal( record.real );
}

//

function _absoluteGlobalMaybeGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.fileProvider;
  return fileProvider._recordAbsoluteGlobalMaybeGet( record );
}

//

function _realGlobalMaybeGet()
{
  let record = this;
  let f = record.factory;
  let fileProvider = f.fileProvider;
  return fileProvider._recordRealGlobalMaybeGet( record );
}

//

function _dirGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.dir( record.absolute );
}

//

function _extsGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.exts( record.absolute );
}

//

function _extGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.ext( record.absolute );
}

//

function _extWithDotGet()
{
  let record = this;
  let f = record.factory;
  let ext = record.ext;
  return ext ? '.' + ext : '';
}

//

function _nickNameGet()
{
  let record = this;
  let f = record.factory;
  if( f && f.path )
  return '{ ' + record.constructor.shortName + ' : ' + f.path.name( record.absolute ) + ' }';
  else
  return '{ ' + record.constructor.shortName + ' }';
}

//

function _nameGet()
{
  let record = this;
  let f = record.factory;
  let path = record.path;
  return path.name( record.absolute );
}

//

function _fullNameGet()
{
  let record = this;
  let f = record.factory;
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
// relations
// --

let statSymbol = Symbol.for( 'stat' );
let realSymbol = Symbol.for( 'real' );
let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );

let Composes =
{

  absolute : null,
  // real : 0,
  relative : null,

  // absoluteGlobalMaybe : null,
  // realGlobalMaybe : null,
  input : null,

  /* */

  // isTransient : null,
  // isActual : null,
  hash : null,

}

let Aggregates =
{
}

let Associates =
{
  // stat : 0,
  factory : null,
  associated : null,
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

  file : 'file',
  relativeIn : 'relativeIn',
  relativeOut : 'relativeOut',
  verbosity : 'verbosity',
  safe : 'safe',
  basePath : 'basePath',
  base : 'base',
  resolvingSoftLink : 'resolvingSoftLink',
  resolvingTextLink : 'resolvingTextLink',
  usingTextLink : 'usingTextLink',
  stating : 'stating',
  effective : 'effective',
  fileProvider : 'fileProvider',
  effectiveFileProvider : 'effectiveFileProvider',
  originPath : 'originPath',
  base : 'base',
  full : 'full',
  superRelative : 'superRelative',
  inclusion : 'inclusion',
  isBase : 'isBase',
  absoluteEffective : 'absoluteEffective',
  realEffective : 'realEffective',
  isBranch : 'isBranch',
  realAbsolute : 'realAbsolute',
  realUri : 'realUri',
  absoluteUri : 'absoluteUri',
  hubAbsolute : 'hubAbsolute',
  context : 'context',

}

let Accessors =
{

  path : { readOnly : 1 },
  stat : { readOnly : 1 },

  real : { readOnly : 1 },
  absoluteGlobal : { readOnly : 1 },
  realGlobal : { readOnly : 1 },
  absoluteGlobalMaybe : { readOnly : 1 },
  realGlobalMaybe : { readOnly : 1 },

  dir : { readOnly : 1 },
  exts : { readOnly : 1 },
  ext : { readOnly : 1 },
  extWithDot : { readOnly : 1 },
  nickName : { readOnly : 1 },
  name : { readOnly : 1 },
  fullName : { readOnly : 1 },

  isTransient : { readOnly : 1 },
  isActual : { readOnly : 1 },
  isStem : { readOnly : 1 },
  isDir : { readOnly : 1 },
  isTerminal : { readOnly : 1 },
  isHardLink : { readOnly : 1 },
  isSoftLink : { readOnly : 1 },
  isTextLink : { readOnly : 1 },
  isLink : { readOnly : 1 },

}

// --
// declare
// --

let Proto =
{

  init,
  form,
  clone,
  From,
  FromMany,
  toAbsolute,

  _pathsForm,
  _filterApply,
  _isSafe,
  _statRead,
  _statAnalyze,

  reval,
  changeExt,
  hashRead,

  _isTransientGet,
  _isActualGet,
  _isStemGet,
  _isDirGet,
  _isTerminalGet,
  _isHardLinkGet,
  _isSoftLinkGet,
  _isTextLinkGet,
  _isLinkGet,

  _pathGet,
  _statGet,

  _realGet,
  _absoluteGlobalGet,
  _realGlobalGet,
  _absoluteGlobalMaybeGet,
  _realGlobalMaybeGet,

  _dirGet,
  _extsGet,
  _extGet,
  _extWithDotGet,
  _nickNameGet,
  _nameGet,
  _fullNameGet,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Copiers,
  Forbids,
  Accessors,

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
require( './FileRecordFactory.s' );

// --
// export
// --

_[ Self.shortName ] = Self;

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
