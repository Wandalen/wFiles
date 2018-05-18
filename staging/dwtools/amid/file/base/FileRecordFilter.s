( function _FileRecordFilter_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

var _ = _global_.wTools;
_.assert( !_.FileRecordFilter );

//

var _ = _global_.wTools;
var Parent = null;
var Self = function wFileRecordFilter( c )
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

Self.nameShort = 'FileRecordFilter';

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1 );
  _.assert( _.FileRecordFilter.prototype.Composes );

  if( arguments.length > 1 )
  {
    var o = Object.create( null );
    for( var r = 0 ; r < arguments.length ; r++ )
    _.mapExtend( o, arguments[ r ] );
  }

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
  // _.assert( self/*.options*/ );

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

  _.assert( self.glob === undefined );
  _.assert( !self.globOut );

  if( !self.globIn )
  return;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );
  _.assert( _.strIs( self.globIn ) || _.arrayIs( self.globIn ) );
  _.assert( self.relative === undefined );

  self.globIn = fileProvider.pathsNormalize( self.globIn );

  function pathFromGlob( globIn )
  {
    var result;
    _.assert( _.strIs( globIn ) );
    var i = globIn.search( /[^\\\/]*?(\*\*|\?|\*|\[.*\]|\{.*\}+(?![^[]*\]))[^\\\/]*/ );
    if( i === -1 )
    result = globIn;
    else
    result = fileProvider.pathNormalize( globIn.substr( 0,i ) );
    if( !result )
    result = _.pathRealMainDir();
    return result;
  }

  if( !self/*.options*/.filePath )
  {
    if( _.arrayIs( self.globIn ) )
    self/*.options*/.filePath = _.entityFilter( self.globIn,( globIn ) => pathFromGlob( globIn ) );
    else
    self/*.options*/.filePath = pathFromGlob( self.globIn );
  }

  if( !self/*.options*/.basePath )
  {
    if( _.arrayIs( self/*.options*/.filePath ) )
    self/*.options*/.basePath = _.pathCommon( self/*.options*/.filePath );
    else
    self/*.options*/.basePath = self/*.options*/.filePath;
  }

  _.assert( _.strIs( self/*.options*/.filePath ) || _.strsAre( self/*.options*/.filePath ) );

  function globAdjust( globIn )
  {

    var basePath = _.strAppendOnce( self/*.options*/.basePath,'/' );
    if( !_.strBegins( globIn,basePath ) )
    basePath = self/*.options*/.basePath;

    if( _.strBegins( globIn,basePath ) )
    {
      globIn = globIn.substr( basePath.length, globIn.length );
    }

    return globIn;
  }

  if( _.arrayIs( self.globIn ) )
  self.globOut = _.entityFilter( self.globIn,( globIn ) => globAdjust( globIn ) );
  else
  self.globOut = globAdjust( self.globIn );

  self.globIn = null;

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
    // var globRegexp = _.regexpForGlob( self.globOut );
    var globRegexp = _.regexpForGlob2( self.globOut );
    self.maskTerminal = _.RegexpObject.shrink( self.maskTerminal,{ includeAll : globRegexp } );
  }
  self.globOut = null;
  // delete self.globOut;

  /* */

  if( self.notOlder )
  _.assert( _.numberIs( self.notOlder ) );

  if( self.notNewer )
  _.assert( _.numberIs( self.notNewer ) );

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

  _.assert( arguments.length === 1 );

  if( record.inclusion === false )
  return record.inclusion;

  var r = record.relative;
  if( record.relative === '.' )
  r = _.pathDot( record.nameWithExt );

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

  _.assert( arguments.length === 1 );

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
  // options : null,
}

var Restricts =
{
  globOut : null,
  formed : 0,
}

var Statics =
{
  tollerantMake : tollerantMake,
}

var Globals =
{
}

var Forbids =
{
}

var Accessors =
{
}

// --
// prototype
// --

var Proto =
{

  tollerantMake : tollerantMake,

  init : init,
  form : form,

  formGlob : formGlob,
  formMasks : formMasks,

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
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
