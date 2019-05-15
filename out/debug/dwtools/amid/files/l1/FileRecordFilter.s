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

function TollerantFrom( o )
{
  _.assert( arguments.length >= 1, 'Expects at least one argument' );
  _.assert( _.objectIs( Self.prototype.Composes ) );
  o = _.mapsExtend( null, arguments );
  return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
}

//

function init( o )
{
  let filter = this;

  _.instanceInit( filter );
  Object.preventExtensions( filter );

  if( o )
  filter.copy( o );

  filter._formAssociations();

  return filter;
}

//

function copy( src )
{
  let filter = this;

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) )
  src = { filePath : src }
  else if( _.arrayIs( src ) )
  src = { filePath : src }

  let result = _.Copyable.prototype.copy.call( filter, src );

  return result;
}

//

function cloneBoth()
{
  let filter = this;

  let result = filter.clone();

  if( filter.srcFilter )
  {
    result.srcFilter = filter.srcFilter.clone();
    result.srcFilter.pairWithDst( result );
    result.srcFilter.pairRefineLight();
    return result;
  }

  if( filter.dstFilter )
  {
    result.dstFilter = filter.dstFilter.clone();
    result.pairWithDst( result.dstFilter );
    result.pairRefineLight();
    return result;
  }

  return result;
}

// --
// former
// --

function form()
{
  let filter = this;

  // _.assert( filter.formed <= 3 );
  if( filter.formed === 5 )
  return filter;

  filter._formAssociations();
  filter._formFinal();

  _.assert( filter.formed === 5 );
  Object.freeze( filter );
  return filter;
}

//

function _formAssociations()
{
  let filter = this;

  /* */

  if( filter.hubFileProvider )
  {
    if( filter.hubFileProvider.hub && filter.hubFileProvider.hub !== filter.hubFileProvider )
    {
      _.assert( filter.effectiveFileProvider === null || filter.effectiveFileProvider === filter.hubFileProvider );
      filter.effectiveFileProvider = filter.hubFileProvider;
      filter.hubFileProvider = filter.hubFileProvider.hub;
    }
  }

  if( filter.effectiveFileProvider )
  {
    if( filter.effectiveFileProvider instanceof _.FileProvider.Hub )
    {
      _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider );
      filter.hubFileProvider = filter.effectiveFileProvider;
      filter.effectiveFileProvider = null;
    }
  }

  if( filter.effectiveFileProvider && filter.effectiveFileProvider.hub )
  {
    _.assert( filter.hubFileProvider === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
  }

  if( !filter.defaultFileProvider )
  {
    filter.defaultFileProvider = filter.defaultFileProvider || filter.effectiveFileProvider || filter.hubFileProvider;
  }

  /* */

  _.assert( !filter.hubFileProvider || filter.hubFileProvider instanceof _.FileProvider.Abstract, 'Expects {- filter.hubFileProvider -}' );
  _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );
  _.assert( !filter.effectiveFileProvider || !( filter.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  /* */

  filter.maskAll = _.RegexpObject( filter.maskAll );
  filter.maskTerminal = _.RegexpObject( filter.maskTerminal );
  filter.maskDirectory = _.RegexpObject( filter.maskDirectory );

  filter.maskTransientAll = _.RegexpObject( filter.maskTransientAll );
  filter.maskTransientTerminal = _.RegexpObject( filter.maskTransientTerminal );
  filter.maskTransientDirectory = _.RegexpObject( filter.maskTransientDirectory );

  /* */

  filter.formed = 1;
}

//

function _formPre()
{
  let filter = this;

  if( filter.formed < 1 )
  filter._formAssociations();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 1 );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.arrayIs( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.arrayIs( filter.postfixPath ) );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  filter.formed = 2;
}

//

function _formPaths()
{
  let filter = this;

  if( filter.formed === 3 )
  return;
  if( filter.formed < 2 )
  filter._formPre();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );

  let applicableToTrue = false;
  if( filter.filePath )
  applicableToTrue = !path.pathMapDstFromSrc( filter.filePath ).filter( ( e ) => !_.boolLike( e ) ).length;
  filter.prefixesApply({ applicableToTrue : applicableToTrue });

  filter.pathsNormalize();

  if( _.mapIs( filter.filePath ) )
  filter.filePath = filter.filePathGlobSimplify( filter.basePath, filter.filePath );

  filter.formed = 3;
}

//

function _formMasks()
{
  let filter = this;

  if( filter.formed < 3 )
  filter._formPaths();

  let fileProvider = filter.effectiveFileProvider || filter.defaultFileProvider || filter.hubFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 3 );

  /* */

  filter.maskExtensionApply();
  filter.maskBeginsApply();
  filter.maskEndsApply();
  filter.filePathGenerate();

  filter.formed = 4;
}

//

function _formFinal()
{
  let filter = this;

  // if( filter.filePath && filter.filePath.length === 2 )
  // debugger;

  if( filter.formed < 4 )
  filter._formMasks();

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  /* - */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 4 );
    _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );
    _.assert( _.mapIs( filter.formedBasePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( _.mapIs( filter.formedFilePath ) );
    _.assert( _.mapIs( filter.basePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( _.objectIs( filter.effectiveFileProvider ) );
    _.assert( filter.hubFileProvider === filter.effectiveFileProvider.hub || filter.hubFileProvider === filter.effectiveFileProvider );
    _.assert( filter.hubFileProvider instanceof _.FileProvider.Abstract );
    _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );

    let filePath = filter.filePathArrayGet( filter.formedFilePath ).filter( ( e ) => _.strIs( e ) );
    _.assert( path.s.noneAreGlob( filePath ) );
    _.assert( path.s.allAreAbsolute( filePath ) || path.s.allAreGlobal( filePath ) );

    if( _.mapIs( filter.formedBasePath ) )
    for( let p in filter.formedBasePath )
    {
      let filePath = p;
      let basePath = filter.formedBasePath[ p ];
      _.assert
      (
        path.isAbsolute( filePath ) && path.isNormalized( filePath ) && !path.isGlob( filePath ) && !path.isTrailed( filePath ),
        () => 'Stem path should be absolute and normalized, but not glob, neither trailed' + '\nstemPath : ' + _.toStr( filePath )
      );
      _.assert
      (
        path.isAbsolute( basePath ) && path.isNormalized( basePath ) && !path.isGlob( basePath ) && !path.isTrailed( basePath ),
        () => 'Base path should be absolute and normalized, but not glob, neither trailed' + '\nbasePath : ' + _.toStr( basePath )
      );
    }

    /* time */

    if( filter.notOlder )
    _.assert( _.numberIs( filter.notOlder ) || _.dateIs( filter.notOlder ) );

    if( filter.notNewer )
    _.assert( _.numberIs( filter.notNewer ) || _.dateIs( filter.notNewer ) );

    if( filter.notOlderAge )
    _.assert( _.numberIs( filter.notOlderAge ) || _.dateIs( filter.notOlderAge )  );

    if( filter.notNewerAge )
    _.assert( _.numberIs( filter.notNewerAge ) || _.dateIs( filter.notNewerAge ) );

  }

  /* - */

  filter.applyTo = filter._applyToRecordNothing;

  if( filter.notOlder || filter.notNewer || filter.notOlderAge || filter.notNewerAge )
  filter.applyTo = filter._applyToRecordFull;
  else if( filter.hasMask() )
  filter.applyTo = filter._applyToRecordMasks;

  filter.formed = 5;
}

// --
// mutator
// --

function maskExtensionApply()
{
  let filter = this;

  if( filter.hasExtension )
  {
    _.assert( _.strIs( filter.hasExtension ) || _.strsAreAll( filter.hasExtension ) );

    filter.hasExtension = _.arrayAs( filter.hasExtension );
    filter.hasExtension = new RegExp( '^.*\\.(' + _.regexpsEscape( filter.hasExtension ).join( '|' ) + ')(\\.|$)(?!.*\/.+)', 'i' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll, { includeAll : filter.hasExtension } );
    filter.hasExtension = null;
  }

}

//

function maskBeginsApply()
{
  let filter = this;

  if( filter.begins )
  {
    _.assert( _.strIs( filter.begins ) || _.strsAreAll( filter.begins ) );

    filter.begins = _.arrayAs( filter.begins );
    filter.begins = new RegExp( '^(\\.\\/)?(' + _.regexpsEscape( filter.begins ).join( '|' ) + ')' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.begins } );
    filter.begins = null;
  }

}

//

function maskEndsApply()
{
  let filter = this;

  if( filter.ends )
  {
    _.assert( _.strIs( filter.ends ) || _.strsAreAll( filter.ends ) );

    filter.ends = _.arrayAs( filter.ends );
    filter.ends = new RegExp( '(' + '^\.|' + _.regexpsEscape( filter.ends ).join( '|' ) + ')$' );

    filter.maskAll = _.RegexpObject.And( filter.maskAll,{ includeAll : filter.ends } );
    filter.ends = null;
  }

}

//

function filePathGenerate()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  let globFound = !filter.srcFilter;
  if( globFound )
  globFound = filter.filePathHasGlob();

  if( globFound )
  {

    _.assert( !filter.srcFilter );
    _.assert( filter.formedFilterMap === null );
    filter.formedFilterMap = Object.create( null );

    // debugger;
    let _processed = path.pathMapToRegexps( filter.filePath, filter.basePath  );
    // debugger;

    filter.formedBasePath = _processed.unglobedBasePath;
    filter.formedFilePath = _processed.unglobedFilePath;

    filter.assertBasePath();

    for( let p in _processed.regexpMap )
    {
      let basePath = filter.formedBasePath[ p ];
      _.assert( _.strDefined( basePath ), 'No base path for', p );
      let relative = p;
      let regexps = _processed.regexpMap[ p ];
      _.assert( !filter.formedFilterMap[ relative ] );
      let subfilter = filter.formedFilterMap[ relative ] = Object.create( null );
      // _.assert( regexps.actual.length === 0 );
      subfilter.maskAll = _.RegexpObject.Or( filter.maskAll.clone(), { includeAll : regexps.actualAll, includeAny : regexps.actualAny, excludeAny : regexps.notActual } );
      subfilter.maskTerminal = filter.maskTerminal.clone();
      subfilter.maskDirectory = filter.maskDirectory.clone();
      subfilter.maskTransientAll = filter.maskTransientAll.clone();
      subfilter.maskTransientTerminal = _.RegexpObject.Or( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
      // subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone(); // zzz
      subfilter.maskTransientDirectory = _.RegexpObject.Or( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
      _.assert( subfilter.maskAll !== filter.maskAll );
      // debugger;
    }

  }
  else
  {
    filter.formedBasePath = _.entityShallowClone( filter.basePath );
    filter.formedFilePath = _.entityShallowClone( filter.filePath );
  }

}

//

function filePathSelect( srcPath, dstPath )
{
  let srcFilter = this;
  let dstFilter = srcFilter.dstFilter;
  let fileProvider = srcFilter.hubFileProvider || srcFilter.effectiveFileProvider || srcFilter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( srcPath ) );
  _.assert( _.strIs( dstPath ) );

  let filePath = path.pathMapExtend( null, srcPath, dstPath );

  if( dstFilter )
  try
  {

    if( _.mapIs( dstFilter.basePath ) )
    for( let dstPath2 in dstFilter.basePath )
    {
      if( dstPath !== dstPath2 )
      {
        _.assert( _.strIs( dstFilter.basePath[ dstPath2 ] ), () => 'No base path for ' + dstPath2 );
        delete dstFilter.basePath[ dstPath2 ];
      }
    }

    dstFilter.filePath = filePath;
    dstFilter.form();
    dstPath = dstFilter.filePathSimplest();
    _.assert( _.strIs( dstPath ) );
    filePath = dstFilter.filePath;
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form destination filter\n', err );
  }

  try
  {

    if( _.mapIs( srcFilter.basePath ) )
    for( let srcPath2 in srcFilter.basePath )
    {
      if( filePath[ srcPath2 ] === undefined )
      {
        _.assert( _.strIs( srcFilter.basePath[ srcPath2 ] ), () => 'No base path for ' + srcPath2 );
        delete srcFilter.basePath[ srcPath2 ];
      }
    }

    srcFilter.filePath = filePath;
    _.assert( dstFilter === null || srcFilter.filePath === dstFilter.filePath );
    srcFilter.form();
    _.assert( dstFilter === null || srcFilter.filePath === dstFilter.filePath );
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form source filter\n', err );
  }

}

//

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let adjustingFilePath = true;
  let paired = false;

  if( filter.prefixPath === null && filter.postfixPath === null )
  return filter;

  if( filter.srcFilter && filter.srcFilter.filePath === filter.filePath )
  paired = true;

  if( filter.dstFilter && filter.dstFilter.filePath === filter.filePath )
  paired = true;

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.strsAreAll( filter.postfixPath ) );
  _.assert( filter.postfixPath === null, 'not implemented' );

  if( !filter.filePath )
  {
    adjustingFilePath = false;
    // filter.filePathFromFixes();
  }

  /* */

  _.assert( filter.postfixPath === null || !path.s.AllAreGlob( filter.postfixPath ) );

  if( adjustingFilePath )
  {
    let o2 = { basePath : 0, fixes : 0, filePath : 1, onEach : filePathEach }
    filter.allPaths( o2 );
  }

  if( filter.basePath )
  {
    filter.basePathEach( basePathEach );
    filter.basePathSimplify();
  }

  /* */

  filter.prefixPath = null;
  filter.postfixPath = null;

  if( !Config.debug )
  return filter;

  _.assert( !_.arrayIs( filter.basePath ) );
  _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) || filter.basePath === null );

  if( filter.basePath && filter.filePath )
  filter.assertBasePath();

  // debugger;

  if( paired && filter.srcFilter && filter.srcFilter.filePath !== filter.filePath )
  filter.srcFilter.filePath = filter.filePath;

  if( paired && filter.dstFilter && filter.dstFilter.filePath !== filter.filePath )
  filter.dstFilter.filePath = filter.filePath;

  return filter;

  /* */

  function filePathEach( it )
  {
    _.assert( it.value === null || _.strIs( it.value ) || _.boolLike( it.value ) || _.arrayIs( it.value ) );

    if( filter.srcFilter )
    {
      if( it.side === 'source' )
      return;
    }
    else if( filter.dstFilter )
    {
      if( it.side === 'destination' )
      return;
    }

    if( it.side === 'source' && _.boolLike( filter.filePath[ it.value ] ) )
    {
      return;
    }

    if( filter.prefixPath || filter.postfixPath )
    {
      if( it.value === null || ( o.applicableToTrue && _.boolLike( it.value ) && it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
      }
      else if( !_.boolLike( it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', it.value, filter.postfixPath || '.' );
      }
    }
  }

  /* */

  function basePathEach( filePath, basePath )
  {
    if( !filter.prefixPath && !filter.postfixPath )
    return;

    let r = Object.create( null );

    basePath = path.s.join( filter.prefixPath || '.', basePath, filter.postfixPath || '.' );

    if( filePath === null )
    return basePath;

    if( !_.boolLike( filter.filePath[ filePath ] ) )
    filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

    if( _.arrayIs( filePath ) )
    {
      for( let f = 0 ; f < filePath.length ; f++ )
      r[ filePath[ f ] ] = basePath[ f ];
      return r;
    }
    else
    {
      r[ filePath ] = basePath;
      return r;
    }

  }

}

prefixesApply.defaults =
{
  applicableToTrue : 0,
}

//

function prefixesRelative( prefixPath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  prefixPath = prefixPath || filter.prefixPath;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !prefixPath || filter.prefixPath === null || filter.prefixPath === prefixPath );

  if( filter.filePath && !prefixPath )
  {

    let filePath;
    if( filter.srcFilter )
    filePath = path.pathMapDstFromDst( filter.filePath );
    else
    filePath = path.pathMapSrcFromSrc( filter.filePath );

    if( filePath )
    {
      filePath = filePath.filter( ( filePath ) => _.strIs( filePath ) );
      if( path.s.anyAreAbsolute( filePath ) )
      filePath = filePath.filter( ( filePath ) => path.isAbsolute( filePath ) );
    }

    if( filePath && filePath.length )
    {
      prefixPath = path.normalize( path.common( filePath ) );
    }

  }

  if( prefixPath )
  {

    if( filter.basePath )
    filter.basePath = path.pathMapFilter( filter.basePath, relative_functor() );

    if( filter.filePath )
    {
      if( filter.srcFilter )
      filter.filePath = path.pathMapRefilter( filter.filePath, relative_functor( 'dst' ) );
      else if( filter.dstFilter )
      filter.filePath = path.pathMapRefilter( filter.filePath, relative_functor( 'src' ) );
      else
      filter.filePath = path.pathMapRefilter( filter.filePath, relative_functor() );
    }

    filter.prefixPath = prefixPath;
  }

  return prefixPath;

  /* */

  function relative_functor( side )
  {
    return function relative( filePath, it )
    {

      if( !side || it.side === side || it.side === undefined )
      {
        if( !_.strIs( filePath ) )
        return filePath;

        _.assert( path.isGlobal( prefixPath ) ^ path.isGlobal( filePath ) ^ true );

        if( path.isAbsolute( prefixPath ) ^ path.isAbsolute( filePath ) )
        return filePath;

        return path.relative( prefixPath, filePath );
      }

      return filePath;
    }
  }

}

//

function pathLocalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = path.normalize( filePath );

  if( filter.effectiveFileProvider && !path.isGlobal( filePath ) )
  return filePath;

  let effectiveProvider2 = fileProvider.providerForPath( filePath );
  _.assert( filter.effectiveFileProvider === null || effectiveProvider2 === null || filter.effectiveFileProvider === effectiveProvider2, 'Record filter should have paths of single file provider' );
  filter.effectiveFileProvider = filter.effectiveFileProvider || effectiveProvider2;

  if( filter.effectiveFileProvider )
  {

    if( !filter.hubFileProvider )
    filter.hubFileProvider = filter.effectiveFileProvider.hub;
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider === filter.effectiveFileProvider.hub );
    _.assert( filter.effectiveFileProvider.hub === null || filter.hubFileProvider instanceof _.FileProvider.Hub );

  }

  if( !path.isGlobal( filePath ) )
  return filePath;

  let provider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let result = provider.path.localFromGlobal( filePath );
  return result;
}

//

function pathsNormalize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let originalFilePath = filter.filePath;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );
  _.assert( filter.prefixPath === null, 'Prefixes should be applied so far' );
  _.assert( filter.postfixPath === null, 'Posftixes should be applied so far' );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );
  _.assert( _.mapIs( filter.filePath ) || !filter.srcFilter, 'Destination filter should have file map' );

  /* */

  filter.filePath = filter.filePathNormalize( filter.filePath );
  _.assert( _.mapIs( filter.filePath ) );

  filter.basePath = filter.basePathNormalize( filter.basePath, filter.filePath );
  _.assert( _.mapIs( filter.basePath ) || filter.basePath === null || _.mapKeys( filter.filePath ).length === 0 );

  filter.filePathAbsolutize();

  filter.providersNormalize();

  /* */

  if( !Config.debug )
  return;

  if( filter.basePath )
  filter.assertBasePath();

  _.assert
  (
       ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
    || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
    || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
    , 'Cant deduce base path'
  );

}

//

function globalsFromLocals()
{
  let filter = this;

  if( !filter.effectiveFileProvider )
  return;

  if( filter.basePath )
  filter.basePath = filter.effectiveFileProvider.globalsFromLocals( filter.basePath );

  if( filter.filePath )
  filter.filePath = filter.effectiveFileProvider.globalsFromLocals( filter.filePath );

}

// --
// combiner
// --

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
  // _.assert( src.filePath === null || src.filePath === undefined );
  // _.assert( filter.filePath === null );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );

  // _.assert( src.filePath === null || src.filePath === undefined );
  // _.assert( src.basePath === null || src.basePath === undefined );
  // _.assert( filter.filePath === null );
  // _.assert( filter.basePath === null );

  // _.assert( !!( filter.hubFileProvider || src.hubFileProvider ) );
  _.assert( !filter.effectiveFileProvider || !src.effectiveFileProvider || filter.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  // _.assert( filter.filePath === null );
  // _.assert( src.filePath === null || src.filePath === undefined );

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
    _.assert( _.strIs( src[ a ] ) || _.strsAreAll( src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );
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

function _pathsJoin_pre( routine, args )
{
  let filter = this;
  let o;

  if( _.mapIs( args[ 0 ] ) )
  o = args[ 0 ];
  else
  o = { src : args }

  _.assert( arguments.length === 2 );
  _.routineOptions( routine, o );

  return o;
}

//

function _pathsJoin_body( o )
{
  let filter = this;

  if( _.arrayLike( o.src ) )
  {
    for( let a = 0 ; a < o.src.length ; a++ )
    {
      let o2 = _.mapExtend( null, o );
      o2.src = o2.src[ a ];
      filter._pathsJoin.body.call( filter, o2 );
    }
    return filter;
  }

  if( Config.debug )
  if( o.src && !( o.src instanceof filter.Self ) )
  _.assertMapHasOnly( o.src, filter.fieldsOfCopyableGroups );

  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !o.src.formed || o.src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !o.src.hubFileProvider || filter.hubFileProvider === o.src.hubFileProvider );
  _.assert( o.src !== filter );
  _.assert( _.objectIs( o.src ) );
  _.assert( o.src.filePath === null || o.src.filePath === undefined || o.src.filePath === '.' || _.strIs( o.src.filePath ) );

  let fileProvider = filter.hubFileProvider || filter.defaultFileProvider || filter.effectiveFileProvider || o.src.hubFileProvider || o.src.defaultFileProvider || o.src.effectiveFileProvider;
  let path = fileProvider.path;

  /* */

  if( o.src.hubFileProvider )
  filter.hubFileProvider = o.src.hubFileProvider;

  for( let n in o.joiningWithoutNullMap )
  if( o.src[ n ] !== undefined && o.src[ n ] !== null )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src[ n ] );
  }

  /* */

  for( let n in o.joiningMap )
  if( o.src[ n ] !== undefined )
  {
    _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    filter[ n ] = path.join( filter[ n ], o.src.basePath );
  }

  /* */

  for( let a in o.appendingMap )
  {
    if( o.src[ a ] === null || o.src[ a ] === undefined )
    continue;

    _.assert( _.strIs( o.src[ a ] ) || _.strsAreAll( o.src[ a ] ) );
    _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );

    if( filter[ a ] === null )
    {
      filter[ a ] = o.src[ a ];
    }
    else
    {
      if( _.strIs( filter[ a ] ) )
      filter[ a ] = [ filter[ a ] ];
      _.arrayAppendOnce( filter[ a ], o.src[ a ] );
    }

  }

  return filter;
}

_pathsJoin_body.defaults =
{

  src : null,

  joiningWithoutNullMap :
  {
    filePath : null,
  },

  joiningMap :
  {
    basePath : null,
  },

  appendingMap :
  {
    prefixPath : null,
    postfixPath : null,
  },

}

let _pathsJoin = _.routineFromPreAndBody( _pathsJoin_pre, _pathsJoin_body );

//

function pathsJoin()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningWithoutNullMap :
    {
      filePath : null,
    },
    joiningMap :
    {
      basePath : null,
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsJoinWithoutNull()
{
  let filter = this;
  return filter._pathsJoin
  ({
    src : arguments,
    joiningWithoutNullMap :
    {
      filePath : null,
      basePath : null,
    },
    joiningMap :
    {
    },
    appendingMap :
    {
      prefixPath : null,
      postfixPath : null,
    },
  });
}

//

function pathsExtend2( src )
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
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  // if( src.prefixPath )
  // src.prefixesApply();
  //
  // if( filter.prefixPath )
  // filter.prefixesApply();

  if( src.prefixPath && filter.prefixPath )
  {
    let prefixPath = src.prefixPath;
    src.prefixesApply();
    filter.prefixesApply();
    _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
    if( filter.filePath === null )
    filter.prefixPath = prefixPath;
  }

  if( src.prefixPath && src.filePath )
  {
    src.prefixesApply();
  }

  if( filter.prefixPath && filter.filePath )
  {
    filter.prefixesApply();
  }

  _.assert( src.prefixPath === null || filter.prefixPath === null );
  _.assert( src.postfixPath === null || filter.postfixPath === null );
  _.assert( src.postfixPath === null && filter.postfixPath === null, 'not implemented' );

  filter.prefixPath = src.prefixPath || filter.prefixPath;
  filter.postfixPath = src.postfixPath || filter.postfixPath;

  /* */

  if( src.basePath && filter.basePath )
  {

    if( _.strIs( src.basePath ) )
    src.basePath = src.basePathFrom( src.basePath, src.filePath || {} );
    _.assert( src.basePath === null || _.mapIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.basePath, filter.filePath || {} );
    _.assert( filter.basePath === null || _.mapIs( filter.basePath ) );

    if( _.mapIs( src.basePath ) )
    filter.basePath = _.mapExtend( filter.basePath, src.basePath );

  }
  else
  {
    filter.basePath = filter.basePath || src.basePath;
  }

  /* */

  if( filter.filePath && src.filePath )
  {

    let isDst = !!filter.srcFilter || !!src.srcFilter;
    if( ( _.mapIs( filter.filePath ) && _.mapIs( src.filePath ) ) || !isDst )
    {
      filter.filePath = path.pathMapExtend( filter.filePath, src.filePath, null );
    }
    else if( !_.mapIs( src.filePath ) )
    {
      debugger; xxx
      filter.filePath = path.pathMapExtend( filter.filePath, filter.filePath, src.filePath );
    }
    else if( !_.mapIs( filter.filePath ) )
    {
      filter.filePath = path.pathMapExtend( null, src.filePath, filter.filePath );
    }

  }
  else
  {
    filter.filePath = filter.filePath || src.filePath;
  }

  /* */

  return filter;
}

//

function pathsInherit( src )
{
  let filter = this;
  let paired = false;

  if( filter.srcFilter && filter.srcFilter.filePath === filter.filePath )
  paired = true;

  if( filter.dstFilter && filter.dstFilter.filePath === filter.filePath )
  paired = true;

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
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  /* */

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider;

  /* */

  if( !( src instanceof Self ) )
  src = fileProvider.recordFilter( src );

  if( src.prefixPath && filter.prefixPath )
  {
    let prefixPath = filter.prefixPath;
    src.prefixesApply();
    filter.prefixesApply();
    _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
    if( filter.filePath === null )
    filter.prefixPath = prefixPath;
  }

  _.assert( src.prefixPath === null || filter.prefixPath === null );
  _.assert( src.postfixPath === null || filter.postfixPath === null );
  _.assert( src.postfixPath === null && filter.postfixPath === null, 'not implemented' );

  filter.prefixPath = filter.prefixPath || src.prefixPath;
  filter.postfixPath = filter.postfixPath || src.postfixPath;

  /* xxx */

  if( filter.filePath && src.filePath )
  {

    let srcPathMap = src.filePathOnlyBools();
    let filterPathArray = filter.filePathSrcArrayNonBoolGet( filter.filePath, 0 );

    if( filterPathArray.length === 0 )
    {
      if( filter.srcFilter && !_.mapIs( filter.srcFilter ) )
      filter.filePath = path.pathMapExtend( null, filter.filePath, null );

      if( src.srcFilter && !_.mapIs( src.srcFilter ) )
      src.filePath = path.pathMapExtend( null, src.filePath, null );

      filter.filePath = path.pathMapExtend( filter.filePath, src.filePath, null );
    }
    else if( Object.keys( srcPathMap ).length )
    {
      if( filter.srcFilter && !_.mapIs( filter.srcFilter ) )
      filter.filePath = path.pathMapExtend( null, filter.filePath, null );

      filter.filePath = path.pathMapExtend( filter.filePath, srcPathMap, null );
    }
    else
    {
      let srcPath = filter.filePathSrcArrayGet();
      if( srcPath.length === 1 && srcPath[ 0 ] === '.' )
      {
        let dstPath = filter.filePathDstArrayGet();
        if( !dstPath.length )
        dstPath = null;
        filter.filePath = path.pathMapExtend( null, src.filePathSrcArrayGet(), dstPath );
      }
    }

  }
  else
  {
    filter.filePath = filter.filePath || src.filePath;
  }

  /* */

  if( src.basePath && filter.basePath )
  {

    if( _.strIs( src.basePath ) )
    src.basePath = src.basePathFrom( src.basePath, src.filePath || {} );
    _.assert( src.basePath === null || _.mapIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.basePath, filter.filePath || {} );
    _.assert( filter.basePath === null || _.mapIs( filter.basePath ) );

    if( _.mapIs( src.basePath ) )
    {
      for( let filePath in src.basePath )
      {
        let basePath = src.basePath[ filePath ];
        if( !_.mapIs( filter.filePath ) || filter.filePath[ filePath ] !== undefined )
        if( !filter.basePath[ filePath ] )
        filter.basePath[ filePath ] = basePath;
      }
      // filter.basePath = _.mapExtend( filter.basePath, src.basePath );
    }

  }
  else
  {
    filter.basePath = filter.basePath || src.basePath;
  }

  /* */

  if( paired && filter.srcFilter && filter.srcFilter.filePath !== filter.filePath )
  filter.srcFilter.filePath = filter.filePath;

  if( paired && filter.dstFilter && filter.dstFilter.filePath !== filter.filePath )
  filter.dstFilter.filePath = filter.filePath;

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
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( filter.filePath === null );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
  _.assert( src !== filter );
  _.assert( src.filePath === null || src.filePath === undefined || filter.filePath === null );

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  let replacing =
  {

    hubFileProvider : null,
    basePath : null,
    filePath : null,
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

// --
// base path
// --

function relativeFor( filePath )
{
  let filter = this;
  let basePath = filter.basePathForFilePath( filePath );
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  relativePath = path.relative( basePath, filePath );

  return relativePath;
}

//

function basePathForFilePath( filePath )
{
  let filter = this;
  let result = null;

  if( !filter.basePath )
  return;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];

  _.assert( result !== undefined, 'No base path for ' + filePath );

  return result;
}

//

function basePathFor( filePath )
{
  let filter = this;
  let result = null;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( !filter.basePath )
  return;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];
  if( !result && !_.strBegins( filePath, '..' ) && !_.strBegins( filePath, '/..' ) )
  {

    let filePath2 = path.join( filePath, '..' );
    while( filePath2 !== '..' && filePath2 !== '/..' )
    {
      result = filter.basePath[ filePath2 ];
      if( result )
      break;
      filePath2 = path.join( filePath2, '..' );
    }

  }

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

function basePathFrom( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( basePath === undefined )
  basePath = filter.basePath
  if( filePath === undefined )
  filePath = filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );

  if( basePath )
  basePath = filter.pathLocalize( basePath );
  filePath = filter.filePathArrayNonBoolGet( filePath );

  let basePath2 = Object.create( null );

  if( basePath )
  {
    for( let s = 0 ; s < filePath.length ; s++ )
    {
      let thisFilePath = filePath[ s ];
      basePath2[ thisFilePath ] = basePath;
    }
  }
  else
  {
    for( let s = 0 ; s < filePath.length ; s++ )
    {
      let thisFilePath = filePath[ s ];
      basePath2[ thisFilePath ] = path.fromGlob( thisFilePath );
    }
  }

  if( !basePath || _.mapKeys( basePath2 ).length )
  return basePath2;
  else
  return basePath;
}

//

function basePathMapNormalize( basePathMap )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let basePathMap2 = Object.create( null );
  basePathMap = basePathMap || filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  // let o3 = { basePath : 1, fixes : 0, filePath : 0, onEach : basePathEach }
  // filter.allPaths( o3 );

  for( let filePath in basePathMap )
  {
    let basePath = basePathMap[ filePath ];

    _.assert( _.strIs( basePath ) );
    _.assert( _.strIs( filePath ) );
    _.assert( !path.isGlob( basePath ) );
    // _.assert( !path.isGlob( filePath ) );

    filePath = filter.pathLocalize( filePath );
    basePath = filter.pathLocalize( basePath );

    // filePath = path.fromGlob( filePath ); // yyy

    basePathMap2[ filePath ] = basePath;

    // _.assert( !path.isGlob( it.value ) ) );
    // it.value = filter.pathLocalize( it.value );
    // if( it.side === 'source' )
    // it.value = path.fromGlob( it.value );
  }

  return basePathMap2;
}

//

function basePathNormalize( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filePath || filter.filePath;

  _.assert( !_.arrayIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 2 );

  if( basePath === null || _.strIs( basePath ) )
  {
    basePath = filter.basePathFrom( basePath, filePath );
  }
  else if( _.mapIs( basePath ) )
  {
    basePath = filter.basePathMapNormalize( basePath );
  }
  else _.assert( 0 );

  _.assert( _.mapIs( basePath ) || basePath === null || _.mapKeys( filePath ).length === 0 );

  return basePath;
}

//

function basePathSimplify()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( !filter.basePath || _.strIs( filter.basePath ) )
  return;

  let basePath = _.arrayAppendArrayOnce( [], _.mapVals( filter.basePath ) );

  if( basePath.length !== 1 )
  return;

  filter.basePath = basePath[ 0 ];

}

//

function basePathEach( onEach )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  // debugger;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( arguments.length === 1 );

  let basePath = filter.basePath;
  if( !_.mapIs( basePath ) )
  basePath = filter.basePathFrom( basePath, filter.filePath );

  // _.assert( _.mapIs( basePath ) );

  if( _.strIs( basePath ) )
  {
    // debugger;
    let r = onEach( null, basePath );
    // debugger;
    _.assert( r === undefined || _.strIs( r ) );
    if( r )
    basePath = r;
  }
  else if( _.mapIs( basePath ) )
  for( let b in basePath )
  {
    let r = onEach( b, basePath[ b ] );
    _.assert( r === undefined || _.mapIs( r ) );
    if( r )
    {
      delete basePath[ b ];
      _.mapExtend( basePath, r );
    }
  }
  else _.assert( 0 );

  filter.basePath = basePath;

}

// --
// file path
// --

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

//

function filePathNormalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  if( !_.mapIs( filePath ) )
  filePath = path.pathMapExtend( null, filePath );

  if( filter.srcFilter )
  {

    for( let srcPath in filePath )
    {
      let dstPath = filePath[ srcPath ];

      if( !_.strIs( dstPath ) )
      continue;

      let dstPath2 = path.normalize( dstPath );
      dstPath2 = filter.pathLocalize( dstPath2 );
      if( dstPath === dstPath2 )
      continue;
      _.assert( _.strIs( dstPath2 ) );
      filePath[ srcPath ] = dstPath2;
    }

  }
  else
  {

    for( let srcPath in filePath )
    {
      let srcPath2 = path.normalize( srcPath );
      srcPath2 = filter.pathLocalize( srcPath2 );
      if( srcPath === srcPath2 )
      continue;
      _.assert( _.strIs( srcPath2 ) );
      filePath[ srcPath2 ] = filePath[ srcPath ];
      delete filePath[ srcPath ];
    }

  }

  _.assert( _.mapIs( filePath ) );

  return filePath;
}

//

function filePathPrependBasePath( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );

  if( filter.srcFilter )
  {

    debugger;
    for( let srcPath in filePath )
    {

      let dstPath = filePath[ srcPath ];
      let b = basePath[ dstPath ];
      if( !_.strIs( dstPath ) || path.isAbsolute( dstPath ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, dstPath );
      if( joinedPath !== dstPath )
      {
        delete basePath[ dstPath ];
        basePath[ joinedPath ] = b;
        filePath[ srcPath ] = joinedPath;
      }

    }
    debugger;

  }
  else
  {

    for( let srcPath in filePath )
    {

      let b = basePath[ srcPath ];
      let dstPath = filePath[ srcPath ];

      if( path.isAbsolute( srcPath ) )
      continue;
      if( !b )
      continue;
      if( !path.isAbsolute( b ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, srcPath );
      if( joinedPath !== srcPath )
      {
        delete basePath[ srcPath ];
        basePath[ joinedPath ] = b;
        delete filePath[ srcPath ];
        path.pathMapExtend( filePath, joinedPath, dstPath );
      }

    }

  }

}

//

function filePathMultiplyRelatives( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );
  _.assert( !filter.srcFilter );

  let relativePath = _.mapExtend( null, filePath );

  for( let r in relativePath )
  if( path.isRelative( r ) )
  {
    // _.assert( basePath[ r ] !== undefined );
    delete basePath[ r ];
    delete filePath[ r ];
  }
  else
  {
    delete relativePath[ r ];
  }

  // debugger;

  let basePath2 = _.mapExtend( null, basePath );

  for( let b in basePath2 )
  {
    let currentBasePath = basePath[ b ];
    let normalizedFilePath = path.fromGlob( b );
    for( let r in relativePath )
    {
      let dstPath = relativePath[ r ];
      let srcPath = path.join( normalizedFilePath, r );
      _.assert( filePath[ srcPath ] === undefined || filePath[ srcPath ] === dstPath );
      filePath[ srcPath ] = dstPath;
      _.assert( basePath[ srcPath ] === undefined || basePath[ srcPath ] === currentBasePath );
      if( !_.boolLike( dstPath ) ) // yyy
      basePath[ srcPath ] = currentBasePath;
    }
  }

  // debugger;

}

//

function filePathAbsolutize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( _.mapKeys( filter.filePath ).length === 0 )
  return;

  _.assert( _.mapIs( filter.basePath ) );
  _.assert( _.mapIs( filter.filePath ) );

  let filePath = filter.filePathArrayGet().filter( ( e ) => _.strIs( e ) );

  if( path.s.anyAreRelative( filePath ) )
  {
    if( path.s.anyAreAbsolute( filePath ) )
    filter.filePathMultiplyRelatives( filter.filePath, filter.basePath );
    else
    filter.filePathPrependBasePath( filter.filePath, filter.basePath );
  }

}

//

function filePathGlobSimplify( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filePath || filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );

  // return filePath; // xxx

  let dst = filter.filePathDstArrayGet();

  if( _.any( dst, ( e ) => _.boolIs( e ) ) )
  return filePath

  for( let src in filePath )
  {
    if( _.strEnds( src, '/**' ) || src === '**' )
    simplify( src, '**' )
  }

  return filePath;

  //

  function simplify( src, what )
  {
    let src2 = path.normalize( _.strRemoveEnd( src, what ) );
    if( !path.isGlob( src2 ) )
    {
      _.assert( filePath[ src2 ] === undefined )
      filePath[ src2 ] = filePath[ src ];
      delete filePath[ src ];

      if( _.mapIs( basePath ) )
      {
        _.assert( basePath[ src2 ] === undefined )
        basePath[ src2 ] = basePath[ src ];
        delete basePath[ src ];
      }

    }
  }

}

//

function filePathFromFixes()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.filePath )
  {
    // adjustingFilePath = false;
    filter.filePath = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
    _.assert( path.s.allAreAbsolute( filter.filePath ), 'Can deduce file path' );
  }

  return filter.filePath;
}

//

function filePathSimplest()
{
  let filter = this;

  // let filePath = filter.srcFilter ? filter.filePathDstNormalizedGet( filter.filePath ) : filter.filePathSrcNormalizedGet( filter.filePath );
  let filePath = filter.filePathNormalizedGet();

  _.assert( !_.mapIs( filePath ) );

  if( _.arrayIs( filePath ) && filePath.length === 1 )
  return filePath[ 0 ];

  // if( filter.filePath.length === 1 )
  // filter.filePath = filter.filePath[ 0 ];

  return filePath;
}

//

function filePathNullizeMaybe( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  let filePath2 = filter.filePathDstArrayGet( filePath );
  if( _.any( filePath2, ( e ) => !_.boolLike( e ) ) )
  return filePath;

  return path.pathMapRefilter( filePath, ( e ) => _.boolLike( e ) && e ? null : e );
}

//

function filePathHasGlob( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  let globFound = true;
  if( _.none( path.s.areGlob( filter.filePath ) ) )
  if( !filter.filePathDstArrayGet().filter( ( e ) => _.boolLike( e ) ).length ) // xxx
  globFound = false;

  return globFound;
}

//

function filePathDstHasAllBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filter.filePathDstArrayGet( filePath );

  if( !filePath.length )
  return true;

  return !filePath.filter( ( e ) => !_.boolLike( e ) ).length;
}

//

function filePathDstHasAnyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filter.filePathDstArrayGet( filePath );

  return !!filePath.filter( ( e ) => _.boolLike( e ) ).length;
}

//

function filePathOnlyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null || _.strIs( filePath ) || _.arrayIs( filePath ) )
  return {};

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.mapIs( filePath ) );

  let result = Object.create( null );
  for( let src in filePath )
  {
    if( _.boolIs( filePath[ src ] ) )
    result[ src ] = filePath[ src ];
  }

  return result;
}

//

function filePathDstArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.srcFilter )
  {
    return path.pathMapDstFromDst( filePath );
  }
  else
  {
    return path.pathMapDstFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.srcFilter )
  {
    return path.pathMapSrcFromDst( filePath );
  }
  else
  {
    return path.pathMapSrcFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.srcFilter )
  {
    filePath = path.pathMapDstFromDst( filePath );
  }
  else
  {
    filePath = path.pathMapSrcFromSrc( filePath );
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathDstArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( boolFallingBack === undefined )
  boolFallingBack = 1;

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter.srcFilter )
  {
    filePath = path.pathMapDstFromDst( filePath );
  }
  else
  {
    filePath = path.pathMapDstFromSrc( filePath );
  }

  let filePath2 = filePath.filter( ( e ) => !_.boolLike( e ) );
  if( filePath2.length || !boolFallingBack )
  filePath = filePath2;
  else
  filePath = filePath.filter( ( e ) => !!e );

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( boolFallingBack === undefined )
  boolFallingBack = 1;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( _.mapIs( filePath ) )
  {
    let r = [];
    for( let src in filePath )
    {
      if( _.boolLike( filePath[ src ] ) )
      continue;
      r.push( src );
    }
    if( !r.length && boolFallingBack )
    {
      // filePath = Object.keys( filePath ).filter( ( e ) => !!e );
      for( let src in filePath )
      {
        if( !filePath[ src ] )
        continue;
        r.push( src );
      }
    }
    filePath = r;
  }
  else
  {
    if( filter.srcFilter )
    {
      filePath = path.pathMapSrcFromDst( filePath );
    }
    else
    {
      filePath = path.pathMapSrcFromSrc( filePath );
    }
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathArrayNonBoolGet( filePath, boolFallingBack )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter.srcFilter )
  {
    return filter.filePathDstArrayNonBoolGet( filePath, boolFallingBack );
  }
  else
  {
    return filter.filePathSrcArrayNonBoolGet( filePath, boolFallingBack );
  }

}

//

function filePathDstArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.srcFilter )
  {
    filePath = path.pathMapDstFromDst( filePath );
  }
  else
  {
    filePath = path.pathMapDstFromSrc( filePath );
  }

  debugger; xxx
  let filePath2 = filePath.filter( ( e ) => _.boolLike( e ) );
  filePath = filePath2;

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathSrcArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.mapIs( filePath ) )
  {
    let r = []; debugger;

    for( let src in filePath )
    {
      if( !_.boolLike( filePath[ src ] ) )
      continue;
      r.push( src );
    }

    filePath = r;

  }
  else
  {
    if( filter.srcFilter )
    {
      filePath = path.pathMapSrcFromDst( filePath );
    }
    else
    {
      filePath = path.pathMapSrcFromSrc( filePath );
    }
  }

  _.assert( _.arrayIs( filePath ) );

  return filePath;
}

//

function filePathArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.srcFilter )
  {
    return filter.filePathDstArrayBoolGet( filePath );
  }
  else
  {
    return filter.filePathSrcArrayBoolGet( filePath );
  }

}

//

function filePathDstNormalizedGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  filePath = filter.filePathDstArrayGet();

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.arrayIs( p ) )
    {
      return _.unrollFrom( p );
    }
    return p;
  });

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;

    if( p === null )
    {
      if( !!p )
      return filter.prefixPath || filter.basePathForFilePath( p ) || undefined;
      return;
    }

    if( _.boolLike( p ) )
    return;

    return p;
  });

  filePath = _.arrayAppendArrayOnce( [], filePath );

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath;
}

//

function filePathSrcNormalizedGet( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  filePath = filePath || filter.filePath;

  filePath = filter.filePathSrcArrayGet();

  _.assert( _.arrayIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.arrayIs( p ) )
    {
      debugger; xxx
      return _.unrollFrom( p );
    }
    return p;
  });

  filePath = _.filter( filePath, ( p ) =>
  {
    if( _.strIs( p ) )
    return p;

    if( p === null )
    {
      if( !!p )
      return filter.prefixPath || undefined;
      return;
    }

    if( _.boolLike( p ) )
    return;

    return p;
  });

  filePath = _.arrayAppendArrayOnce( [], filePath );

  if( filter.prefixPath || filter.postfixPath )
  filePath = path.s.join( filter.prefixPath || '.', filePath, filter.postfixPath || '.' );

  return filePath
}

//

function filePathNormalizedGet( filePath )
{
  let filter = this;
  if( filter.srcFilter )
  return filter.filePathDstNormalizedGet( filePath );
  else
  return filter.filePathSrcNormalizedGet( filePath );
}

//

function filePathCommon( filePath )
{
  let filter = this;
  if( filter.srcFilter )
  return filter.filePathDstCommon( filePath );
  else
  return filter.filePathSrcCommon( filePath );
}

//

function filePathDstCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.filePathDstNormalizedGet();

  return path.common.apply( path, filePath );
}

//

function filePathSrcCommon()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  let filePath = filter.filePathSrcNormalizedGet();

  return path.common.apply( path, filePath );
}

// --
// pair
// --

function pairFor( srcPath, dstPath )
{
  let srcFilter = this;
  let dstFilter = srcFilter.dstFilter;
  let fileProvider = srcFilter.hubFileProvider || srcFilter.effectiveFileProvider || srcFilter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( dstFilter instanceof Self );
  _.assert( dstFilter.srcFilter === srcFilter );

  dstFilter = dstFilter.clone();
  srcFilter = srcFilter.clone();
  srcFilter.pairWithDst( dstFilter );

  srcFilter.filePathSelect( srcPath, dstPath );

  return srcFilter;
}

//

function pairWithDst( dstFilter )
{
  let filter = this;

  _.assert( dstFilter instanceof Self );
  _.assert( filter instanceof Self );
  _.assert( filter.dstFilter === null || filter.dstFilter === dstFilter );
  _.assert( dstFilter.srcFilter === null || dstFilter.srcFilter === filter );

  filter.dstFilter = dstFilter;
  dstFilter.srcFilter = filter;

  return filter;
}

//

function pairRefineLight()
{
  let srcFilter = this;
  let dstFilter = srcFilter.dstFilter;
  let fileProvider = srcFilter.hubFileProvider || srcFilter.effectiveFileProvider || srcFilter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( dstFilter instanceof Self );
  _.assert( srcFilter instanceof Self );
  _.assert( dstFilter.srcFilter === srcFilter );
  _.assert( srcFilter.dstFilter === dstFilter );
  _.assert( arguments.length === 0 );

  srcFilter.pairWithDst( dstFilter );
  srcFilter.filePath = dstFilter.filePath = path.pathMapPairSrcAndDst( srcFilter.filePath, dstFilter.filePath );

  _.assert( srcFilter.filePath !== undefined );

}

//

function pairRefine()
{
  let srcFilter = this;
  let dstFilter = srcFilter.dstFilter;
  let fileProvider = srcFilter.hubFileProvider || srcFilter.effectiveFileProvider || srcFilter.defaultFileProvider;
  let path = fileProvider.path;
  let lackOfDst = false;

  _.assert( arguments.length === 0 );

  if( _.mapIs( srcFilter.filePath ) && _.entityIdentical( srcFilter.filePath, dstFilter.filePath ) )
  {
    dstFilter.filePath = srcFilter.filePath;
  }

  /* deduce src path if required */

  if( !srcFilter.filePath )
  {
    if( _.mapIs( dstFilter.filePath ) )
    srcFilter.filePath = dstFilter.filePath;
    else if( !srcFilter.filePath && ( srcFilter.prefixPath || srcFilter.postfixPath ) )
    srcFilter.filePath = path.join( srcFilter.prefixPath || '.', srcFilter.postfixPath || '.' );
    else
    {}
  }

  /* deduce dst path if required */

  let dstRequired = _.mapIs( srcFilter.filePath ) && _.any( srcFilter.filePath, ( e, k ) => e === null );
  if( dstRequired || _.arrayIs( srcFilter.filePath ) || _.strIs( srcFilter.filePath ) )
  {

    if( _.entityIdentical( dstFilter.basePath, { '.' : '.' } ) )
    dstFilter.basePath = '.';

    if( _.arrayIs( dstFilter.filePath ) && dstFilter.filePath.length === 1 )
    dstFilter.filePath = dstFilter.filePath[ 0 ];
    if( dstFilter.filePath === '.' )
    {
      _.assert( dstFilter.basePath === null || dstFilter.basePath === '.' || _.entityIdentical( dstFilter.basePath, { '.' : '.' } ) );
      dstFilter.filePath = null;
    }

    if( !dstFilter.filePath )
    {
      if( dstFilter.prefixPath || dstFilter.postfixPath )
      dstFilter.filePath = path.join( dstFilter.prefixPath || '.', dstFilter.postfixPath || '.' );
    }
    else
    {
      let dstPath1 = path.pathMapDstFromSrc( srcFilter.filePath ).filter( ( e, k ) => _.strIs( e ) );
      let dstPath2 = path.pathMapDstFromDst( dstFilter.filePath ).filter( ( e, k ) => _.strIs( e ) );
      _.assert( dstPath1.length === 0 || dstPath2.length === 0 || _.arraySetIdentical( dstPath1, dstPath2 ) );
    }

    srcFilter._formAssociations();
    if( srcFilter.filePath )
    srcFilter.prefixesApply();

    dstFilter._formAssociations();
    if( dstFilter.filePath )
    dstFilter.prefixesApply()

    // if( fileProvider instanceof _.FileProvider.Hub )
    // {
    //   debugger;
    //   srcFilter.globalsFromLocals();
    //   dstFilter.globalsFromLocals();
    // }

    if( dstFilter.filePath )
    {
      srcVerify();
      let dstPath = dstFilter.filePathDstNormalizedGet(); // xxx
      // let dstPath = dstFilter.filePathDstArrayGet();
      if( _.arrayIs( dstPath ) && dstPath.length === 1 )
      dstPath = dstPath[ 0 ];
      if( _.arrayIs( dstPath ) && dstPath.length === 0 )
      {
        dstPath = null;
        lackOfDst = true;
      }
      _.assert( _.strIs( dstPath ) || _.arrayIs( dstPath ) || _.boolLike( dstPath ) || dstPath === null );
      srcFilter.filePath = dstFilter.filePath = path.pathMapExtend( null, srcFilter.filePath, dstPath );
    }
    else
    {
      lackOfDst = true;
      if( _.strIs( srcFilter.filePath ) )
      srcFilter.filePath = { [ srcFilter.filePath ] : null }
    }

  }

  /* assign destination path */

  _.assert( srcFilter.filePath === null || _.mapIs( srcFilter.filePath ) );

  if( dstFilter.filePath && dstFilter.filePath !== srcFilter.filePath )
  {

    srcVerify();
    dstVerify();

    if( _.mapIs( dstFilter.filePath ) )
    {
    }
    else if( srcFilter.filePath && !_.mapIs( dstFilter.filePath ) )
    {
      dstFilter.filePath = _.arrayAs( dstFilter.filePath );
      _.assert( _.strsAreAll( dstFilter.filePath ) );
      dstVerify();
    }

  }

  if( dstFilter.filePath !== srcFilter.filePath && srcFilter.filePath )
  dstFilter.filePath = srcFilter.filePath;

  /* validate */

  let dstFilePath = srcFilter.filePathSrcArrayGet();

  _.assert( srcFilter.filePath === null || dstFilter.filePath === null || srcFilter.filePath === dstFilter.filePath )
  _.assert( srcFilter.filePath === null || _.all( srcFilter.filePath, ( e, k ) => path.is( k ) ) );
  _.assert( srcFilter.filePath === null || _.all( dstFilePath, ( e, k ) => _.boolLike( e ) || path.s.allAre( e ) ) );

  /* */

  function srcVerify()
  {
    if( dstFilter.filePath && srcFilter.filePath && Config.debug )
    {
      let srcPath1 = path.pathMapSrcFromSrc( srcFilter.filePath );
      let srcPath2 = path.pathMapSrcFromDst( dstFilter.filePath );
      _.assert( srcPath1.length === 0 || srcPath2.length === 0 || _.arraySetIdentical( srcPath1, srcPath2 ), () => 'Source paths are inconsistent ' + _.toStr( srcPath1 ) + ' ' + _.toStr( srcPath2 ) );
    }
  }

  /* */

  function dstVerify()
  {
    if( dstFilter.filePath && srcFilter.filePath && Config.debug )
    {
      // let dstPath1 = path.pathMapDstFromSrc( srcFilter.filePath ).filter( ( e ) => _.strIs( e ) );
      // let dstPath2 = path.pathMapDstFromDst( dstFilter.filePath ).filter( ( e ) => _.strIs( e ) );
      let dstPath1 = path.pathMapDstFromSrc( srcFilter.filePath );
      let dstPath2 = path.pathMapDstFromDst( dstFilter.filePath );
      _.arrayRemove( dstPath2, '.' );
      _.assert( dstPath1.length === 0 || dstPath2.length === 0 || _.arraySetIdentical( dstPath1, dstPath2 ), () => 'Destination paths are inconsistent ' + _.toStr( dstPath1 ) + ' ' + _.toStr( dstPath2 ) );
    }
  }

}

// --
// etc
// --

//

function providersNormalize()
{
  let filter = this;

  if( !filter.effectiveFileProvider )
  filter.effectiveFileProvider = filter.defaultFileProvider;
  if( !filter.hubFileProvider )
  filter.hubFileProvider = filter.effectiveFileProvider;
  if( filter.hubFileProvider.hub )
  filter.hubFileProvider = filter.hubFileProvider.hub;

}

//

function providerForPath( filePath )
{
  let filter = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.effectiveFileProvider )
  return filter.effectiveFileProvider;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.basePath

  _.assert( _.strIs( filePath ), 'Expects string' );

  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;

  filter.effectiveFileProvider = fileProvider.providerForPath( filePath );

  return filter.effectiveFileProvider;
}

// --
// iterative
// --

function allPaths( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let thePath;

  if( _.routineIs( o ) )
  o = { onEach : o }
  o = _.routineOptions( allPaths, o );
  _.assert( arguments.length === 1 );

  if( o.fixes )
  if( !each( filter.prefixPath, 'prefixPath' ) )
  return false;

  if( o.fixes )
  if( !each( filter.postfix, 'postfix' ) )
  return false;

  if( o.basePath )
  if( !each( filter.basePath, 'basePath' ) )
  return false;

  if( o.filePath )
  if( !each( filter.filePath, 'filePath' ) )
  return false;

  return true;

  /* - */

  function each( thePath, fieldName )
  {
    let it = Object.create( null );

    // it.options = o;
    // it.fieldName = fieldName;
    it.fieldName = fieldName;
    it.side = null;
    // it.field = thePath;
    it.value = thePath;

    let result = path.pathMapIterate({ iteration : it, filePath : thePath, onEach : o.onEach });

    filter[ fieldName ] = it.value;

    return it.result;

    // if( thePath === null || _.strIs( thePath ) )
    // {
    //   if( o.onEach( it ) === false )
    //   return false;
    //   if( filter[ fieldName ] !== it.value )
    //   filter[ fieldName ] = it.value;
    // }
    // else
    // {
    //   return path.pathMapIterate({ iteration : it, filePath : thePath, onEach : o.onEach });
    // }
    //
    // return true;

  }

}

allPaths.defaults =
{
  onEach : null,
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function isRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
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
    return;
    if( path.isRelative( it.value ) )
    return;
    it.value = false;
    // if( it.value === null )
    // return true;
    // if( path.isRelative( it.value ) )
    // return true;
    // return false;
  }

}

isRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelative( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
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
      () => 'Filter should have relative ' + it.fieldName + ', but has  ' + _.toStr( it.value )
    );
    // return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  // filePath : 1,
  filePath : 1,
}

//

function sureRelativeOrGlobal( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  o = _.routineOptions( sureRelative, arguments );

  let o2 = _.mapExtend( null, o );
  o2.onEach = onEach;

  let result = filter.allPaths( o2 );

  return result;

  /* - */

  function onEach( it )
  {
    _.sure
    (
      it.value === null || _.boolLike( it.value ) || path.s.allAreRelative( it.value ) || path.s.allAreGlobal( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has ' + _.toStr( it.value )
    );
    // return true;
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  filePath : 1,
}

//

function sureBasePath( basePath, filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  // debugger;

  basePath = basePath || filter.basePath;
  // filePath = filePath || filter.filePath; // yyy
  filePath = filter.filePathArrayNonBoolGet( filePath || filter.filePath );
  filePath = filePath.filter( ( e ) => _.strIs( e ) );

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( !_.arrayIs( basePath ) );

  if( !basePath || _.strIs( basePath ) )
  return;

  // filePath = filter.filePathArrayGet().filter( ( e ) => _.strIs( e ) );

  let diff = _.arraySetDiff( path.s.fromGlob( _.mapKeys( basePath ) ), path.s.fromGlob( filePath ) );
  _.sure( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );

  for( let g in basePath )
  {
    _.sure( !path.isGlob( basePath[ g ] ) );
  }

}

//

function assertBasePath( basePath, filePath )
{
  let filter = this;

  if( !Config.debug )
  return;

  _.assert( arguments.length === 0 || arguments.length === 2 );

  return filter.sureBasePath( basePath, filePath );
}

function filteringClear()
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

  if( filter.formedFilterMap )
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

function hasAnyPath()
{
  let filter = this;

  _.assert( arguments.length === 0 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) );
  _.assert( filter.filePath === null || _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );

  if( _.strIs( filter.basePath ) || _.mapIsPopulated( filter.basePath ) )
  return true;

  if( _.any( filter.prefixPath, ( e ) => _.strIs( e ) ) )
  return true;

  if( _.any( filter.postfixPath, ( e ) => _.strIs( e ) ) )
  return true;

  let filePath = filter.filePathArrayGet();

  if( _.any( filePath, ( e ) => _.strIs( e ) ) )
  return true;

  return false;
}

//

function hasData()
{
  let filter = this;

  if( filter.hasAnyPath() )
  return true;

  if( filter.hasFiltering() )
  return true;

  return false;
}

// --
// exporter
// --

function compactField( it )
{
  let filter = this;

  // if( it.path === "/src/filePath" )
  // debugger;

  if( it.dst === null )
  return;

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
    if( filter[ maskName ] !== null )
    {
      if( !filter[ maskName ].isEmpty )
      // result += '\n' + '  ' + maskName + ' : ' + !filter[ maskName ].isEmpty();
      // else
      result += '\n' + '  ' + maskName + ' : ' + true;
    }
  }

  let FieldNames =
  [
    'prefixPath', 'postfixPath',
    'filePath',
    'basePath',
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

// --
// applier
// --

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
  filter = filter.formedFilterMap ? filter.formedFilterMap[ f.stemPath ] : filter;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!filter, 'Cant resolve filter map for stem path', () => _.strQuote( f.stemPath ) );
  _.assert( !!f.formed, 'Record factor was not formed!' );

  // if( _.strHas( record.absolute, '.will' ) )
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
      record[ isActualSymbol ] = time >= filter.notOlder;
    }

    if( record.isActual === true )
    if( filter.notNewer !== null )
    {
      record[ isActualSymbol ] = time <= filter.notNewer;
    }

    if( record.isActual === true )
    if( filter.notOlderAge !== null )
    {
      record[ isActualSymbol ] = _.timeNow() - filter.notOlderAge - time <= 0;
    }

    if( record.isActual === true )
    if( filter.notNewerAge !== null )
    {
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

  filePath : null,
  basePath : null,
  prefixPath : null,
  postfixPath : null,

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
}

let Associates =
{
  effectiveFileProvider : null,
  defaultFileProvider : null,
  hubFileProvider : null,
}

let Restricts =
{

  formedFilePath : null,
  formedBasePath : null,
  formedFilterMap : null,

  // globFound : null,

  applyTo : null,
  formed : 0,

  srcFilter : null,
  dstFilter : null,

}

let Medials =
{

  srcFilter : null,
  dstFilter : null,

}

let Statics =
{
  TollerantFrom : TollerantFrom,
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
  inFilePath : 'inFilePath',
  stemPath : 'stemPath',
  src : 'src',
  dst : 'dst',
  globFound : 'globFound',

}

let Accessors =
{

  basePaths : { getter : basePathsGet, readOnly : 1 },

}

// --
// declare
// --

let Extend =
{

  TollerantFrom,
  init,
  copy,
  cloneBoth,

  // former

  form,
  _formAssociations,
  _formPre,
  _formPaths,
  _formMasks,
  _formFinal,

  // mutator

  maskExtensionApply,
  maskBeginsApply,
  maskEndsApply,
  filePathGenerate,
  filePathSelect,

  prefixesApply,
  prefixesRelative,
  pathLocalize,
  pathsNormalize,
  globalsFromLocals,

  // combiner

  And,
  and,
  _pathsJoin,
  pathsJoin,
  pathsJoinWithoutNull,
  pathsExtend2,
  pathsInherit,
  pathsExtend,

  // base path

  relativeFor,
  basePathForFilePath,
  basePathFor,
  basePathsGet,
  basePathFrom,
  basePathMapNormalize,
  basePathNormalize,
  basePathSimplify,
  basePathEach,

  // file path

  filePathGet,
  filePathSet,
  filePathNormalize,
  filePathPrependBasePath,
  filePathMultiplyRelatives,
  filePathAbsolutize,
  filePathGlobSimplify,
  filePathFromFixes,
  filePathSimplest,
  filePathNullizeMaybe,
  filePathHasGlob,

  filePathDstHasAllBools,
  filePathDstHasAnyBools,
  filePathOnlyBools,

  filePathDstArrayGet,
  filePathSrcArrayGet,
  filePathArrayGet,

  filePathDstArrayNonBoolGet,
  filePathSrcArrayNonBoolGet,
  filePathArrayNonBoolGet,

  filePathDstArrayBoolGet,
  filePathSrcArrayBoolGet,
  filePathArrayBoolGet,

  filePathDstNormalizedGet,
  filePathSrcNormalizedGet,
  filePathNormalizedGet,

  filePathCommon,
  filePathDstCommon,
  filePathSrcCommon,

  // pair

  pairFor,
  pairWithDst,
  pairRefineLight,
  pairRefine,

  // etc

  filteringClear,
  providersNormalize,
  providerForPath,

  // iterative

  allPaths,
  isRelative,
  sureRelative,
  sureRelativeOrGlobal,
  sureBasePath,
  assertBasePath,

  hasMask,
  hasFiltering,
  hasAnyPath,
  hasData,

  // exporter

  compactField,
  toStr,

  // applier

  _applyToRecordNothing,
  _applyToRecordMasks,
  _applyToRecordTime,
  _applyToRecordFull,

  // relations

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Medials,
  Statics,
  Forbids,
  Accessors,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
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
