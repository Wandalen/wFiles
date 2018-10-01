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

  if( self.hubFileProvider && self.hubFileProvider.hub && self.hubFileProvider.hub !== self.hubFileProvider )
  {
    _.assert( self.effectiveFileProvider === null || self.effectiveFileProvider === self.hubFileProvider );
    self.effectiveFileProvider = self.hubFileProvider;
    self.hubFileProvider = self.hubFileProvider.hub;
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

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    self.and( arguments[ a ] );
    return self;
  }

  if( Config.debug )
  if( src && !( src instanceof self.Self ) )
  _.assertMapHasOnly( src, self.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( self ) );
  _.assert( !self.formed );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( src.globMap === null || src.globMap === undefined );
  _.assert( self.globMap === null );
  _.assert( self.filterMap === null );
  _.assert( self.test === null );
  _.assert( !self.formed );

  // _.assert( src.inFilePath === null || src.inFilePath === undefined );
  // _.assert( src.basePath === null || src.basePath === undefined );
  // _.assert( self.inFilePath === null );
  // _.assert( self.basePath === null );

  _.assert( !!( self.hubFileProvider || src.hubFileProvider ) );
  _.assert( !self.effectiveFileProvider || !src.effectiveFileProvider || self.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !self.hubFileProvider || !src.hubFileProvider || self.hubFileProvider === src.hubFileProvider );
  _.assert( self.inFilePath === null );
  _.assert( src.inFilePath === null || src.inFilePath === undefined );

  if( src === self )
  return self;

  /* */

  if( src.effectiveFileProvider )
  self.effectiveFileProvider = src.effectiveFileProvider

  if( src.hubFileProvider )
  self.hubFileProvider = src.hubFileProvider

  /* */

  // if( src.basePath )
  // {
  //   _.assert( _.strIs( src.basePath ) );
  //   _.assert( self.basePath === null || _.strIs( self.basePath ) );
  //   self.basePath = path.joinIfDefined( self.basePath, src.basePath );
  // }
  //
  // if( src.prefixPath )
  // self.prefixPath = path.s.joinIfDefined( self.prefixPath, src.prefixPath );
  // if( src.postfixPath )
  // self.postfixPath = path.s.joinIfDefined( self.postfixPath, src.postfixPath  );

  /* */

  let appending =
  {

    hasExtension : null,
    begins : null,
    ends : null,

  }

  for( let a in appending )
  {
    if( src[ a ] === null || src[ a ] === undefined )
    continue;
    _.assert( _.strIs( src[ a ] ) || _.strsAre( src[ a ] ) );
    _.assert( self[ a ] === null || _.strIs( self[ a ] ) || _.strsAre( self[ a ] ) );
    if( self[ a ] === null )
    {
      self[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( self[ a ] ) )
      self[ a ] = [ self[ a ] ];
      _.arrayAppendOnce( self[ a ], src[ a ] );
    }
  }

  /* */

  let once =
  {
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

  self.maskAll = _.RegexpObject.And( self.maskAll, src.maskAll || null );
  self.maskTerminal = _.RegexpObject.And( self.maskTerminal, src.maskTerminal || null );
  self.maskDirectory = _.RegexpObject.And( self.maskDirectory, src.maskDirectory || null );

  self.maskTransientAll = _.RegexpObject.And( self.maskTransientAll, src.maskTransientAll || null );
  self.maskTransientTerminal = _.RegexpObject.And( self.maskTransientTerminal, src.maskTransientTerminal || null );
  self.maskTransientDirectory = _.RegexpObject.And( self.maskTransientDirectory, src.maskTransientDirectory || null );

  return self;
}

//

function pathsJoin( src )
{
  let self = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    self.pathsJoin( arguments[ a ] );
    return self;
  }

  if( Config.debug )
  if( src && !( src instanceof self.Self ) )
  _.assertMapHasOnly( src, self.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( self ) );
  _.assert( !self.formed );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( src.globMap === null || src.globMap === undefined );
  _.assert( self.globMap === null );
  _.assert( self.filterMap === null );
  _.assert( self.test === null );
  _.assert( !self.formed );

  _.assert( src.inFilePath === null || src.inFilePath === undefined );
  // _.assert( src.basePath === null || src.basePath === undefined );
  _.assert( self.inFilePath === null );
  // _.assert( self.basePath === null );
  // _.assert( !!( self.effectiveFileProvider || src.effectiveFileProvider ) );
  // _.assert( !self.effectiveFileProvider || !src.effectiveFileProvider || self.effectiveFileProvider === src.fileProvider );
  _.assert( !self.hubFileProvider || !src.hubFileProvider || self.hubFileProvider === src.hubFileProvider );
  _.assert( src !== self );
  _.assert( self.inFilePath === null );
  _.assert( src.inFilePath === null || src.inFilePath === undefined );

  let fileProvider = self.effectiveFileProvider || self.hubFileProvider || src.effectiveFileProvider || sec.hubFileProvider;
  let path = fileProvider.path;

  /* */

  // if( src.effectiveFileProvider )
  // self.effectiveFileProvider = src.effectiveFileProvider;
  if( src.hubFileProvider )
  self.hubFileProvider = src.hubFileProvider;

  /* */

  if( src.basePath !== undefined )
  {
    _.assert( src.basePath === null || _.strIs( src.basePath ) );
    _.assert( self.basePath === null || _.strIs( self.basePath ) );
    self.basePath = path.joinIfDefined( self.basePath, src.basePath );
  }

  if( src.branchPath !== undefined )
  {
    _.assert( src.branchPath === null || _.strIs( src.branchPath ) || _.arrayIs( src.branchPath ) );
    _.assert( self.branchPath === null || _.strIs( self.branchPath ) || _.arrayIs( self.branchPath ) );
    self.branchPath = path.joinIfDefined( self.branchPath, src.branchPath );
  }

  /* */

  let appending =
  {

    // hasExtension : null,
    // begins : null,
    // ends : null,

    prefixPath : null,
    postfixPath : null,
    // branchPath : null,

  }

  for( let a in appending )
  {
    if( src[ a ] === null || src[ a ] === undefined )
    continue;
    _.assert( _.strIs( src[ a ] ) || _.strsAre( src[ a ] ) );
    _.assert( self[ a ] === null || _.strIs( self[ a ] ) || _.strsAre( self[ a ] ) );
    if( self[ a ] === null )
    {
      self[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( self[ a ] ) )
      self[ a ] = [ self[ a ] ];
      _.arrayAppendOnce( self[ a ], src[ a ] );
    }
  }

  return self;
}

//

function fromOptions( o )
{
  let filter = this;

  _.assert( arguments.length === 1 );
  _.assert( !filter.formed, 'This filter is already formed' );
  _.assert( filter.inFilePath === null || !o.filePath || _.entityIdentical( filter.inFilePath, o.filePath ) );

  if( o.basePath !== undefined )
  filter.basePath = o.basePath;
  if( o.filePath !== undefined )
  filter.inFilePath = o.filePath;
  if( o.prefixPath !== undefined )
  filter.prefixPath = o.prefixPath;
  if( o.postfixPath !== undefined )
  filter.postfixPath = o.postfixPath;

}

//

function toOptions( o )
{
  let filter = this;

  _.assert( arguments.length === 1 );

  o.filePath = filter.branchPath;

  if( o.basePath !== undefined )
  o.basePath = filter.basePath;
  if( o.prefixPath !== undefined )
  o.prefixPath = null;
  if( o.postfixPath !== undefined )
  o.postfixPath = null;

}

//

function form()
{
  let self = this;

  _.assert( self.formed === 0 );
  _.assert( self.hubFileProvider instanceof _.FileProvider.Abstract );

  self._formFixes();
  self._formGlob();
  self._formMasks();

  let fileProvider = self.hubFileProvider;
  let path = fileProvider.path;

  _.assert( _.strIs( self.branchPath ) || _.arrayIs( self.branchPath ) );
  _.assert( path.s.noneAreGlob( self.branchPath ) );
  _.assert( path.s.allAreAbsolute( self.branchPath ) );
  _.assert( _.objectIs( self.basePath ) );
  _.assert( _.objectIs( self.effectiveFileProvider ) );
  _.assert( _.objectIs( self.hubFileProvider ) );

  for( let p in self.basePath )
  {
    _.assert( path.isAbsolute( p ) && !path.isGlob( p ) && !path.isTrailed( p ) );
    _.assert( path.isAbsolute( self.basePath[ p ] ) && !path.isGlob( self.basePath[ p ] ) && !path.isTrailed( self.basePath[ p ] ) );
    // _.assert( !_.uri.isGlobal( p ) );
    // _.assert( !_.uri.isGlobal( self.basePath[ p ] ) );
  }

  if( _.arrayIs( self.branchPath ) && self.branchPath.length === 1 )
  self.branchPath = self.branchPath[ 0 ];

  self.test = self._testNothing;

  if( self.notOlder || self.notNewer || self.notOlderAge || self.notNewerAge )
  self.test = self._testFull;
  else if( self.hasMask() )
  self.test = self._testMasks;

  self.formed = 1;
  Object.freeze( self );
  return self;
}

//

function _formFixes()
{
  let self = this;
  let fileProvider = self.hubFileProvider || self.effectiveFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( self.globMap === null );
  _.assert( !self.formed );
  _.assert( self.prefixPath === null || _.strIs( self.prefixPath ) || _.arrayIs( self.prefixPath ) );
  _.assert( self.postfixPath === null || _.strIs( self.postfixPath ) || _.arrayIs( self.postfixPath ) );
  _.assert( self.basePath === null || _.strIs( self.basePath ) );

  if( self.basePath )
  self.prefixPath = path.s.join( self.basePath, self.prefixPath || '' );

  self.postfixPath = self.postfixPath || '';

}

//

function _formGlob()
{
  let self = this;
  let fileProvider = self.hubFileProvider || self.effectiveFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( self ) );
  _.assert( self.globMap === null );
  _.assert( !self.formed );
  _.assert( self.prefixPath === null || _.strIs( self.prefixPath ) || _.arrayIs( self.prefixPath ) );
  _.assert( self.postfixPath === null || _.strIs( self.postfixPath ) || _.arrayIs( self.postfixPath ) );

  let fixes = _.multipleAll([ self.prefixPath || '', self.postfixPath || '' ]);

  // self.basePath = self.basePath;
  // debugger;
  // if( self.basePath )
  // self.basePath = path.s.join( fixes[ 0 ], self.basePath, fixes[ 1 ] );

  self.globMap = path.s.normalize( path.s.join( fixes[ 0 ], self.inFilePath || '', fixes[ 1 ] ) );

  self.globMap = path.globMapExtend( null, self.globMap );

  /* */

  for( let g in self.globMap )
  {
    let g2 = usePath( g );
    if( g === g2 )
    continue;
    // debugger;
    self.globMap[ g2 ] = self.globMap[ g ];
    delete self.globMap[ g ];
  }

  /* */

  if( self.basePath === null )
  {
    self.basePath = _.mapKeys( self.globMap ).filter( ( g ) => path.isAbsolute( g ) );
    self.basePath = self.basePath.map( ( g ) => path.fromGlob( g ) );
    _.sure( self.basePath.length > 0, 'Cant deduce basePath' );
    if( self.basePath.length > 0 )
    {
      let basePath = Object.create( null );
      for( let b in self.basePath )
      basePath[ self.basePath[ b ] ] = self.basePath[ b ];
      self.basePath = basePath;
    }
  }
  else
  {

    _.assert( _.strIs( self.basePath ) );
    self.basePath = usePath( self.basePath );
    let basePath = Object.create( null );
    let branchPath = _.mapKeys( self.globMap ).filter( ( g ) => path.isAbsolute( g ) );
    branchPath = branchPath.map( ( g ) => path.fromGlob( g ) );
    for( let b in branchPath )
    basePath[ branchPath[ b ] ] = self.basePath;
    self.basePath = basePath;

  }

  /* */

  if( _.none( path.s.areGlob( self.globMap ) ) && _.all( _.mapVals( self.globMap ) ) )
  {
    self.branchPath = _.mapKeys( self.globMap );
    self.globMap = null;
    return;
  }

  _.assert( _.objectIs( self.basePath ) );

  /* */

  for( let g in self.globMap )
  {

    let value = self.globMap[ g ];
    if( path.isAbsolute( g ) )
    continue;

    for( let b in self.basePath )
    {
      let glob = path.join( self.basePath[ b ], g );
      debugger;
      if( glob !== g )
      {
        delete self.globMap[ g ];
        path.globMapExtend( self.globMap, glob, value );
      }
    }

  }

  /* */

  function usePath( path )
  {
    if( self.effectiveFileProvider && !_.uri.isGlobal( path ) )
    return path;
    let effectiveProvider2 = fileProvider.providerForPath( path );
    self.effectiveFileProvider = self.effectiveFileProvider || effectiveProvider2;
    _.assert( effectiveProvider2 === null || self.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
    let result = self.hubFileProvider.localFromUri( path );
    return result;
  }

}

//

function _formMasks()
{
  let self = this;
  let fileProvider = self.effectiveFileProvider || self.hubFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( !self.formed );

  /* */

  self.maskAll = _.RegexpObject( self.maskAll || Object.create( null ), 'includeAny' );
  self.maskTerminal = _.RegexpObject( self.maskTerminal || Object.create( null ), 'includeAny' );
  self.maskDirectory = _.RegexpObject( self.maskDirectory || Object.create( null ), 'includeAny' );

  self.maskTransientAll = _.RegexpObject( self.maskTransientAll || Object.create( null ), 'includeAny' );
  self.maskTransientTerminal = _.RegexpObject( self.maskTransientTerminal || Object.create( null ), 'includeAny' );
  self.maskTransientDirectory = _.RegexpObject( self.maskTransientDirectory || Object.create( null ), 'includeAny' );

  /* */

  if( self.hasExtension )
  {
    _.assert( _.strIs( self.hasExtension ) || _.strsAre( self.hasExtension ) );

    self.hasExtension = _.arrayAs( self.hasExtension );
    self.hasExtension = new RegExp( '^\\.\\/.+\\.(' + _.regexpsEscape( self.hasExtension ).join( '|' ) + ')$', 'i' );

    self.maskAll = _.RegexpObject.And( self.maskAll,{ includeAll : self.hasExtension } );
    self.hasExtension = null;
  }

  if( self.begins )
  {
    _.assert( _.strIs( self.begins ) || _.strsAre( self.begins ) );

    self.begins = _.arrayAs( self.begins );
    self.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( self.begins ).join( '|' ) + ')' );

    self.maskAll = _.RegexpObject.And( self.maskAll,{ includeAll : self.begins } );
    self.begins = null;
  }

  if( self.ends )
  {
    _.assert( _.strIs( self.ends ) || _.strsAre( self.ends ) );

    self.ends = _.arrayAs( self.ends );
    self.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( self.ends ).join( '|' ) + ')$' );

    self.maskAll = _.RegexpObject.And( self.maskAll,{ includeAll : self.ends } );
    self.ends = null;
  }

  /* */

  if( self.globMap )
  {

    // if( self.maskTerminal.includeAny.length )
    // debugger;
    // if( self.maskDirectory.includeAny.length )
    // debugger;

    // let globRegexps = path.globRegexpsFor2( self.globOut[ 0 ], self.globOut[ 1 ], self.globOut[ 2 ] );
    // self.maskAll = _.RegexpObject.And( self.maskAll, { includeAny : globRegexps.terminal } );
    // self.maskTransientTerminal = _.RegexpObject.And( self.maskTransientTerminal, { includeAny : /$_^/ } );
    // self.maskTransientDirectory = _.RegexpObject.And( self.maskTransientAll, { includeAny : globRegexps.directory } );

    _.assert( self.filterMap === null );
    self.filterMap = Object.create( null );
    // debugger;
    self._processed = path.globMapToRegexps( self.globMap, self.basePath  );
    // debugger;

    _.assert( self.branchPath === null );
    self.branchPath = _.mapKeys( self._processed.regexpMap );
    // debugger;
    for( let p in self._processed.regexpMap )
    {
      let basePath = self.basePath[ p ];
      _.assert( _.strIsNotEmpty( basePath ), 'No base path for', p );
      // let relative = path.relative( basePath, p );
      let relative = p;
      let regexps = self._processed.regexpMap[ p ];
      _.assert( !self.filterMap[ relative ] );
      let filter = self.filterMap[ relative ] = Object.create( null );
      filter.maskAll = _.RegexpObject.And( self.maskAll.clone(), { includeAny : regexps.actual, excludeAny : regexps.notActual } );
      filter.maskTerminal = self.maskTerminal.clone();
      filter.maskDirectory = self.maskDirectory.clone();
      filter.maskTransientAll = self.maskTransientAll.clone();
      filter.maskTransientTerminal = _.RegexpObject.And( self.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      filter.maskTransientDirectory = _.RegexpObject.And( self.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( self.maskAll !== filter.maskAll );
    }
    // debugger;

    // self.maskAll = _.RegexpObject.And( self.maskAll, { includeAny : globRegexps.actual, excludeAny : globRegexps.notActual } );
    // self.maskTransientTerminal = _.RegexpObject.And( self.maskTransientTerminal, { includeAny : /$_^/ } );
    // self.maskTransientDirectory = _.RegexpObject.And( self.maskTransientDirectory, { includeAny : globRegexps.transient } );

  }

  // self.globOut = null;

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

  if( filter.filterMap )
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
  let filter = self.filterMap ? self.filterMap[ c.branchPath ] : self;
  // let filter = self.filterMap ? self.filterMap[ path.relative( c.basePath, c.branchPath ) ] : self;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( !!filter, 'Cant resolve filter for start path', () => _.strQuote( c.branchPath ) );
  _.assert( c.formed, 'Record context was not formed!' );

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
  // if( record.absolute === '/common.external' )
  // debugger;
  if( _.strHas( record.absolute, '/doubledir/d1' ) )
  debugger;
  // if( _.strHas( record.absolute, '/doubledir/d1/b' ) )
  // debugger;
  // if( _.strHas( record.absolute, '/common.external' ) )
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

  inFilePath : null,
  basePath : null,
  prefixPath : null,
  postfixPath : null,
  branchPath : null,

}

let Associates =
{
  effectiveFileProvider : null,
  hubFileProvider : null,
}

let Restricts =
{

  globMap : null,
  filterMap : null,
  test : null,
  formed : 0,
  _processed : null,

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
  filePath : 'filePath',
  globOut : 'globOut',
  inPrefixPath : 'inPrefixPath',
  inPostfixPath : 'inPostfixPath',
  fixedFilePath : 'fixedFilePath',
  fileProvider : 'fileProvider',
  fileProviderEffective : 'fileProviderEffective',

  // basePath : 'basePath',

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
  pathsJoin : pathsJoin,

  fromOptions : fromOptions,
  toOptions : toOptions,

  form : form,
  _formFixes : _formFixes,
  _formGlob : _formGlob,
  _formMasks : _formMasks,

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
