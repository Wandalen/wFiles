( function _FileRecord_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

var _global = _global_;
var _ = _global_.wTools;
_.assert( !_.FileRecord );

//

var _global = _global_;
var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecord( c )
{
  if( !( this instanceof Self ) )
  if( c instanceof Self )
  {
    _.assert( arguments.length === 1, 'expects single argument' );
    return c;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileRecord';

//

function init( filePath, c )
{
  var record = this;

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( !( arguments[ 0 ] instanceof _.FileRecordContext ) || arguments[ 1 ] instanceof _.FileRecordContext );
  _.assert( _.strIs( filePath ),'expects string {-filePath-}, but got',_.strTypeOf( filePath ) );

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
    if( !c.basePath && !c.dir )
    {
      c.basePath = _.path.dir( filePath );
    }

    c = new _.FileRecordContext( c );
  }

  record.context = c;
  Object.freeze( record.context );

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
  var record = this;
  var c = record.context;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( src === undefined || _.strIs( src ) );

  var result = _.FileRecord( src, c );

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

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.arrayIs( src ) );

  for( var s = 0 ; s < src.length ; s++ )
  result[ s ] = Self.from( src[ s ] );

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

  var result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

function _pathsForm()
{
  var record = this;
  var c = record.context;
  var fileProvider = c.fileProviderEffective;
  var filePath = record.input;
  var isAbsolute = _.path.isAbsolute( filePath );

  _.assert( arguments.length === 0 );
  _.assert( _.strIs( c.basePath ) );

  /* path */

  if( !isAbsolute )
  if( c.dir )
  filePath = _.path.join( c.basePath, c.dir, filePath );
  else if( c.basePath )
  filePath = _.path.join( c.basePath,filePath );
  else if( !_.path.isAbsolute( filePath ) )
  _.assert( 0, 'FileRecordContext expects { dir } or { basePath } or absolute path' );

  filePath = _.path.normalize( filePath );

  /* relative */

  record.relative = fileProvider.path.relative( c.basePath, filePath );
  _.assert( record.relative[ 0 ] !== '/' );
  record.relative = _.path.dot( record.relative );

  record.superRelative = _.path.join( _.path.fullName( c.basePath ), _.path.undot( record.relative ) );
  if( record.superRelative[ 0 ] !== '/' )
  record.superRelative = _.path.dot( record.superRelative );
  record.superRelative = _.path.normalize( record.superRelative );

  /*  */

  if( c.basePath )
  record.absolute = fileProvider.pathResolve( c.basePath,record.relative );
  else
  record.absolute = filePath;

  record.absolute = _.path.normalize( record.absolute );

  c.fileProvider._fileRecordFormBegin( record );

  _.assert( _.strIs( c.originPath ) );

  // record.absoluteUri = c.originPath + record.absolute;
  record.absoluteEffective = record.absolute;

  record.real = record.absolute;
  // record.realUri = c.originPath + record.real;
  record.realEffective = record.real;

  /* */

  record.context.fileProvider._fileRecordPathForm( record );

  return record;
}

//

function _statRead()
{
  var record = this;
  var c = record.context;

  // if( _.strHas( record.absolute, 'staging/dwtools/amid/astring/StringsExtra.s' ) )
  // debugger;

  _.assert( arguments.length === 0 );

  /* pathResolve link */

  record.real = c.fileProviderEffective.pathResolveLink
  ({
    filePath : record.real,
    // resolvingHardLink : null,
    resolvingSoftLink : c.resolvingSoftLink,
    resolvingTextLink : c.resolvingTextLink,
    hub : c.fileProvider,
  });

  // record.realUri = _.uri.join( c.originPath, record.real );
  record.realEffective = record.real;

  // if( c.fileProviderEffective.verbosity >= 8 )
  // logger.log( 'Record', record.absolute,'->', record.real );

  /* get stat */

  if( !c.stating )
  record.inclusion = false;

  if( record.inclusion !== false )
  {

    var provider = _.uri.isGlobal( record.real ) ? c.fileProvider : c.fileProviderEffective;

    record.stat = provider.fileStat
    ({
      filePath : record.real,
      resolvingSoftLink : 0,
      resolvingTextLink : 0,
      throwing : 0,
      sync : 1,
      // sync : c.sync,
    });

    if( !record.stat )
    if( record.real !== record.absolute )
    {
      debugger;
      throw _.err( 'Bad link', record.absolute, '->', record.real );
    }

    // if( !c.sync )
    // debugger;
    // if( !c.sync )
    // record.stat.ifNoErrorThen( ( arg ) => record.stat = arg );

  }

  /* analyze stat */

  _.assert( record.stat === null || _.fileStatIs( record.stat ) );

  // if( record.stat instanceof _.Consequence )
  // record.stat.doThen( function( err,arg )
  // {
  //   debugger;
  //   record._statAnalyze();
  //   this.give( err,arg );
  // });
  // else
  // {
    record._statAnalyze();
  // }

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

  if( fileProvider.verbosity > 2 )
  if( !record.stat )
  {
    logger.log( '!','Cant access file :',record.absolute );
  }

  /* */

  if( record.inclusion === null )
  record.inclusion = true;

  c.filter.test( record );

  /* */

  if( fileProvider.safe || fileProvider.safe === undefined )
  {
    if( record.inclusion )
    if( !_.path.isSafe( record.absolute ) )
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
  var record = this;

  _.assert( arguments.length === 0 );

  record.inclusion = null;

  return record._statRead();
}

//

function changeExt( ext )
{
  var record = this;
  _.assert( arguments.length === 1, 'expects single argument' );
  record.input = _.path.changeExt( record.input,ext );
  record.form();
}

//

function hashGet()
{
  var record = this;
  var c = record.context;

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

//

function _isTerminal()
{
  var record = this;

  if( !record.stat )
  return false;

  _.assert( _.routineIs( record.stat.isDirectory ) );

  if( !record.stat.isDirectory )
  return false;

  return !record.stat.isDirectory();
}

//

function _isSoftLink()
{
  var record = this;
  var c = record.context;

  if( !c.usingSoftLink )
  return false;

  if( !record.stat )
  return false;

  return record.stat.isSymbolicLink();
}

//

function _isTextLink()
{
  var record = this;
  var c = record.context;

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

function _isLink()
{
  var record = this;
  var c = record.context;

  debugger;

  return self._isSoftLink() || self._isTextLink();
}

//

function _absoluteUriGet()
{
  var record = this;
  var c = record.context;
  return c.originPath + record.absolute;
}

//

function _realUriGet()
{
  var record = this;
  var c = record.context;
  return c.originPath + record.real;
}

//

function _dirGet()
{
  var record = this;
  var c = record.context;
  return _.path.dir( record.absolute );
}

//

function _extsGet()
{
  var record = this;
  var c = record.context;
  return _.path.exts( record.absolute );
}

//

function _extGet()
{
  var record = this;
  var c = record.context;
  return _.path.ext( record.absolute );
}

//

function _extWithDotGet()
{
  var record = this;
  var c = record.context;
  var ext = record.ext;
  return ext ? '.' + ext : '';
}

//

function _nameGet()
{
  var record = this;
  var c = record.context;
  return _.path.name( record.absolute );
}

//

function _fullNameGet()
{
  var record = this;
  var c = record.context;
  return _.path.fullName( record.absolute );
}

// --
// statics
// --

function statCopier( it )
{
  var self = this;

  if( it.technique === 'data' )
  return _.mapFields( it.src );
  else
  return it.src;
}

// --
//
// --

var Composes =
{

  input : null,
  relative : null,
  superRelative : null,

  absolute : null,
  absoluteEffective : null,

  real : null,
  realEffective : null,

  /* */

  isBase : 0,
  inclusion : null,
  hash : null,
  stat : null,

}

var Aggregates =
{
}

var Associates =
{
  context : null,
}

var Restricts =
{
}

var Statics =
{
  from : from,
  manyFrom : manyFrom,
  toAbsolute : toAbsolute,
}

var Copiers =
{
  stat : statCopier,
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
  full : 'full',

}

var Accessors =
{

  absoluteUri : { readOnly : 1 },
  realUri : { readOnly : 1 },
  dir : { readOnly : 1 },
  exts : { readOnly : 1 },
  ext : { readOnly : 1 },
  extWithDot : { readOnly : 1 },
  name : { readOnly : 1 },
  fullName : { readOnly : 1 },

  // isDir : { readOnly : 1 },
  // isTerminal : { readOnly : 1 },

}

// --
// declare
// --

var Proto =
{

  init : init,
  form : form,
  clone : clone,
  from : from,
  manyFrom : manyFrom,
  toAbsolute : toAbsolute,

  _pathsForm : _pathsForm,
  _statRead : _statRead,
  _statAnalyze : _statAnalyze,

  restat : restat,
  changeExt : changeExt,
  hashGet : hashGet,

  _isDir : _isDir,
  _isTerminal : _isTerminal,
  _isSoftLink : _isSoftLink,
  _isTextLink : _isTextLink,
  _isLink : _isLink,

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
