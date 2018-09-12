( function _FileRecordFilter_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecordFilter( c )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileRecordFilter';

_.assert( !_.FileRecordFilter );
_.assert( !!_.regexpsEscape );

//

function tollerantMake( o )
{
  _.assert( arguments.length >= 1, 'expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function init( o )
{
  let self = this;

  _.instanceInit( self );
  Object.preventExtensions( self );

  if( o )
  {

    // if( o.maskAll )
    // o.maskAll = _.RegexpObject( o.maskAll,'includeAny' );
    // if( o.maskTerminal )
    // o.maskTerminal = _.RegexpObject( o.maskTerminal,'includeAny' );
    // if( o.maskDirectory )
    // o.maskDirectory = _.RegexpObject( o.maskDirectory,'includeAny' );

    self.copy( o );

  }

  return self;
}

//

function form()
{
  let self = this;

  _.assert( self.formed === 0 );
  _.assert( self.fileProvider instanceof _.FileProvider.Abstract );

  self.formGlob();
  self.formMasks();

  self.test = self._testNothing;

  let isEmpty = true;
  isEmpty = isEmpty && self.maskAll.isEmpty();
  isEmpty = isEmpty && self.maskTerminal.isEmpty();
  isEmpty = isEmpty && self.maskDirectory.isEmpty();
  isEmpty = isEmpty && self.maskTransientAll.isEmpty();
  isEmpty = isEmpty && self.maskTransientTerminal.isEmpty();
  isEmpty = isEmpty && self.maskTransientDirectory.isEmpty();

  if( self.notOlder || self.notNewer || self.notOlderAge || self.notNewerAge )
  self.test = self._testFull;
  else if( !isEmpty )
  self.test = self._testMasks;

  // _.assert( self.maskAll === null || _.regexpObjectIs( self.maskAll ) );
  // _.assert( self.maskTerminal === null || _.regexpObjectIs( self.maskTerminal ) );
  // _.assert( self.maskDirectory === null || _.regexpObjectIs( self.maskDirectory ) );

  self.formed = 1;
  Object.freeze( self );
  return self;
}

//

function formGlob()
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.assert( !self.globOut );

  if( self.globOut !== null || self.glob === null )
  return;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );
  _.assert( _.strIs( self.glob ) || _.arrayIs( self.glob ) );

  self.glob = fileProvider.path.pathsNormalize( self.glob );

  if( !self.filePath )
  {
    if( _.arrayIs( self.glob ) )
    self.filePath = _.entityFilter( self.glob,( glob ) => fileProvider.path.fromGlob( glob ) );
    else
    self.filePath = fileProvider.path.fromGlob( self.glob );
  }

  if( !self.basePath )
  {
    if( _.arrayIs( self.filePath ) )
    self.basePath = fileProvider.path.common( self.filePath );
    else
    self.basePath = self.filePath;
  }

  _.assert( fileProvider.path.isAbsolute( self.basePath ), () => 'Expects absolute {-basePath-}, but got ' + self.basePath );
  _.assert( _.all( self.filePath, ( path ) => fileProvider.path.isAbsolute( path ) ), () => 'Expects absolute path, but got\n' + _.toStr( self.filePath ) );
  _.assert( _.strIs( self.filePath ) || _.strsAre( self.filePath ) );

  self.globOut = [ self.glob, self.filePath, self.basePath ];

}

//

function formMasks()
{
  let self = this;
  let fileProvider = self.fileProvider;

  _.assert( arguments.length === 0 );

  /* */

  self.maskAll = _.regexpMakeObject( self.maskAll || Object.create( null ), 'includeAny' );
  self.maskTerminal = _.regexpMakeObject( self.maskTerminal || Object.create( null ), 'includeAny' );
  self.maskDirectory = _.regexpMakeObject( self.maskDirectory || Object.create( null ), 'includeAny' );

  self.maskTransientAll = _.regexpMakeObject( self.maskTransientAll || Object.create( null ), 'includeAny' );
  self.maskTransientTerminal = _.regexpMakeObject( self.maskTransientTerminal || Object.create( null ), 'includeAny' );
  self.maskTransientDirectory = _.regexpMakeObject( self.maskTransientDirectory || Object.create( null ), 'includeAny' );

  /* */

  if( self.hasExtension )
  {
    _.assert( _.strIs( self.hasExtension ) || _.strsAre( self.hasExtension ) );

    self.hasExtension = _.arrayAs( self.hasExtension );
    self.hasExtension = new RegExp( '^\\.\\/.+\\.(' + _.regexpsEscape( self.hasExtension ).join( '|' ) + ')$', 'i' );

    self.maskAll = _.RegexpObject.shrink( self.maskAll,{ includeAll : self.hasExtension } );
    self.hasExtension = null;
  }

  if( self.begins )
  {
    _.assert( _.strIs( self.begins ) || _.strsAre( self.begins ) );

    self.begins = _.arrayAs( self.begins );
    self.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( self.begins ).join( '|' ) + ')' );

    self.maskAll = _.RegexpObject.shrink( self.maskAll,{ includeAll : self.begins } );
    self.begins = null;
  }

  if( self.ends )
  {
    _.assert( _.strIs( self.ends ) || _.strsAre( self.ends ) );

    self.ends = _.arrayAs( self.ends );
    self.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( self.ends ).join( '|' ) + ')$' );

    self.maskAll = _.RegexpObject.shrink( self.maskAll,{ includeAll : self.ends } );
    self.ends = null;
  }

  /* */

  if( self.globOut )
  {

    if( self.maskTerminal.includeAny.length )
    debugger;
    if( self.maskDirectory.includeAny.length )
    debugger;

    let globRegexps = fileProvider.path.globRegexpsFor2( self.globOut[ 0 ], self.globOut[ 1 ], self.globOut[ 2 ] );
    self.maskAll = _.RegexpObject.shrink( self.maskAll, { includeAny : globRegexps.terminal } );
    // self.maskTerminal = _.RegexpObject.shrink( self.maskTerminal, { includeAny : globRegexps.terminal } );
    // self.maskDirectory = _.RegexpObject.shrink( self.maskDirectory, { includeAny : /$_^/ } );
    self.maskTransientTerminal = _.RegexpObject.shrink( self.maskTransientTerminal, { includeAny : /$_^/ } );
    self.maskTransientDirectory = _.RegexpObject.shrink( self.maskTransientAll, { includeAny : globRegexps.directory } );
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

function and( src )
{
  let self = this;

  _.assert( _.instanceIs( self ) );

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    self.and( arguments[ a ] );
    return self;
  }

  _.assert( !self.formed );
  _.assert( arguments.length === 1, 'expects single argument' );
  if( Config.debug )
  if( src && !( src instanceof self.Self ) )
  _.assertMapHasOnly( src, self.fieldsOfCopyableGroups );

  if( src === self )
  return self;

  let once =
  {
    glob : null,
    hasExtension : null,
    begins : null,
    ends : null,
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
  }

  for( let n in once )
  {
    _.assert( !self[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field', n );
    if( src[ n ] )
    self[ n ] = src[ n ];
  }

  /* */

  self.maskAll = _.RegexpObject.Shrink( self.maskAll, src.maskAll );
  self.maskTerminal = _.RegexpObject.Shrink( self.maskTerminal, src.maskTerminal );
  self.maskDirectory = _.RegexpObject.Shrink( self.maskDirectory, src.maskDirectory );

  self.maskTransientAll = _.RegexpObject.Shrink( self.maskTransientAll, src.maskTransientAll );
  self.maskTransientTerminal = _.RegexpObject.Shrink( self.maskTransientTerminal, src.maskTransientTerminal );
  self.maskTransientDirectory = _.RegexpObject.Shrink( self.maskTransientDirectory, src.maskTransientDirectory );

}

//

function all_static()
{
  _.assert( !_.instanceIs( this ) );

  let dstFilter = null;

  if( arguments.length === 1 )
  return this.Self( arguments[ 0 ] );

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let srcFilter = arguments[ a ];

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
  let self = this;
  return record.isActual;
}

//

function _testMasks( record )
{
  let self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.strHas( record.absolute, '/src1' ) )
  debugger;

  let relative = record.relative;

  /* */

  if( record._isDir() )
  {
    if( record.isTransient && self.maskTransientAll )
    record.isTransient = self.maskTransientAll.test( relative );
    if( record.isTransient && self.maskTransientDirectory )
    record.isTransient = self.maskTransientDirectory.test( relative );
  }
  else
  {
    if( record.isTransient && self.maskTransientAll )
    record.isTransient = self.maskTransientAll.test( relative );
    if( record.isTransient && self.maskTransientTerminal )
    record.isTransient = self.maskTransientTerminal.test( relative );
  }

  /* */

  if( record._isDir() )
  {
    if( record.isActual && self.maskAll )
    record.isActual = self.maskAll.test( relative );
    if( record.isActual && self.maskDirectory )
    record.isActual = self.maskDirectory.test( relative );
  }
  else
  {
    if( record.isActual && self.maskAll )
    record.isActual = self.maskAll.test( relative );
    if( record.isActual && self.maskTerminal )
    record.isActual = self.maskTerminal.test( relative );
  }

  /* */

  // logger.log( '_testMasks', record.absolute, record.isTransient, record.isActual );
  if( _.strHas( record.absolute, '/src1' ) )
  debugger;
  return record.isActual;
}

//

function _testTime( record )
{
  let self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  if( !record._isDir() )
  {
    let time;
    if( record.isActual === true )
    {
      time = record.stat.mtime;
      if( record.stat.birthtime > record.stat.mtime )
      time = record.stat.birthtime;
    }

    if( record.isActual === true )
    if( self.notOlder !== null )
    {
      debugger;
      record.isActual = time >= self.notOlder;
    }

    if( record.isActual === true )
    if( self.notNewer !== null )
    {
      debugger;
      record.isActual = time <= self.notNewer;
    }

    if( record.isActual === true )
    if( self.notOlderAge !== null )
    {
      debugger;
      record.isActual = _.timeNow() - self.notOlderAge - time <= 0;
    }

    if( record.isActual === true )
    if( self.notNewerAge !== null )
    {
      debugger;
      record.isActual = _.timeNow() - self.notNewerAge - time >= 0;
    }
  }

  return record.isActual;
}

//

function _testFull( record )
{
  let self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  self._testMasks( record );
  self._testTime( record );

  return record.isActual;
}

// --
//
// --

let Composes =
{

  glob : null,

  hasExtension : null,
  begins : null,
  ends : null,

  maskTransientAll : null,
  maskTransientTerminal : null,
  maskTransientDirectory : null,
  maskAll : null,
  maskTerminal : null,
  maskDirectory : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

let Aggregates =
{

  filePath : null,
  basePath : null,
  test : null,

}

let Associates =
{
  fileProvider : null,
}

let Restricts =
{
  globOut : null,
  // globOptional : null,
  formed : 0,
}

let Statics =
{
  tollerantMake : tollerantMake,
  all : all_static,
}

let Globals =
{
}

let Forbids =
{
  options : 'options',
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  tollerantMake : tollerantMake,

  init : init,
  form : form,

  formGlob : formGlob,
  formMasks : formMasks,

  and : and,

  _testNothing : _testNothing,
  _testMasks : _testMasks,
  _testTime : _testTime,
  _testFull : _testFull,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
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

_.mapExtend( _,Globals );

if( _global_.wCopyable )
_.Copyable.mixin( Self );

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
