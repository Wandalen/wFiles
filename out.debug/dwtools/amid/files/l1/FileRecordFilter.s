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
let Self = function wFileRecordFilter( o )
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
  let filter = this;

  _.instanceInit( filter );
  Object.preventExtensions( filter );

  if( o )
  {

    // if( o.maskAll )
    // o.maskAll = _.RegexpObject( o.maskAll,'includeAny' );
    // if( o.maskTerminal )
    // o.maskTerminal = _.RegexpObject( o.maskTerminal,'includeAny' );
    // if( o.maskDirectory )
    // o.maskDirectory = _.RegexpObject( o.maskDirectory,'includeAny' );

    filter.copy( o );

  }

  if( filter.hubFileProvider && filter.hubFileProvider.hub && filter.hubFileProvider.hub !== filter.hubFileProvider )
  {
    _.assert( filter.effectiveFileProvider === null || filter.effectiveFileProvider === filter.hubFileProvider );
    filter.effectiveFileProvider = filter.hubFileProvider;
    filter.hubFileProvider = filter.hubFileProvider.hub;
  }

  return filter;
}

//

function TollerantMake( o )
{
  _.assert( arguments.length >= 1, 'Expects at least one argument' );
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
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.and( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( src.stemPath/*globMap*/ === null || src.stemPath/*globMap*/ === undefined );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );

  // _.assert( src.inFilePath === null || src.inFilePath === undefined );
  // _.assert( src.basePath === null || src.basePath === undefined );
  // _.assert( filter.inFilePath === null );
  // _.assert( filter.basePath === null );

  // _.assert( !!( filter.hubFileProvider || src.hubFileProvider ) );
  _.assert( !filter.effectiveFileProvider || !src.effectiveFileProvider || filter.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  // _.assert( filter.inFilePath === null );
  // _.assert( src.inFilePath === null || src.inFilePath === undefined );

  if( src === filter )
  return filter;

  /* */

  if( src.effectiveFileProvider )
  filter.effectiveFileProvider = src.effectiveFileProvider

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider

  /* */

  // if( src.basePath )
  // {
  //   _.assert( _.strIs( src.basePath ) );
  //   _.assert( filter.basePath === null || _.strIs( filter.basePath ) );
  //   filter.basePath = path.joinIfDefined( filter.basePath, src.basePath );
  // }
  //
  // if( src.prefixPath )
  // filter.prefixPath = path.s.joinIfDefined( filter.prefixPath, src.prefixPath );
  // if( src.postfixPath )
  // filter.postfixPath = path.s.joinIfDefined( filter.postfixPath, src.postfixPath  );

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
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAre( filter[ a ] ) );
    if( filter[ a ] === null )
    {
      filter[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], src[ a ] );
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
    _.assert( !filter[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field', n );
    if( src[ n ] )
    filter[ n ] = src[ n ];
  }

  /* */

  filter.maskAll = _.RegexpObject.And( filter.maskAll, src.maskAll || null );
  filter.maskTerminal = _.RegexpObject.And( filter.maskTerminal, src.maskTerminal || null );
  filter.maskDirectory = _.RegexpObject.And( filter.maskDirectory, src.maskDirectory || null );

  filter.maskTransientAll = _.RegexpObject.And( filter.maskTransientAll, src.maskTransientAll || null );
  filter.maskTransientTerminal = _.RegexpObject.And( filter.maskTransientTerminal, src.maskTransientTerminal || null );
  filter.maskTransientDirectory = _.RegexpObject.And( filter.maskTransientDirectory, src.maskTransientDirectory || null );

  return filter;
}

//

function pathsJoin( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsJoin( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( filter.inFilePath === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );
  // _.assert( src.stemPath/*globMap*/ === null || src.stemPath/*globMap*/ === undefined );
  _.assert( src.inFilePath === null || src.inFilePath === undefined );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || src.effectiveFileProvider || src.hubFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  // let joining =
  // {
  //   basePath : null,
  //   stemPath : null,
  //   prefixPath : null,
  //   postfixPath : null,
  // }
  //
  // for( let n in joining )
  // if( src[ n ] !== undefined && src[ n ] !== null )
  // {
  //   _.assert( src[ n ] === null || _.strIs( src[ n ] ) );
  //   _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
  //   filter[ n ] = path.join( filter[ n ], src.basePath );
  // }

  /* */

  if( src.basePath !== undefined && src.basePath !== null )
  {
    _.assert( src.basePath === null || _.strIs( src.basePath ) );
    _.assert( filter.basePath === null || _.strIs( filter.basePath ) );
    filter.basePath = path.join( filter.basePath, src.basePath );
  }

  if( src.stemPath !== undefined && src.stemPath !== null )
  {
    _.assert( src.stemPath === null || _.strIs( src.stemPath ) || _.arrayIs( src.stemPath ) );
    _.assert( filter.stemPath === null || _.strIs( filter.stemPath ) || _.arrayIs( filter.stemPath ) );
    filter.stemPath = path.join( filter.stemPath, src.stemPath );
  }

  /* */

  let appending =
  {
    prefixPath : null,
    postfixPath : null,
  }

  for( let a in appending )
  {
    if( src[ a ] === null || src[ a ] === undefined )
    continue;

    _.assert( _.strIs( src[ a ] ) || _.strsAre( src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAre( filter[ a ] ) );

    if( filter[ a ] === null )
    {
      filter[ a ] = src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], src[ a ] );
    }

  }

  return filter;
}

//

function pathsInherit( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsJoin( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );
  // _.assert( src.stemPath/*globMap*/ === null || src.stemPath/*globMap*/ === undefined );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || src.effectiveFileProvider || src.hubFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  src.prefixesApply();
  filter.prefixesApply();

  _.assert( src.prefixPath === null );
  _.assert( src.postfixPath === null );
  _.assert( filter.prefixPath === null );
  _.assert( filter.postfixPath === null );

  if( _.mapIs( src.basePath ) )
  filter.basePath = _.mapExtend( filter.basePath, src.basePath );
  else if( filter.basePath === null )
  filter.basePath = src.basePath;

  /* */

  if( src.filePath )
  filter.filePath = path.globMapExtend( filter.filePath, src.filePath, true );

  // if( src.inFilePath )
  // filter.inFilePath = path.globMapExtend( filter.inFilePath, src.inFilePath, true );
  //
  // if( src.stemPath )
  // filter.stemPath = path.globMapExtend( filter.stemPath, src.stemPath, true );

  return filter;
}

//

function pathsExtend( src )
{
  let filter = this;

  if( arguments.length > 1 )
  {
    for( let a = 0 ; a < arguments.length ; a++ )
    filter.pathsExtend( arguments[ a ] );
    return filter;
  }

  if( Config.debug )
  if( src && !( src instanceof filter.Self ) )
  _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.filterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( filter.inFilePath === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );
  // _.assert( src.stemPath/*globMap*/ === null || src.stemPath/*globMap*/ === undefined );
  _.assert( src.inFilePath === null || src.inFilePath === undefined );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || src.effectiveFileProvider || src.hubFileProvider;
  let path = fileProvider.path;

  let replacing =
  {

    hubFileProvider : null,
    basePath : null,
    stemPath : null,
    prefixPath : null,
    postfixPath : null,

  }

  /* */

  for( let s in replacing )
  {
    if( src[ s ] === null || src[ s ] === undefined )
    continue;
    filter[ s ] = src[ s ];
  }

  return filter;
}

//

function form()
{
  let filter = this;

  _.assert( filter.formed <= 3 );
  _.assert( filter.hubFileProvider instanceof _.FileProvider.Abstract );

  // if( filter.filePath === null )
  // debugger;

  filter._formFinal();

  _.assert( filter.formed === 5 );
  Object.freeze( filter );
  return filter;
}

//

function _formComponents()
{
  let filter = this;

  _.assert( filter.formed === 0 );

  filter.maskAll = _.RegexpObject( filter.maskAll || Object.create( null ), 'includeAny' );
  filter.maskTerminal = _.RegexpObject( filter.maskTerminal || Object.create( null ), 'includeAny' );
  filter.maskDirectory = _.RegexpObject( filter.maskDirectory || Object.create( null ), 'includeAny' );

  filter.maskTransientAll = _.RegexpObject( filter.maskTransientAll || Object.create( null ), 'includeAny' );
  filter.maskTransientTerminal = _.RegexpObject( filter.maskTransientTerminal || Object.create( null ), 'includeAny' );
  filter.maskTransientDirectory = _.RegexpObject( filter.maskTransientDirectory || Object.create( null ), 'includeAny' );

  filter.formed = 1;
}

//

function _formFixes()
{
  let filter = this;

  if( filter.formed < 1 )
  filter._formComponents();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.formed === 1 );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.arrayIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.arrayIs( filter.postfixPath ) );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  // if( filter.basePath )
  // filter.prefixPath = path.s.join( filter.basePath, filter.prefixPath || '' );
  //
  // filter.postfixPath = filter.postfixPath || '';

  filter.formed = 2;
}

//

function _formBasePath()
{
  let filter = this;

  if( filter.formed === 3 )
  return;
  if( filter.formed < 2 )
  filter._formFixes();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( _.objectIs( filter ) );
  // _.assert( filter.stemPath/*globMap*/ === null );
  _.assert( filter.formed === 2 );
  // _.assert( filter.stemPath === null );

  // if( filter.filePath === null )
  // debugger;

  // debugger;
  filter.prefixesApply();
  // debugger;
  filter.stemPath/*globMap*/ = filter.pathsNormalize();

}

//

function _formMasks()
{
  let filter = this;

  if( filter.formed < 3 )
  filter._formBasePath();

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 3 );

  /* */

  if( filter.hasExtension )
  {
    _.assert( _.strIs( filter.hasExtension ) || _.strsAre( filter.hasExtension ) );

    filter.hasExtension = _.arrayAs( filter.hasExtension );
    filter.hasExtension = new RegExp( '^.*\\.(' + _.regexpsEscape( filter.hasExtension ).join( '|' ) + ')(\\.|$)(?!.*\/.+)', 'i' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.hasExtension } );
    filter.hasExtension = null;
  }

  if( filter.begins )
  {
    _.assert( _.strIs( filter.begins ) || _.strsAre( filter.begins ) );

    filter.begins = _.arrayAs( filter.begins );
    filter.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( filter.begins ).join( '|' ) + ')' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.begins } );
    filter.begins = null;
  }

  if( filter.ends )
  {
    _.assert( _.strIs( filter.ends ) || _.strsAre( filter.ends ) );

    filter.ends = _.arrayAs( filter.ends );
    filter.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( filter.ends ).join( '|' ) + ')$' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.ends } );
    filter.ends = null;
  }

  /* */

  // if( filter.stemPath/*globMap*/ )
  if( filter.globFound )
  {

    // debugger;
    for( let g in filter.stemPath/*globMap*/ )
    {

      let value = filter.stemPath/*globMap*/[ g ];
      if( path.isAbsolute( g ) )
      continue;

      for( let b in filter.basePath )
      {
        let glob = path.join( filter.basePath[ b ], g );
        // debugger;
        if( glob !== g )
        {
          delete filter.stemPath/*globMap*/[ g ];
          path.globMapExtend( filter.stemPath/*globMap*/, glob, value );
        }
      }

    }

    _.assert( filter.filterMap === null );
    filter.filterMap = Object.create( null );
    let _processed = path.globMapToRegexps( filter.stemPath/*globMap*/, filter.basePath  );

    // _.assert( filter.stemPath === null );
    filter.stemPath = _.mapKeys( _processed.regexpMap );
    for( let p in _processed.regexpMap )
    {
      let basePath = filter.basePath[ p ];
      _.assert( _.strDefined( basePath ), 'No base path for', p );
      let relative = p;
      let regexps = _processed.regexpMap[ p ];
      _.assert( !filter.filterMap[ relative ] );
      let subfilter = filter.filterMap[ relative ] = Object.create( null );
      subfilter.maskAll = _.RegexpObject.And( filter.maskAll.clone(), { includeAny : regexps.actual, excludeAny : regexps.notActual } );
      subfilter.maskTerminal = filter.maskTerminal.clone();
      subfilter.maskDirectory = filter.maskDirectory.clone();
      subfilter.maskTransientAll = filter.maskTransientAll.clone();
      subfilter.maskTransientTerminal = _.RegexpObject.And( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      subfilter.maskTransientDirectory = _.RegexpObject.And( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( subfilter.maskAll !== filter.maskAll );
    }

    // debugger;
  }

  /* */

  if( Config.debug )
  {

    if( filter.notOlder )
    _.assert( _.numberIs( filter.notOlder ) || _.dateIs( filter.notOlder ) );

    if( filter.notNewer )
    _.assert( _.numberIs( filter.notNewer ) || _.dateIs( filter.notNewer ) );

    if( filter.notOlderAge )
    _.assert( _.numberIs( filter.notOlderAge ) || _.dateIs( filter.notOlderAge )  );

    if( filter.notNewerAge )
    _.assert( _.numberIs( filter.notNewerAge ) || _.dateIs( filter.notNewerAge ) );

  }

  filter.formed = 4;
}

//

function _formFinal()
{
  let filter = this;

  if( filter.formed < 4 )
  filter._formMasks();

  let fileProvider = filter.hubFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 4 );
  _.assert( _.strIs( filter.stemPath ) || _.arrayIs( filter.stemPath ) || _.mapIs( filter.stemPath ) );
  // _.assert( _.strIs( filter.stemPath ) || _.mapIs( filter.stemPath ) );
  _.assert( path.s.noneAreGlob( filter.stemPath ) );
  _.assert( path.s.allAreAbsolute( filter.stemPath ) || path.s.allAreGlobal( filter.stemPath ) );
  _.assert( _.objectIs( filter.basePath ) );
  _.assert( _.objectIs( filter.effectiveFileProvider ) );
  _.assert( _.objectIs( filter.hubFileProvider ) );

  for( let p in filter.basePath )
  {
    let stemPath = p;
    let basePath = filter.basePath[ p ];
    _.assert
    (
      path.isAbsolute( stemPath ) && path.isNormalized( stemPath ) && !path.isGlob( stemPath ) && !path.isTrailed( stemPath ),
      () => 'Stem path should be absolute and normalized, but not glob, neither trailed' + '\nstemPath : ' + _.toStr( stemPath )
    );
    _.assert
    (
      path.isAbsolute( basePath ) && path.isNormalized( basePath ) && !path.isGlob( basePath ) && !path.isTrailed( basePath ),
      () => 'Base path should be absolute and normalized, but not glob, neither trailed' + '\nbasePath : ' + _.toStr( basePath )
    );
  }

  filter.applyTo = filter._applyToRecordNothing;

  if( filter.notOlder || filter.notNewer || filter.notOlderAge || filter.notNewerAge )
  filter.applyTo = filter._applyToRecordFull;
  else if( filter.hasMask() )
  filter.applyTo = filter._applyToRecordMasks;

  filter.formed = 5;
}

//

function determineEffectiveFileProvider( filePath )
{
  let filter = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.effectiveFileProvider )
  return filter.effectiveFileProvider;

  if( !filePath )
  filePath = filter.stemPath;

  if( !filePath )
  filePath = filter.inFilePath;

  if( !filePath )
  filePath = filter.basePath

  _.assert( _.strIs( filePath ), 'Expects string' );

  let fileProvider = filter.hubFileProvider;
  filter.effectiveFileProvider = fileProvider.providerForPath( filePath );

  // function usePath( path )
  // {
  //   if( filter.effectiveFileProvider && !_.path.isGlobal( path ) )
  //   return path;
  //   let effectiveProvider2 = fileProvider.providerForPath( path );
  //   filter.effectiveFileProvider = filter.effectiveFileProvider || effectiveProvider2;
  //   _.assert( effectiveProvider2 === null || filter.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
  //   let result = filter.hubFileProvider.localFromGlobal( path );
  //   return result;
  // }

  return filter.effectiveFileProvider;
}

//

function filteringEmpty()
{
  let filter = this;

  filter.maskAll = null;
  filter.maskTerminal = null;
  filter.maskDirectory = null;
  filter.maskTransientAll = null;
  filter.maskTransientTerminal = null;
  filter.maskTransientDirectory = null;

  filter.hasExtension = null;
  filter.begins = null;
  filter.ends = null;

  filter.notOlder = null;
  filter.notNewer = null;
  filter.notOlderAge = null;
  filter.notNewerAge = null;

  return filter;
}

//

function hasMask()
{
  let filter = this;

  if( filter.filterMap )
  return true;

  let hasMask = false;

  hasMask = hasMask || ( filter.maskAll && !filter.maskAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTerminal && !filter.maskTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskDirectory && !filter.maskDirectory.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientAll && !filter.maskTransientAll.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientTerminal && !filter.maskTransientTerminal.isEmpty() );
  hasMask = hasMask || ( filter.maskTransientDirectory && !filter.maskTransientDirectory.isEmpty() );

  hasMask = hasMask || !!filter.hasExtension;
  hasMask = hasMask || !!filter.begins;
  hasMask = hasMask || !!filter.ends;

  return hasMask;
}

//

function hasFiltering()
{
  let filter = this;

  if( filter.hasMask() )
  return true;

  if( filter.notOlder !== null )
  return true;
  if( filter.notNewer !== null )
  return true;
  if( filter.notOlderAge !== null )
  return true;
  if( filter.notNewerAge !== null )
  return true;

  return false;
}

//

function hasData()
{
  let filter = this;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) );
  _.assert( filter.stemPath === null || _.strIs( filter.stemPath ) || _.arrayIs( filter.stemPath ) );
  _.assert( filter.inFilePath === null || _.strIs( filter.inFilePath ) || _.arrayIs( filter.inFilePath ) || _.mapIs( filter.inFilePath ) );

  if( _.strIs( filter.basePath ) || _.mapIsPopulated( filter.basePath ) )
  return true;

  if( _.strIs( filter.prefixPath ) )
  return true;

  if( _.strIs( filter.postfixPath ) )
  return true;

  if( _.strIs( filter.stemPath ) || _.arrayIsPopulated( filter.stemPath ) )
  return true;

  if( _.strIs( filter.inFilePath ) || _.arrayIsPopulated( filter.inFilePath ) || _.mapIsPopulated( filter.inFilePath ) )
  return true;

  return filter.hasFiltering();
}

//

function pathsNormalize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );
  _.assert( filter.prefixPath === null, 'Prefixes should be applied so far' );
  _.assert( filter.postfixPath === null, 'Posftixes should be applied so far' );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( _.strIs( filter.inFilePath ) || _.arrayIs( filter.inFilePath ) || _.mapIs( filter.inFilePath ), 'inFilePath of file record filter is not defined' );

  filter.inFilePath = path.s.normalize( filter.inFilePath );
  let stemPath = path.globMapExtend( null, filter.inFilePath );

  /* */

  for( let g in stemPath )
  {
    let g2 = usePath( g );
    if( g === g2 )
    continue;
    _.assert( _.strIs( g2 ) );
    stemPath[ g2 ] = stemPath[ g ];
    delete stemPath[ g ];
  }

  /* */

  if( filter.basePath === null )
  {
    filter.basePath = _.mapKeys( stemPath ).filter( ( g ) => path.isAbsolute( g ) /*|| path.isGlobal( g )*/ );
    filter.basePath = filter.basePath.map( ( g ) => path.fromGlob( g ) );
    _.sure( filter.basePath.length > 0 || ( _.arrayIs( filter.inFilePath ) && filter.inFilePath.length === 0 ), 'Cant deduce basePath' );
    let basePath = Object.create( null );
    for( let b in filter.basePath )
    basePath[ filter.basePath[ b ] ] = path.normalize( filter.basePath[ b ] );
    filter.basePath = basePath;
  }
  else if( _.strIs( filter.basePath ) )
  {

    _.assert( _.strIs( filter.basePath ) );
    filter.basePath = usePath( filter.basePath );
    filter.basePath = path.normalize( filter.basePath );
    let basePath = Object.create( null );
    let stemPath = _.mapKeys( stemPath ).filter( ( g ) => path.isAbsolute( g ) );
    stemPath = stemPath.map( ( g ) => path.fromGlob( g ) );
    for( let b in stemPath )
    basePath[ stemPath[ b ] ] = filter.basePath;
    filter.basePath = basePath;

  }
  else if( _.mapIs( filter.basePath ) )
  {

    _.assert( _.mapIs( filter.basePath ) );

    filter.basePath = path.filter( filter.basePath, ( p ) => usePath( p ) );
    filter.basePath = path.filter( filter.basePath, ( p ) => path.normalize( p ) );

    if( Config.debug )
    {
      let stemPath2 = _.mapKeys( stemPath ).filter( ( g ) => path.isAbsolute( g ) );
      let diff = _.arraySetDiff( _.mapKeys( filter.basePath ), path.s.fromGlob( stemPath2 ) );
      _.assert( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );
    }

  }

  /* */

  filter.globFound = 1;
  if( _.none( path.s.areGlob( stemPath ) ) && _.all( _.mapVals( stemPath ) ) )
  {
    stemPath = _.mapKeys( stemPath );
    if( stemPath.length === 1 )
    stemPath = stemPath[ 0 ];
    // stemPath = null;
    filter.globFound = 0;
  }

  _.assert
  (
       ( _.arrayIs( stemPath ) && stemPath.length === 0 )
    || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
    , 'Cant deduce base path'
  )

  if( !_.mapKeys( filter.basePath ).length && !filter.effectiveFileProvider )
  filter.effectiveFileProvider = filter.hubFileProvider;

  /* */

  filter.formed = 3;

  return stemPath;

  /* - */

  function usePath( filePath )
  {
    if( filter.effectiveFileProvider && !path.isGlobal( filePath ) )
    return filePath;
    let effectiveProvider2 = fileProvider.providerForPath( filePath );
    filter.effectiveFileProvider = filter.effectiveFileProvider || effectiveProvider2;
    _.assert( effectiveProvider2 === null || filter.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
    let result = filter.hubFileProvider.localFromGlobal( filePath );
    return result;
  }

}

//

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;
  let prefixPath;

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.postfixPath === null, 'not implemented' );

  if( filter.prefixPath !== null )
  {
    prefixPath = path.fromGlob( filter.prefixPath );

    let o2 = { basePath : 0, fixes : 0, onEach : filePathEach }
    filter.allPaths( o2 );

    let o3 = { filePath : 0, /*stemPath : 0,*/ fixes : 0, onEach : basePathEach }
    filter.allPaths( o3 );
  }

  // if( filter.basePath === '/dst' )
  // debugger;

  if( _.strIs( filter.basePath ) && filter.stemPath !== null )
  {
    basePathNorm( filter.stemPath );
  }
  else if( _.strIs( filter.basePath ) && filter.inFilePath !== null )
  {
    basePathNorm( filter.inFilePath );
  }

  filter.prefixPath = null;
  filter.postfixPath = null;

  if( Config.debug && filter.basePath && filter.stemPath )
  assertBasePath( filter.stemPath );

  if( Config.debug && filter.basePath && filter.inFilePath )
  assertBasePath( filter.inFilePath );

  return filter;

  /* */

  function filePathEach( it )
  {
    if( _.strIs( filter.prefixPath ) )
    if( _.strIs( it.value ) )
    {
      let basePath = filter.basePathFor( it.value );
      basePath = basePath || '.';
      it.value = path.join( filter.prefixPath, it.value );
      // it.value = path.join( filter.prefixPath, basePath, it.value );
    }
    return true;
  }

  /* */

  function basePathEach( it )
  {
    // debugger;
    if( _.strIs( it.value ) )
    {
      it.value = path.join( filter.prefixPath, it.value );
    }
    else
    {
    }
    return true;
  }

  /* */

  function basePathNorm( originalStemPath )
  {
    let basePath = Object.create( null );
    let stemPaths = originalStemPath;

    if( _.mapIs( stemPaths ) )
    stemPaths = _.mapKeys( stemPaths );
    else if( !_.arrayIs( stemPaths ) )
    stemPaths = [ stemPaths ];

    for( let s = 0 ; s < stemPaths.length ; s++ )
    {
      let stemPath = stemPaths[ s ];

      _.assert( _.strIs( stemPath ) || _.boolIs( stemPath ) );

      if( _.strIs( stemPath ) && path.isGlob( stemPath ) )
      stemPath = path.fromGlob( stemPath );

      if( _.boolIs( stemPath ) )
      {
        _.assert( _.strIs( prefixPath ) && !path.isGlob( prefixPath ) );
        basePath[ prefixPath ] = filter.basePath;
      }
      else
      {
        _.assert( !path.isGlob( stemPath ) );
        if( path.isAbsolute( stemPath ) )
        basePath[ stemPath ] = filter.basePath;
      }

    }

    filter.basePath = basePath;
  }

  /* */

  function assertBasePath( stemPath )
  {
    if( _.mapIs( stemPath ) )
    stemPath = _.mapKeys( stemPath );
    else if( _.strIs( stemPath ) )
    stemPath = [ stemPath ];

    stemPath = stemPath.filter( ( g ) => _.strIs( g ) && path.isAbsolute( g ) );

    let diff = _.arraySetDiff( _.mapKeys( filter.basePath ), path.s.fromGlob( stemPath ) );
    _.assert( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );
  }

}

prefixesApply.defaults =
{
}

//

function allPaths( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;
  let thePath;

  if( _.routineIs( o ) )
  o = { onEach : o }
  o = _.routineOptions( allPaths, o );
  _.assert( arguments.length === 1 );
  // _.assert( 0, 'not tested' );

  if( o.fixes )
  if( !each( filter.prefixPath, 'prefixPath' ) )
  return false;

  if( o.fixes )
  if( !each( filter.postfix, 'postfix' ) )
  return false;

  if( o.basePath )
  if( !each( filter.basePath, 'basePath' ) )
  return false;

  // if( o.stemPath )
  // if( !each( filter.stemPath, 'stemPath' ) )
  // return false;
  //
  // if( o.filePath )
  // if( !each( filter.inFilePath, 'inFilePath' ) )
  // return false;

  if( o.filePath )
  if( !each( filter.filePath, 'inFilePath' ) )
  return false;

  return true;

  /* - */

  function each( thePath, name )
  {
    let it = Object.create( null );

    it.options = o;
    it.fieldName = name;
    it.name = name;
    it.side = null;
    it.field = thePath;
    it.value = thePath;

    if( thePath === null || _.strIs( thePath ) )
    {
      if( o.onEach( it ) === false )
      return false;
      if( filter[ name ] !== it.value )
      filter[ name ] = it.value;
    }
    else
    {
      return path.iterateAll({ iteration : it, filePath : thePath, onEach : o.onEach });
    }

    return true;
  }

}

allPaths.defaults =
{
  onEach : null,
  fixes : 1,
  basePath : 1,
  // stemPath : 1,
  filePath : 1,
}

//

function isRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;
  let thePath;

  o = _.routineOptions( isRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  return filter.allPaths( o2 );

  /* - */

  function onEach( it )
  {
    if( it.value === null )
    return true;
    if( path.isRelative( it.value ) )
    return true;
    return false;
  }

}

isRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // stemPath : 1,
  filePath : 1,
}

//

function sureRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  return filter.allPaths( o2 );

  /* - */

  function onEach( it )
  {
    _.sure
    (
      it.value === null || path.isRelative( it.value ),
      () => 'Filter should have relative ' + it.name + ', but has  ' + _.toStr( it.value )
    );
    return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // stemPath : 1,
  filePath : 1,
}

//

function sureRelativeOrGlobal( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  // _.assert( 0, 'not tested' );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  // debugger;
  let result = filter.allPaths( o2 );
  // debugger;

  return result;

  /* - */

  function onEach( it )
  {
    _.sure
    (
      it.value === null || _.boolIs( it.value ) || path.isRelative( it.value ) || path.isGlobal( it.value ),
      () => 'Filter should have relative ' + it.name + ', but has ' + _.toStr( it.value )
    );
    return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // stemPath : 1,
  filePath : 1,
}

// {
//   let filter = this;
//   let thePath;
//
//   o = _.routineOptions( sureRelative, arguments );
//
//   thePath = filter.prefixPath;
//   if( o.fixes )
//   _.assert
//   (
//     thePath === null || path.s.allAreRelative( thePath ),
//     () => 'Filter should have relative prefixPath, but has  ' + _.toStr( thePath )
//   );
//
//   thePath = filter.postfixPath;
//   if( o.fixes )
//   _.assert
//   (
//     thePath === null || path.s.allAreRelative( thePath ),
//     () => 'Filter should have relative postfixPath, but has ' + _.toStr( thePath )
//   );
//
//   if( o.basePath )
//   {
//     thePath = filter.basePath;
//     if( _.mapIs( thePath ) )
//     thePath = _.mapVals( filter.basePath
//     _.assert
//     (
//       thePath === null || path.s.allAreRelative( thePath ),
//       () => 'Filter should have relative basePath, but has ' + _.toStr( thePath )
//     );
//   }
//
//   if( o.stemPath )
//   {
//     if( thePath === null )
//     {}
//     else if( _.arrayIs( thePath ) || _.strIs( thePath ) )
//     {
//       _.assert
//       (
//         thePath === null || path.s.allAreRelative( thePath ),
//         () => 'Filter should have relative postfixPath, but has ' + _.toStr( thePath )
//       );
//     }
//     if( _.mapIs( thePath ) )
//     for( let src in thePath )
//     {
//       let dst = thePath[ src ];
//
//       _.assert
//       (
//         _.all( src, ( p ) => path.isRelative( p ) || ( o.allowGlobal && path.isGlobal( p ) ) ),
//         () => 'Expects relative or global path, source of stemPath of filter is ' + src
//       );
//
//       _.assert
//       (
//         _.all( dst, ( p ) => _.boolIs( p ) || path.isRelative( p ) || ( o.allowGlobal && path.isGlobal( p ) ) ),
//         () => 'Expects relative or global path, destination of stemPath of filter is ' + dst
//       );
//
//     }
//   }
//
//   if( o.stemPath )
//   {
//     thePath = filter.stemPath;
//     _.assert
//     (
//       thePath === null || path.s.allAreRelative( thePath ),
//       () => 'Filter should have relative stemPath, but has  ' + _.toStr( thePath )
//     );
//   }
//
//   if( o.filePath )
//   {
//     thePath = filter.inFilePath;
//     _.assert
//     (
//       thePath === null || path.s.allAreRelative( thePath ),
//       () => 'Filter should have relative inFilePath, but has  ' + _.toStr( p )
//     );
//   }
//
// }
//
// sureRelative.defaults =
// {
//   fixes : 1,
//   basePath : 1,
//   stemPath : 1,
//   filePath : 1,
//   allowGlobal : 0,
// }

// --
//
// --

function compactField( it )
{
  let filter = this;

  if( it.dst === null )
  return;

  // debugger;

  if( it.dst && it.dst instanceof _.RegexpObject )
  if( !it.dst.hasData() )
  return;

  if( _.objectIs( it.dst ) && _.mapKeys( it.dst ).length === 0 )
  return;

  return it.dst;
}

//

function toStr()
{
  let filter = this;
  let result = '';

  // _.assert( arguments.length === 0 );

  result += 'Filter';

  for( let m in filter.MaskNames )
  {
    let maskName = filter.MaskNames[ m ];
    if( filter[ maskName ] !== null && !filter[ maskName ].isEmpty() )
    result += '\n' + '  ' + maskName + ' : ' + !filter[ maskName ].isEmpty();
  }

  let FieldNames =
  [
    'basePath',
    'prefixPath', 'postfixPath', 'stemPath',
    'hasExtension', 'begins', 'ends',
    'notOlder', 'notNewer', 'notOlderAge', 'notNewerAge',
  ];

  for( let f in FieldNames )
  {
    let fieldName = FieldNames[ f ];
    if( filter[ fieldName ] !== null )
    result += '\n' + '  ' + fieldName + ' : ' + _.toStr( filter[ fieldName ] );
  }

  return result;
}

//

function _applyToRecordNothing( record )
{
  let filter = this;
  return record.isActual;
}

//

function _applyToRecordMasks( record )
{
  let filter = this;
  let relative = record.relative;
  let f = record.factory;
  let path = record.path;
  filter = filter.filterMap ? filter.filterMap[ f.stemPath ] : filter;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!filter, 'Cant resolve filter for start path', () => _.strQuote( f.stemPath ) );
  _.assert( !!f.formed, 'Record factor was not formed!' );

  // if( _.strHas( record.absolute, '/file.b' ) )
  // debugger;

  /* */

  if( record.isDir )
  {

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientDirectory )
    record[ isTransientSymbol ] = filter.maskTransientDirectory.test( relative );

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskDirectory )
    record[ isActualSymbol ] = filter.maskDirectory.test( relative );

  }
  else
  {

    if( record.isActual && filter.maskAll )
    record[ isActualSymbol ] = filter.maskAll.test( relative );
    if( record.isActual && filter.maskTerminal )
    record[ isActualSymbol ] = filter.maskTerminal.test( relative );

    if( record.isTransient && filter.maskTransientAll )
    record[ isTransientSymbol ] = filter.maskTransientAll.test( relative );
    if( record.isTransient && filter.maskTransientTerminal )
    record[ isTransientSymbol ] = filter.maskTransientTerminal.test( relative );

  }

  /* */

  // logger.log( '_applyToRecordMasks', record.absolute, record.isTransient, record.isActual );
  // if( record.absolute === '/common.external' )
  // debugger;
  // if( _.strHas( record.absolute, '/dstExt/d1a/d1b/b.js' ) )
  // debugger;
  // if( _.strHas( record.absolute, '/doubledir/d1/b' ) )
  // debugger;
  // if( _.strHas( record.absolute, '.im.in.yml' ) )
  // debugger;

  return record.isActual;
}

//

function _applyToRecordTime( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

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
    if( filter.notOlder !== null )
    {
      debugger;
      record[ isActualSymbol ] = time >= filter.notOlder;
    }

    if( record.isActual === true )
    if( filter.notNewer !== null )
    {
      debugger;
      record[ isActualSymbol ] = time <= filter.notNewer;
    }

    if( record.isActual === true )
    if( filter.notOlderAge !== null )
    {
      debugger;
      record[ isActualSymbol ] = _.timeNow() - filter.notOlderAge - time <= 0;
    }

    if( record.isActual === true )
    if( filter.notNewerAge !== null )
    {
      debugger;
      record[ isActualSymbol ] = _.timeNow() - filter.notNewerAge - time >= 0;
    }
  }

  return record.isActual;
}

//

function _applyToRecordFull( record )
{
  let filter = this;

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( record.isActual === false )
  return record.isActual;

  filter._applyToRecordMasks( record );
  filter._applyToRecordTime( record );

  return record.isActual;
}

// --
// path
// --

function basePathFor( filePath )
{
  let filter = this;
  let result = null;

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];

  _.assert( result !== undefined, 'No base path for ' + filePath );

  return result;
}

//

function basePathsGet()
{
  let filter = this;

  _.assert( arguments.length === 0 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  if( _.objectIs( filter.basePath ) )
  return _.arrayUnique( _.mapVals( filter.basePath ) )
  else if( _.strIs( filter.basePath ) )
  return [ filter.basePath ];
  else
  return [];
}

//

function filePathGet()
{
  let filter = this;
  return filter.filePath;
}

//

function filePathSet( src )
{
  let filter = this;
  _.assert( src === null || _.strIs( src ) || _.arrayIs( src ) || _.mapIs( src ) );
  filter.filePath = src;
  return src;
}

// --
// relations
// --

let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );

let MaskNames =
[
  'maskAll',
  'maskTerminal',
  'maskDirectory',
  'maskTransientAll',
  'maskTransientTerminal',
  'maskTransientDirectory',
]

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

  basePath : null,
  prefixPath : null,
  postfixPath : null,

}

let Aggregates =
{

  filePath : null,
  // inFilePath : null,
  // stemPath : null,

}

let Associates =
{
  effectiveFileProvider : null,
  hubFileProvider : null,
}

let Restricts =
{

  filterMap : null,
  applyTo : null,
  formed : 0,
  globFound : null,

  // globMap : null,
  // _processed : null,

}

let Statics =
{
  TollerantMake : TollerantMake,
  And : And,
  MaskNames : MaskNames,
}

let Globals =
{
}

let Forbids =
{

  options : 'options',
  glob : 'glob',
  recipe : 'recipe',
  globOut : 'globOut',
  inPrefixPath : 'inPrefixPath',
  inPostfixPath : 'inPostfixPath',
  fixedFilePath : 'fixedFilePath',
  fileProvider : 'fileProvider',
  fileProviderEffective : 'fileProviderEffective',
  isEmpty : 'isEmpty',
  globMap : 'globMap',
  _processed : '_processed',
  test : 'test',

}

let Accessors =
{

  basePaths : { getter : basePathsGet, readOnly : 1 },
  inFilePath : { getter : filePathGet, setter : filePathSet },
  stemPath : { getter : filePathGet, setter : filePathSet },

}

// --
// declare
// --

let Proto =
{

  init,

  TollerantMake,
  And,
  and,
  pathsJoin,
  pathsInherit,
  pathsExtend,

  form,
  _formComponents,
  _formFixes,
  _formBasePath,
  _formMasks,
  _formFinal,

  determineEffectiveFileProvider,

  filteringEmpty,
  hasMask,
  hasFiltering,
  hasData,

  pathsNormalize,
  prefixesApply,
  allPaths,
  isRelative,
  sureRelative,
  sureRelativeOrGlobal,

  compactField,
  toStr,

  _applyToRecordNothing,
  _applyToRecordMasks,
  _applyToRecordTime,
  _applyToRecordFull,

  // path

  basePathFor,
  basePathsGet,
  filePathGet,
  filePathSet,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
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

_.mapExtend( _,Globals );

_.Copyable.mixin( Self );

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
