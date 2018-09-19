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
  let path = fileProvider.path;

  _.assert( !self.globOut );
  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );

  if( self.globOut !== null )
  return;

  _.assert( self._glob === null );

  if( self.prefixPath === null )
  self.prefixPath = self.basePath;

  let fixes = _.multipleAll([ self.prefixPath || '', self.postfixPath || '' ]);
  self._glob = path.s.join( fixes[ 0 ], self.filePath, fixes[ 1 ] );
  self._glob = path.globMapExtend( null, self._glob );

  if( _.none( path.s.areGlob( self._glob ) ) )
  {
    self._glob = null;
    return;
  }

  /* */

  if( self.basePath === null )
  {
    self.basePath = _.mapKeys( self._glob ).filter( ( g ) => path.isAbsolute( g ) );
    self.basePath = self.basePath.map( ( g ) => path.fromGlob( g ) );
    if( self.basePath.length > 0 )
    self.basePath = path.common.apply( path, self.basePath );
    _.sure( _.strIsNotEmpty( self.basePath ), 'Cant deduce prefixPath' );
  }

  /* */

  if( self.prefixPath === null )
  self.prefixPath = self.basePath;

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

  self.prefixPath = path.s.detrail( self.prefixPath );
  self.basePath = path.detrail( self.basePath );

  _.assert( self.postfixPath === null || ( _.strIs( self.postfixPath ) && !path.isGlob( self.postfixPath ) ) );
  _.assert( path.s.allAre( self.prefixPath ) /*&& path.s.noneAreGlob( self.prefixPath )*/ );
  _.assert( _.strIs( self.basePath ) && !path.isGlob( self.basePath ) );

  // _.assert( _.strIs( self.prefixPath ) && !path.isGlob( self.prefixPath ) ||  );
  // _.assert( _.strIs( self.basePath ) && !path.isGlob( self.basePath ) );

  /* */

  if( self._glob === null )
  return;

  self.globOut = [ self._glob, self.basePath ];

}

  //
  // if( self.filePath === null )
  // self.filePath = self.basePath;
  // else if( self.basePath === null )
  // self.basePath = self.filePath;
  //
  // self.glob = path.globMapExtend( null, self.glob );
  //
  // debugger;
  // if( _.none( path.s.areGlob( self.glob ) ) )
  // {
  //   debugger;
  //   return;
  // }
  //
  // if( self.basePath === null )
  // {
  //   self.basePath = _.mapKeys( self.glob ).filter( ( g ) => path.isAbsolute( g ) );
  //   if( self.basePath.length > 1 )
  //   self.basePath = path.common.apply( path, self.basePath );
  //   _.sure( _.strIs( self.basePath ), 'Cant deduce prefixPath' );
  //   self.filePath = self.basePath;
  // }
  //
  // for( let g in self.glob )
  // {
  //   let glob = path.join( self.filePath, g );
  //   glob = path.relative( self.basePath, glob );
  //   if( glob !== g )
  //   {
  //     let value = self.glob[ g ];
  //     delete self.glob[ g ];
  //     if( !value || self.glob[ glob ] === undefined )
  //     self.glob[ glob ] = value;
  //   }
  // }

  // self.glob = path.globMapExtend( null, self.glob );
  //
  // if( _.arrayIs( self.filePath ) && self.filePath.length === 0 )
  // self.filePath = null;
  //
  // debugger;
  //
  // if( !self.filePath )
  // {
  //   self.filePath = _.mapVals( _.entityFilter( self.glob, ( v, glob ) => path.fromGlob( glob ) ) );
  //   self.filePath = self.filePath.filter( ( e ) => path.isAbsolute( e ) );
  //   if( self.filePath.length === 1 )
  //   self.filePath = self.filePath[ 0 ];
  // }
  // else if( _.mapIs( self.filePath ) )
  // {
  //   debugger;
  //
  // }
  //
  // if( _.arrayIs( self.filePath ) && self.filePath.length === 0 )
  // self.filePath = null;
  //
  // if( self.filePath === null )
  // self.filePath = self.basePath;
  //
  // _.sure( !!self.filePath, 'Cant deduce filePath' );
  //
  // if( !self.basePath )
  // {
  //   if( _.arrayIs( self.filePath ) )
  //   self.basePath = path.common.apply( path, self.filePath );
  //   else
  //   self.basePath = self.filePath;
  // }
  //
  // self.filePath = path.s.join( self.basePath, self.filePath );
  //
  // _.assert( path.isAbsolute( self.basePath ), () => 'Expects absolute {-basePath-}, but got ' + self.basePath );
  //
  // let isAbsolute1 = ( path.is( self.filePath ) && path.isAbsolute( self.filePath ) );
  // let isAbsolute2 = ( path.are( self.filePath ) && _.all( path.s.areAbsolute( self.filePath ) ) );
  //
  // // let isAbsolute1 = path.isAbsolute( self.filePath );
  // // let isAbsolute2 = _.all( path.s.areAbsolute( self.filePath ) );
  //
  // _.assert( isAbsolute1 || isAbsolute2 );
  //
  // // _.assert( _.all( self.filePath, ( p ) => path.isAbsolute( p ) ), () => 'Expects absolute path, but got\n' + _.toStr( self.filePath ) );
  // // _.assert( _.strIs( self.filePath ) || _.strsAre( self.filePath ) );
  //
  // self.globOut = [ self.glob, self.filePath, self.basePath ];
//
// }

// function formGlob()
// {
//   let self = this;
//   let fileProvider = self.fileProvider;
//
//   _.assert( !self.globOut );
//
//   if( self.globOut !== null || self.glob === null )
//   return;
//
//   _.assert( arguments.length === 0 );
//   _.assert( _.objectIs( self ) );
//   _.assert( _.strIs( self.glob ) || _.arrayIs( self.glob ) );
//
//   self.glob = fileProvider.path.pathsNormalize( self.glob );
//
//   if( !self.filePath )
//   {
//     if( _.arrayIs( self.glob ) )
//     self.filePath = _.entityFilter( self.glob, ( glob ) => fileProvider.path.fromGlob( glob ) );
//     else
//     self.filePath = fileProvider.path.fromGlob( self.glob );
//   }
//
//   if( !self.basePath )
//   {
//     if( _.arrayIs( self.filePath ) )
//     self.basePath = fileProvider.path.common( self.filePath );
//     else
//     self.basePath = self.filePath;
//   }
//
//   _.assert( fileProvider.path.isAbsolute( self.basePath ), () => 'Expects absolute {-basePath-}, but got ' + self.basePath );
//   _.assert( _.all( self.filePath, ( path ) => fileProvider.path.isAbsolute( path ) ), () => 'Expects absolute path, but got\n' + _.toStr( self.filePath ) );
//   _.assert( _.strIs( self.filePath ) || _.strsAre( self.filePath ) );
//
//   self.globOut = [ self.glob, self.filePath, self.basePath ];
//
// }

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
  let relative = record.relative;
  let c = record.context;
  let path = record.path;
  debugger;
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
  basePath : null,
  prefixPath : null,
  postfixPath : null,

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
  all : all_static,
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

  fromOptions : fromOptions,
  toOptions : toOptions,

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
