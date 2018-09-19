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

// --
//
// --

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

function TollerantMake( o )
{
  _.assert( arguments.length >= 1, 'expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function And()
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
  _.assert( src._glob === null || src._glob === undefined );

  if( src === self )
  return self;

  let once =
  {
    // glob : null,
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

function fromOptions( o )
{
  let filter = this;

  _.assert( arguments.length === 1 );
  _.assert( !filter.formed, 'This filter is already formed' );
  _.assert( filter.filePath === null );
  _.assert( filter.basePath === null );
  _.assert( filter.prefixPath === null );
  _.assert( filter.postfixPath === null );

  filter.filePath = o.filePath;
  filter.basePath = o.basePath;
  filter.prefixPath = o.prefixPath;
  filter.postfixPath = o.postfixPath;

}

//

function toOptions( o )
{
  let filter = this;

  _.assert( arguments.length === 1 );

  o.filePath = filter.filePath;
  o.basePath = filter.basePath;
  o.prefixPath = filter.prefixPath;
  o.postfixPath = filter.postfixPath;

}

//

function form()
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  _.assert( self.formed === 0 );
  _.assert( self.fileProvider instanceof _.FileProvider.Abstract );

  self.formGlob();
  self.formMasks();

  _.assert( _.strIs( self.filePath ) || _.arrayIs( self.filePath ) );

  if( _.arrayIs( self.filePath ) && self.filePath.length === 1 )
  self.filePath = self.filePath[ 0 ];

  // if( _.mapIs( self.filePath ) )
  // {
  //   let keys = _.mapKeys( self.filePath );
  //   if( keys.length === 1 && self.filePath[ keys[ 0 ] ] )
  //   self.filePath = keys[ 0 ];
  // }

  self.branchPath = self.filePath;

  self.formed = 1;
  self.test = self._testNothing;

  if( self.notOlder || self.notNewer || self.notOlderAge || self.notNewerAge )
  self.test = self._testFull;
  else if( self.hasMask() )
  self.test = self._testMasks;

  _.assert( path.s.allAreAbsolute( self.filePath ) );
  _.assert( path.isAbsolute( self.basePath ) && !path.isGlob( self.basePath ) );

  Object.freeze( self );
  return self;
}

//

function formGlob()
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

  if( self.prefixPath === null )
  self.prefixPath = self.basePath;

  _.assert( !self.globOut );
  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );
  _.assert( self._glob === null );
  _.assert( self.prefixPath === null || _.strIs( self.prefixPath ) || _.arrayIs( self.prefixPath ) );
  _.assert( self.postfixPath === null || _.strIs( self.postfixPath ) || _.arrayIs( self.postfixPath ) );

  // if( self.globOut !== null )
  // return;

  let fixes = _.multipleAll([ self.prefixPath || '', self.postfixPath || '' ]);
  self._glob = path.s.join( fixes[ 0 ], self.filePath, fixes[ 1 ] );
  self._glob = path.globMapExtend( null, self._glob );

  /* */

  if( self.basePath === null )
  {
    self.basePath = _.mapKeys( self._glob ).filter( ( g ) => path.isAbsolute( g ) );
    self.basePath = self.basePath.map( ( g ) => path.fromGlob( g ) );
    if( self.basePath.length > 0 )
    self.basePath = path.common.apply( path, self.basePath );
    _.sure( _.strIsNotEmpty( self.basePath ), 'Cant deduce prefixPath' );
  }

  if( _.none( path.s.areGlob( self._glob ) ) )
  {
    self._glob = null;
    return;
  }

  /* */

  // if( self.prefixPath === null )
  // self.prefixPath = self.basePath;

  /* */

  for( let g in self._glob )
  {
    let glob = path.s.join( self.basePath, g );
    if( glob !== g )
    {
      let value = self._glob[ g ];
      delete self._glob[ g ];
      path.globMapExtend( self._glob, glob, value );
    }
  }

  /* */

  self.filePath = null;

  // self.prefixPath = path.s.detrail( self.prefixPath );
  self.basePath = path.detrail( self.basePath );

  // _.assert( self.postfixPath === null || ( _.strIs( self.postfixPath ) && !path.isGlob( self.postfixPath ) ) );
  // _.assert( path.s.allAreAbsolute( self.prefixPath ) );
  // _.assert( path.isAbsolute( self.basePath ) && !path.isGlob( self.basePath ) );

  // _.assert( _.strIs( self.prefixPath ) && !path.isGlob( self.prefixPath ) ||  );
  // _.assert( _.strIs( self.basePath ) && !path.isGlob( self.basePath ) );

  /* */

  if( self._glob === null )
  return;

  self.globOut = [ self._glob, self.basePath ];

}

//

function formMasks()
{
  let self = this;
  let fileProvider = self.fileProvider;
  let path = fileProvider.path;

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

    // let globRegexps = path.globRegexpsFor2( self.globOut[ 0 ], self.globOut[ 1 ], self.globOut[ 2 ] );
    // self.maskAll = _.RegexpObject.shrink( self.maskAll, { includeAny : globRegexps.terminal } );
    // self.maskTransientTerminal = _.RegexpObject.shrink( self.maskTransientTerminal, { includeAny : /$_^/ } );
    // self.maskTransientDirectory = _.RegexpObject.shrink( self.maskTransientAll, { includeAny : globRegexps.directory } );

    _.assert( self.byPath === null );
    self.byPath = Object.create( null );
    let processed = path.globMapToRegexps.apply( path, self.globOut );

    self.filePath = _.mapKeys( processed.regexpMap );
    for( let p in processed.regexpMap )
    {
      let relative = path.relative( self.basePath, p );
      let regexps = processed.regexpMap[ p ];
      let filter = self.byPath[ relative ] = Object.create( null );
      filter.maskAll = _.RegexpObject.shrink( self.maskAll.clone(), { includeAny : regexps.actual, excludeAny : regexps.notActual } );
      filter.maskTerminal = self.maskTerminal.clone();
      filter.maskDirectory = self.maskDirectory.clone();
      filter.maskTransientAll = self.maskTransientAll.clone();
      filter.maskTransientTerminal = _.RegexpObject.shrink( self.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      filter.maskTransientDirectory = _.RegexpObject.shrink( self.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( self.maskAll !== filter.maskAll );
    }

    // self.maskAll = _.RegexpObject.shrink( self.maskAll, { includeAny : globRegexps.actual, excludeAny : globRegexps.notActual } );
    // self.maskTransientTerminal = _.RegexpObject.shrink( self.maskTransientTerminal, { includeAny : /$_^/ } );
    // self.maskTransientDirectory = _.RegexpObject.shrink( self.maskTransientDirectory, { includeAny : globRegexps.transient } );

  }

  self.globOut = null;

  /* */

  if( Config.debug )
  {

    if( self.notOlder )
    _.assert( _.numberIs( self.notOlder ) || _.dateIs( self.notOlder ) );

    if( self.notNewer )
    _.assert( _.numberIs( self.notNewer ) || _.dateIs( self.notNewer ) );

    if( self.notOlderAge )
    _.assert( _.numberIs( self.notOlderAge ) || _.dateIs( self.notOlderAge )  );

    if( self.notNewerAge )
    _.assert( _.numberIs( self.notNewerAge ) || _.dateIs( self.notNewerAge ) );

  }

}

//

function hasMask()
{
  let filter = this;

  if( filter.byPath )
  return true;

  let hasMask = false;

  hasMask = hasMask || !filter.maskAll.isEmpty();
  hasMask = hasMask || !filter.maskTerminal.isEmpty();
  hasMask = hasMask || !filter.maskDirectory.isEmpty();
  hasMask = hasMask || !filter.maskTransientAll.isEmpty();
  hasMask = hasMask || !filter.maskTransientTerminal.isEmpty();
  hasMask = hasMask || !filter.maskTransientDirectory.isEmpty();

  return hasMask;
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
  let relative = record.relative;
  let c = record.context;
  let path = record.path;
  let filter = self.byPath ? self.byPath[ path.relative( c.basePath, c.branchPath ) ] : self;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!filter, 'Cant resolve filter for start path', () => _.strQuote( c.branchPath ) );

  // if( _.strHas( record.absolute, '/src1' ) )
  // debugger;

  /* */

  if( record.isDir )
  {

    if( record.isTransient && filter.maskTransientAll )
    record.isTransient = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientDirectory )
    record.isTransient = filter.maskTransientDirectory.test( relative );

    if( record.isActual && filter.maskAll )
    record.isActual = filter.maskAll.test( relative );
    if( record.isActual && filter.maskDirectory )
    record.isActual = filter.maskDirectory.test( relative );

  }
  else
  {

    if( record.isActual && filter.maskAll )
    record.isActual = filter.maskAll.test( relative );
    if( record.isActual && filter.maskTerminal )
    record.isActual = filter.maskTerminal.test( relative );

    if( record.isTransient && filter.maskTransientAll )
    record.isTransient = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientTerminal )
    record.isTransient = filter.maskTransientTerminal.test( relative );

  }

  /* */

  // logger.log( '_testMasks', record.absolute, record.isTransient, record.isActual );
  // if( _.strHas( record.absolute, '/doubledir/d1' ) )
  // debugger;
  // if( _.strHas( record.absolute, '/doubledir/d1/b' ) )
  // debugger;
  // if( _.strHas( record.absolute, '/doubledir/d2/b' ) )
  // debugger;
  // if( record.absolute === '/doubledir/d1/a' )
  // debugger;
  // debugger;

  return record.isActual;
}

//

function _testTime( record )
{
  let self = this;

  _.assert( arguments.length === 1, 'expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  if( !record.isDir )
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

  byPath : null,
  _glob : null,
  // recipe : null,

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
  prefixPath : null,
  postfixPath : null,

  basePath : null,
  branchPath : null,

  test : null,

}

let Associates =
{
  fileProvider : null,
}

let Restricts =
{
  globOut : null,
  formed : 0,
}

let Statics =
{
  TollerantMake : TollerantMake,
  And : And,
}

let Globals =
{
}

let Forbids =
{
  options : 'options',
  glob : 'glob',
  recipe : 'recipe',
}

let Accessors =
{
}

// --
// declare
// --

let Proto =
{

  init : init,

  TollerantMake : TollerantMake,
  And : And,
  and : and,

  fromOptions : fromOptions,
  toOptions : toOptions,

  form : form,
  formGlob : formGlob,
  formMasks : formMasks,

  hasMask : hasMask,

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
