( function _FileRecordFilter_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

var _global = _global_; var _ = _global_.wTools;
_.assert( !_.FileRecordFilter );

//

var _global = _global_; var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecordFilter( c )
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

Self.nameShort = 'FileRecordFilter';

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1, 'expects at least one argument' );
  _.assert( Self.prototype.Composes );
  o = _.mapExtendByMaps( null, arguments );
  return new Self( _.mapScreen( Self.prototype.copyableFields,o ) );
}

//

function init( o )
{
  var self = this;

  _.instanceInit( self );
  Object.preventExtensions( self );

  if( o )
  {

    if( o.maskAll )
    o.maskAll = _.RegexpObject( o.maskAll,'includeAny' );
    if( o.maskTerminal )
    o.maskTerminal = _.RegexpObject( o.maskTerminal,'includeAny' );
    if( o.maskDir )
    o.maskDir = _.RegexpObject( o.maskDir,'includeAny' );

    self.copy( o );

  }

  // _.assert( self.filter.maskAll === null || _.regexpObjectIs( self.filter.maskAll ) );
  // _.assert( self.filter.maskTerminal === null || _.regexpObjectIs( self.filter.maskTerminal ) );
  // _.assert( self.filter.maskDir === null || _.regexpObjectIs( self.filter.maskDir ) );

  return self;
}

//

function form()
{
  var self = this;

  _.assert( self.formed === 0 );
  _.assert( self.fileProvider );
  // _.assert( self );

  self.formGlob();
  self.formMasks();

  self.test = self._testNothing;

  if( self.notOlder || self.notNewer || self.notOlderAge || self.notNewerAge )
  self.test = self._testFull;
  else if( !self.maskAll.isEmpty() || !self.maskTerminal.isEmpty() || !self.maskDir.isEmpty() )
  self.test = self._testMasks;

  self.formed = 1;
  Object.freeze( self );

  return self;
}

//

function formGlob()
{
  var self = this;
  var fileProvider = self.fileProvider;

  _.assert( !self.globOut );

  if( self.globOut !== null || self.globIn === null )
  return;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );
  _.assert( _.strIs( self.globIn ) || _.arrayIs( self.globIn ) );
  _.assert( self.relative === undefined );

  self.globIn = fileProvider.pathsNormalize( self.globIn );

  if( !self.filePath )
  {
    if( _.arrayIs( self.globIn ) )
    self.filePath = _.entityFilter( self.globIn,( globIn ) => self.pathFromGlob( globIn ) );
    else
    self.filePath = self.pathFromGlob( self.globIn );
  }

  if( !self.basePath )
  {
    if( _.arrayIs( self.filePath ) )
    self.basePath = _.pathCommon( self.filePath );
    else
    self.basePath = self.filePath;
  }

  _.assert( _.strIs( self.filePath ) || _.strsAre( self.filePath ) );

  function globAdjust( glob )
  {

    var basePath = _.strAppendOnce( self.basePath,'/' );

    if( !_.strBegins( glob, basePath ) )
    basePath = self.basePath;

    if( _.strBegins( glob, basePath ) )
    {
      glob = glob.substr( basePath.length, glob.length );
    }

    return glob;
  }

  if( _.arrayIs( self.globIn ) )
  self.globOut = _.entityFilter( self.globIn,( globIn ) => globAdjust( globIn ) );
  else
  self.globOut = globAdjust( self.globIn );

}

//

function formMasks()
{
  var self = this;

  _.assert( arguments.length === 0 );
  _.assert( self.glob === undefined );

  self.maskAll = _.regexpMakeObject( self.maskAll || Object.create( null ),'includeAny' );
  self.maskTerminal = _.regexpMakeObject( self.maskTerminal || Object.create( null ),'includeAny' );
  self.maskDir = _.regexpMakeObject( self.maskDir || Object.create( null ),'includeAny' );

  if( self.hasExtension )
  {
    _.assert( _.strIs( self.hasExtension ) || _.strsAre( self.hasExtension ) );

    self.hasExtension = _.arrayAs( self.hasExtension );
    self.hasExtension = new RegExp( '^\\.\\/.+\\.(' + _.regexpEscape( self.hasExtension ).join( '|' ) + ')$', 'i' );

    _.RegexpObject.shrink( self.maskTerminal,{ includeAll : self.hasExtension } );
    self.hasExtension = null;
  }

  if( self.begins )
  {
    _.assert( _.strIs( self.begins ) || _.strsAre( self.begins ) );

    self.begins = _.arrayAs( self.begins );
    self.begins = new RegExp( '^(\\.\\/)?(' + _.regexpEscape( self.begins ).join( '|' ) + ')' );

    self.maskTerminal = _.RegexpObject.shrink( self.maskTerminal,{ includeAll : self.begins } );
    self.begins = null;
  }

  if( self.ends )
  {
    _.assert( _.strIs( self.ends ) || _.strsAre( self.ends ) );

    self.ends = _.arrayAs( self.ends );
    self.ends = new RegExp( '(' + _.regexpEscape( self.ends ).join( '|' ) + ')$' );

    self.maskTerminal = _.RegexpObject.shrink( self.maskTerminal,{ includeAll : self.ends } );
    self.ends = null;
  }

  /* */

  if( self.globOut )
  {

    var globRegexp = _.globRegexpsForTerminal( self.globOut );
    self.maskTerminal = _.RegexpObject.shrink( self.maskTerminal,{ includeAll : globRegexp } );

    // var globRegexp = _.globRegexpsForDirectory( self.globOut );
    // self.maskDir = _.RegexpObject.shrink( self.maskDir,{ includeAll : globRegexp } );

  }

  self.globOut = null;

  /* */

  if( self.notOlder )
  _.assert( _.numberIs( self.notOlder ) || _.dateIs( self.notOlder ) );

  if( self.notNewer )
  _.assert( _.numberIs( self.notNewer ) || _.dateIs( self.notNewer ) );

  if( self.notOlderAge )
  _.assert( _.numberIs( self.notOlderAge ) || _.dateIs( self.notOlderAge )  );

  if( self.notNewerAge )
  _.assert( _.numberIs( self.notNewerAge ) || _.dateIs( self.notNewerAge ) );

}

//

function pathFromGlob( globIn )
{
  var self = this;
  var result = _.pathFromGlob( globIn );
  return result;
}

//

function and( src )
{
  var self = this;

  _.assert( _.instanceIs( self ) );

  // if( !_.instanceIs( self ) )
  // debugger;
  // if( !_.instanceIs( self ) )
  // return self.Self.all.apply( self.Self, arguments );

  if( arguments.length > 1 )
  {
    for( var a = 0 ; a < arguments.length ; a++ )
    self.and( arguments[ a ] );
    return self;
  }

  _.assert( !self.formed );
  _.assert( arguments.length === 1, 'expects single argument' );
  if( Config.debug )
  if( src && !( src instanceof self.Self ) )
  _.assertMapHasOnly( src, self.copyableFields );

  if( src === self )
  return self;

  var once =
  {
    globIn : null,
    hasExtension : null,
    begins : null,
    ends : null,
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
  }

  for( var n in once )
  {
    _.assert( !self[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field',n );
    if( src[ n ] )
    self[ n ] = src[ n ];
  }

  if( self.maskAll && src.maskAll !== undefined )
  self.maskAll.shrink( src.maskAll );
  else if( src.maskAll )
  {
    if( src.maskAll instanceof _.RegexpObject )
    self.maskAll = src.maskAll.clone();
    else
    self.maskAll = _.RegexpObject( src.maskAll );
  }

  if( self.maskTerminal && src.maskTerminal !== undefined )
  self.maskTerminal.shrink( src.maskTerminal );
  else if( src.maskTerminal )
  {
    if( src.maskTerminal instanceof _.RegexpObject )
    self.maskTerminal = src.maskTerminal.clone();
    else
    self.maskTerminal = _.RegexpObject( src.maskTerminal );
  }

  if( self.maskDir && src.maskDir !== undefined )
  self.maskDir.shrink( src.maskDir );
  else if( src.maskDir )
  {
    if( src.maskDir instanceof _.RegexpObject )
    self.maskDir = src.maskDir.clone();
    else
    self.maskDir = _.RegexpObject( src.maskDir );
  }

}

//

function all_static()
{
  _.assert( !_.instanceIs( this ) );

  var dstFilter = null;

  if( arguments.length === 1 )
  return this.Self( arguments[ 0 ] );

  for( var a = 0 ; a < arguments.length ; a++ )
  {
    var srcFilter = arguments[ a ];

    if( dstFilter )
    dstFilter = this.Self( dstFilter );
    if( dstFilter )
    dstFilter.and( srcFilter );
    else
    dstFilter = this.Self( srcFilter );

  }

  return dstFilter;
}

//

function _testNothing( record )
{
  var self = this;
  return record.inclusion;
}

//

function _testMasks( record )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( record.inclusion === false )
  return record.inclusion;

  // if( record.absolute === '/' )
  // debugger;

  var r = record.relative;

  // if( record.relative === '.' )
  // debugger;
  // if( record.relative === '.' )
  // r = _.pathDot( record.nameWithExt );

  if( record._isDir() )
  {
    if( record.inclusion && self.maskAll )
    record.inclusion = self.maskAll.test( r );
    if( record.inclusion && self.maskDir )
    record.inclusion = self.maskDir.test( r );
  }
  else
  {
    if( record.inclusion && self.maskAll )
    record.inclusion = self.maskAll.test( r );
    if( record.inclusion && self.maskTerminal )
    record.inclusion = self.maskTerminal.test( r );
  }

  return record.inclusion;
}

//

function _testFull( record )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( record.inclusion === false )
  return record.inclusion;

  self._testMasks( record );

  if( record.inclusion === false )
  return record.inclusion;

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
    if( self.notOlder !== null )
    {
      debugger;
      record.inclusion = time >= self.notOlder;
    }

    if( record.inclusion === true )
    if( self.notNewer !== null )
    {
      debugger;
      record.inclusion = time <= self.notNewer;
    }

    if( record.inclusion === true )
    if( self.notOlderAge !== null )
    {
      debugger;
      record.inclusion = _.timeNow() - self.notOlderAge - time <= 0;
    }

    if( record.inclusion === true )
    if( self.notNewerAge !== null )
    {
      debugger;
      record.inclusion = _.timeNow() - self.notNewerAge - time >= 0;
    }
  }

  return record.inclusion;
}

// --
//
// --

var Composes =
{

  globIn : null,

  hasExtension : null,
  begins : null,
  ends : null,

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

var Aggregates =
{

  filePath : null,
  basePath : null,

  test : null,

}

var Associates =
{
  fileProvider : null,
}

var Restricts =
{
  globOut : null,
  formed : 0,
}

var Statics =
{
  tollerantMake : tollerantMake,
  all : all_static,
}

var Globals =
{
}

var Forbids =
{
  options : 'options',
}

var Accessors =
{
}

// --
// define class
// --

var Proto =
{

  tollerantMake : tollerantMake,

  init : init,
  form : form,

  formGlob : formGlob,
  formMasks : formMasks,

  pathFromGlob : pathFromGlob,

  and : and,

  _testNothing : _testNothing,
  _testMasks : _testMasks,
  _testFull : _testFull,

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

// --
// export
// --

_[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
