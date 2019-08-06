( function _FileRecordFilter_s_() {

'use strict';


if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

}

//

/**
 * @class wFileRecordFilter
 * @memberof module:Tools/mid/Files
*/

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileRecordFilter( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'FileRecordFilter';

_.assert( !_.FileRecordFilter );
_.assert( !!_.regexpsEscape );

// --
//
// --

/**
 * @summary Creates filter instance ignoring unknown options.
 * @param {Object} o Options map.
 * @function TollerantFrom
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

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

  _.workpiece.initFields( filter );
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

  if( _.strIs( src ) || _.arrayIs( src ) )
  src = { prefixPath : src, filePath : '.' }

  // if( _.strIs( src ) || _.arrayIs( src ) )
  // src = { prefixPath : src, filePath : src }

  let result = _.Copyable.prototype.copy.call( filter, src );

  return result;
}

//

function pairedClone()
{
  let filter = this;

  let result = filter.clone();

  if( filter.src )
  {
    result.src = filter.src.clone();
    result.src.pairWithDst( result );
    result.src.pairRefineLight();
    return result;
  }

  if( filter.dst )
  {
    result.dst = filter.dst.clone();
    result.pairWithDst( result.dst );
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
  applicableToTrue = !path.mapDstFromSrc( filter.filePath ).filter( ( e ) => !_.boolLike( e ) ).length;
  filter.prefixesApply({ applicableToTrue : applicableToTrue });

  filter.pathsNormalize();

  // if( !filter.src )
  // if( _.mapIs( filter.filePath ) )
  // filter.filePath = filter.filePathGlobSimplify( filter.filePath, filter.basePath );

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

  /* */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 3 );

    if( filter.basePath )
    filter.assertBasePath();

    _.assert
    (
         ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
      || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
      || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
      || _.strIs( filter.basePath )
      , 'Cant deduce base path'
    );

    // _.assert( _.mapIs( filter.filePath ) || !filter.src, 'Destination filter should have file map' );
    _.assert( _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );
    // _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );

  }

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

  if( filter.formed < 4 )
  filter._formMasks();

  /*
    should use effectiveFileProvider because of option globbing of file provider
  */

  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  /* - */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 4 );
    _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );
    _.assert( _.mapIs( filter.formedBasePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( _.mapIs( filter.formedFilePath ) );
    _.assert( _.objectIs( filter.effectiveFileProvider ) );
    _.assert( filter.hubFileProvider === filter.effectiveFileProvider.hub || filter.hubFileProvider === filter.effectiveFileProvider );
    _.assert( filter.hubFileProvider instanceof _.FileProvider.Abstract );
    _.assert( filter.defaultFileProvider instanceof _.FileProvider.Abstract );

    let filePath = filter.filePathArrayGet( filter.formedFilePath ).filter( ( e ) => _.strIs( e ) && e );
    _.assert( path.s.noneAreGlob( filePath ) );
    _.assert( path.s.allAreAbsolute( filePath ) || path.s.allAreGlobal( filePath ), () => 'Expects absolute or global file path, but got\n' + _.toJson( filePath ) );

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

/**
 * @summary Applies file extension mask to the filter.
 * @function maskExtensionApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @summary Applies file begins mask to the filter.
 * @function maskBeginsApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @summary Applies file ends mask to the filter.
 * @function maskEndsApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @descriptionNeeded
 * @function filePathGenerate
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function filePathGenerate()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  let globFound = !filter.src;
  if( globFound )
  globFound = filter.filePathHasGlob();

  if( globFound )
  {

    _.assert( !filter.src );
    let filePath = _.mapExtend( null, filter.filePath );
    let basePath = _.mapExtend( null, filter.basePath );
    filter.filePathGlobSimplify( filePath, basePath );
    if( !_.entityIdentical( filePath, filter.filePath ) )
    {
      globFound = filter.filePathHasGlob( filePath );
    }

    if( globFound )
    {
      _.assert( !filter.src );
      _.assert( filter.formedFilterMap === null );
      filter.formedFilterMap = Object.create( null );

      let _processed = path.pathMapToRegexps( filter.filePath, filter.basePath  );

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
        subfilter.maskAll = _.RegexpObject.Or( filter.maskAll.clone(), { includeAll : regexps.actualAll, includeAny : regexps.actualAny, excludeAny : regexps.notActual } );
        subfilter.maskTerminal = filter.maskTerminal.clone();
        subfilter.maskDirectory = filter.maskDirectory.clone();
        subfilter.maskTransientAll = filter.maskTransientAll.clone();
        subfilter.maskTransientTerminal = _.RegexpObject.Or( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
        // subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone(); // zzz
        subfilter.maskTransientDirectory = _.RegexpObject.Or( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } );
        _.assert( subfilter.maskAll !== filter.maskAll );
      }
    }
    else
    {
      copy( filePath, basePath );
    }

  }
  else
  {
    copy( filter.filePath, filter.basePath );
  }

  function copy( filePath, basePath )
  {

    /* if base path is redundant then return empty map */
    if( _.mapIs( basePath ) )
    filter.formedBasePath = _.entityShallowClone( basePath );
    else
    filter.formedBasePath = Object.create( null );
    filter.formedFilePath = _.entityShallowClone( filePath );

  }

}

//

/**
 * @descriptionNeeded
 * @param {String} srcPath
 * @param {String} dstPath
 * @function filePathSelect
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function filePathSelect( srcPath, dstPath )
{
  let src = this;
  let dst = src.dst;
  let fileProvider = src.hubFileProvider || src.effectiveFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( srcPath ) );
  _.assert( _.strIs( dstPath ) );

  let filePath = path.mapExtend( null, srcPath, dstPath );

  if( dst )
  try
  {

    if( _.mapIs( dst.basePath ) )
    for( let dstPath2 in dst.basePath )
    {
      if( dstPath !== dstPath2 )
      {
        _.assert( _.strIs( dst.basePath[ dstPath2 ] ), () => 'No base path for ' + dstPath2 );
        delete dst.basePath[ dstPath2 ];
      }
    }

    dst.filePath = filePath;
    dst.form();
    dstPath = dst.filePathSimplest();
    _.assert( _.strIs( dstPath ) );
    filePath = dst.filePath;
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form destination filter\n', err );
  }

  try
  {

    if( _.mapIs( src.basePath ) )
    for( let srcPath2 in src.basePath )
    {
      if( filePath[ srcPath2 ] === undefined )
      {
        _.assert( _.strIs( src.basePath[ srcPath2 ] ), () => 'No base path for ' + srcPath2 );
        delete src.basePath[ srcPath2 ];
      }
    }

    src.filePath = filePath;
    _.assert( dst === null || src.filePath === dst.filePath );
    src.form();
    _.assert( dst === null || src.filePath === dst.filePath );
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form source filter\n', err );
  }

}

//

/**
 * @descriptionNeeded
 * @param {Object} o Options map.
 * @param {Boolean} o.applicableToTrue=false
 * @function prefixesApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;
  let adjustingFilePath = true;
  let paired = false;

  if( filter.prefixPath === null && filter.postfixPath === null )
  return filter;

  if( filter.src && filter.src.filePath === filter.filePath )
  paired = true;

  if( filter.dst && filter.dst.filePath === filter.filePath )
  paired = true;

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.strsAreAll( filter.postfixPath ) );
  _.assert( filter.postfixPath === null, 'not implemented' );

  if( !filter.filePath )
  {
    adjustingFilePath = false;
  }

  /* */

  _.assert( filter.postfixPath === null || !path.s.AllAreGlob( filter.postfixPath ) );

  if( adjustingFilePath )
  {
    let o2 = { basePath : 0, fixes : 0, filePath : 1, inplace : 1, onEach : filePathEach }
    filter.allPaths( o2 );
  }
  else
  {
    if( filter.src )
    filter.filePath = path.mapsPair( filter.prefixPath, null );
    else if( filter.dst )
    filter.filePath = path.mapsPair( null, filter.prefixPath );
    else
    filter.filePath = filter.prefixPath;
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

  if( paired && filter.src && filter.src.filePath !== filter.filePath )
  filter.src.filePath = filter.filePath;

  if( paired && filter.dst && filter.dst.filePath !== filter.filePath )
  filter.dst.filePath = filter.filePath;

  return filter;

  /* */

  function filePathEach( element, it )
  {
    _.assert( it.value === null || _.strIs( it.value ) || _.boolLike( it.value ) || _.arrayIs( it.value ) );

    if( filter.src )
    {
      if( it.side === 'src' ) // yyy
      return it.value;
    }
    else if( filter.dst )
    {
      if( it.side === 'dst' ) // yyy
      return it.value;
    }

    if( !o.applicableToTrue )
    if( it.side === 'src' && _.boolLike( it.dst ) ) // yyy
    {
      return it.value;
    }

    if( filter.prefixPath || filter.postfixPath )
    {
      if( it.value === null || it.value === '' || ( o.applicableToTrue && _.boolLike( it.value ) && it.value ) )
      // if( it.value === null || ( o.applicableToTrue && _.boolLike( it.value ) && it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
      }
      else if( !_.boolLike( it.value ) )
      {
        it.value = path.s.join( filter.prefixPath || '.', it.value, filter.postfixPath || '.' );
      }
    }

    if( it.side === 'dst' && _.strIs( it.value ) ) // yyy
    it.value = path.fromGlob( it.value );

    return it.value;
  }

  /* */

  function basePathEach( filePath, basePath )
  {
    if( !filter.prefixPath && !filter.postfixPath )
    return;

    let prefixPath = filter.prefixPath;
    if( prefixPath )
    prefixPath = path.s.fromGlob( prefixPath );

    let postfixPath = filter.postfixPath;
    if( postfixPath )
    postfixPath = path.s.fromGlob( postfixPath );

    let r = Object.create( null );

    basePath = path.s.join( prefixPath || '.', basePath, postfixPath || '.' );

    // if( !_.boolLike( filePath ) )
    // filePath = path.s.join( prefixPath || '.', filePath, postfixPath || '.' );

    if( !_.boolLike( filePath ) )
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

/**
 * @descriptionNeeded
 * @param {String} prefixPath
 * @function prefixesRelative
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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
    prefixPath = filter.prefixPathFromFilePath({ usingBools : 1 });
  }

  if( prefixPath )
  {

    if( filter.basePath )
    filter.basePath = path.filter( filter.basePath, relative_functor() );

    if( filter.filePath )
    {
      if( filter.src )
      filter.filePath = path.filterInplace( filter.filePath, relative_functor( 'dst' ) );
      else if( filter.dst )
      filter.filePath = path.filterInplace( filter.filePath, relative_functor( 'src' ) );
      else
      filter.filePath = path.filterInplace( filter.filePath, relative_functor() );
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
        // if( !_.strIs( filePath ) )
        if( !_.strIs( filePath ) || filePath === '' )
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

function prefixPathFromFilePath( o )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.routineOptions( prefixPathFromFilePath, arguments );

  let result = o.filePath || filter.filePath;

  if( result === null )
  return null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !!result );

  if( o.usingBools )
  result = filter.filePathArrayGet( result );
  else
  result = filter.filePathArrayNonBoolGet( result, 1 );

  if( result )
  {
    result = result.filter( ( filePath ) => _.strIs( filePath ) && filePath );
    if( path.s.anyAreAbsolute( result ) )
    result = result.filter( ( filePath ) => path.isAbsolute( filePath ) );
  }

  if( result && result.length )
  {
    result = path.fromGlob( path.detrail( path.common( result ) ) );
  }
  else
  {
    result = null;
  }

  return result;
}

prefixPathFromFilePath.defaults =
{
  filePath : null,
  usingBools : 1,
}

//

/**
 * @summary Converts global path into local.
 * @param {String} filePath Input file path.
 * @function prefixesRelative
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function pathLocalize( filePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( _.strIs( filePath ) );

  filePath = path.canonize( filePath );

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

  _.assert( !path.isTrailed( filePath ) );

  let provider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let result = provider.path.localFromGlobal( filePath );
  return result;
}

//

/**
 * @summary Normalizes path properties of the filter.
 * @function pathsNormalize
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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
  // _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );
  // _.assert( _.mapIs( filter.filePath ) || !filter.src, 'Destination filter should have file map' );

  /* */

  filter.filePath = filter.filePathNormalize( filter.filePath );
  _.assert( _.mapIs( filter.filePath ) );

  filter.basePath = filter.basePathNormalize( filter.filePath, filter.basePath );
  _.assert( _.mapIs( filter.basePath ) || filter.basePath === null || filter.filePathArrayNonBoolGet( filter.filePath, 1 ).filter( ( e ) => e !== null ).length === 0 );

  filter.filePathAbsolutize();
  filter.providersNormalize();

  // /* */
  //
  // if( !Config.debug )
  // return;
  //
  // if( filter.basePath )
  // filter.assertBasePath();
  //
  // _.assert
  // (
  //      ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
  //   || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
  //   || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
  //   || _.strIs( filter.basePath )
  //   , 'Cant deduce base path'
  // );

}

//

/**
 * @summary Converts local paths of filter into global.
 * @function globalsFromLocals
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @descriptionNeeded
 * @function And
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

function And()
{
  _.assert( !_.instanceIs( this ) );

  let dst = null;

  if( arguments.length === 1 )
  return this.Self( arguments[ 0 ] );

  for( let a = 0 ; a < arguments.length ; a++ )
  {
    let src = arguments[ a ];

    if( dst )
    dst = this.Self( dst );
    if( dst )
    dst.and( src );
    else
    dst = this.Self( src );

  }

  return dst;
}

//

/**
 * @descriptionNeeded
 * @function and
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.effectiveFileProvider || !src.effectiveFileProvider || filter.effectiveFileProvider === src.effectiveFileProvider );
  _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );

  if( src === filter )
  return filter;

  /* */

  if( src.effectiveFileProvider )
  filter.effectiveFileProvider = src.effectiveFileProvider

  if( src.hubFileProvider )
  filter.hubFileProvider = src.hubFileProvider

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
  // _.assert( o.src.filePath === null || o.src.filePath === undefined || o.src.filePath === '.' || _.strIs( o.src.filePath ) );

  let fileProvider = filter.hubFileProvider || filter.defaultFileProvider || filter.effectiveFileProvider || o.src.hubFileProvider || o.src.defaultFileProvider || o.src.effectiveFileProvider;
  let path = fileProvider.path;

  if( o.src.hubFileProvider )
  filter.hubFileProvider = o.src.hubFileProvider;

  /* */

  for( let n in o.joiningAsPathMap )
  if( o.src[ n ] !== undefined && o.src[ n ] !== null )
  {
    if( filter[ n ] === null )
    {
      filter[ n ] = o.src[ n ];
      continue;
    }
    // _.assert( !!filter.dst || !!filter.src, 'Filters should be paired first!' );
    if( filter.src )
    {
      debugger;
      if( !_.mapIs( filter[ n ] ) )
      filter[ n ] = path.mapExtend( null, null, filter[ n ] );
      path.mapExtend( filter[ n ], o.src[ n ], null );
    }
    else
    {
      debugger;
      path.mapExtend( filter[ n ], o.src[ n ], null );
    }
    // _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
    // _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
    // filter[ n ] = path.join( filter[ n ], o.src[ n ] );
  }

  /* */

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

  joiningAsPathMap :
  {
    filePath : null,
  },

  joiningWithoutNullMap :
  {
    // filePath : null, // yyy
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
    joiningAsPathMap :
    {
      filePath : null,
    },
    joiningWithoutNullMap :
    {
      // filePath : null,
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
    joiningAsPathMap :
    {
      filePath : null,
    },
    joiningWithoutNullMap :
    {
      // filePath : null,
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

function pathsExtend( src )
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
    src.basePath = src.basePathFrom( src.filePath || {}, src.basePath );
    _.assert( src.basePath === null || _.mapIs( src.basePath ) || _.strIs( src.basePath ) ); // yyy
    // _.assert( src.basePath === null || _.mapIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.filePath || {}, filter.basePath );
    _.assert( filter.basePath === null || _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) ); // yyy
    // _.assert( filter.basePath === null || _.mapIs( filter.basePath ) );

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

    let isDst = !!filter.src || !!src.src;
    if( ( _.mapIs( filter.filePath ) && _.mapIs( src.filePath ) ) || !isDst )
    {
      filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
    }
    else if( !_.mapIs( src.filePath ) )
    {
      debugger;
      _.assert( 0, 'not tested' );
      filter.filePath = path.mapExtend( filter.filePath, filter.filePath, src.filePath );
    }
    else if( !_.mapIs( filter.filePath ) )
    {
      filter.filePath = path.mapExtend( null, src.filePath, filter.filePath );
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

  if( filter.src && filter.src.filePath === filter.filePath )
  paired = true;

  if( filter.dst && filter.dst.filePath === filter.filePath )
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

  /* */

  let dstSrcNonBoolPaths = filter.filePathSrcArrayNonBoolGet( filter.filePath, 0 );
  let srcOnlyBoolPathMap = src.filePathMapOnlyBools( src.filePath );
  let srcSrcNonBoolPaths = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
  let srcDstNonBoolPaths = src.filePathDstArrayNonBoolGet( src.filePath, 0 ).filter( ( p ) => !path.isEmpty( p ) );

  let dstFilePath = filter.filePath;
  let srcFilePath = src.filePath;
  if( dstSrcNonBoolPaths.length === 0 && srcSrcNonBoolPaths.length === 0 )
  {
    if( dstFilePath )
    dstFilePath = path.filter( dstFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
    if( srcFilePath )
    srcFilePath = path.filter( srcFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
  }

  let dstSrcIsDot = false;
  if( dstSrcNonBoolPaths.length === 1 )
  if( dstSrcNonBoolPaths[ 0 ] === '.' || dstSrcNonBoolPaths[ 0 ] === '' ) // yyy
  {
    dstSrcIsDot = true;
    dstSrcNonBoolPaths = [];
  }

  /* */

  if( filter.basePath === null && _.mapIs( src.basePath ) )
  {

    for( let p = 0 ; p < dstSrcNonBoolPaths.length ; p++ )
    {
      let filePath = dstSrcNonBoolPaths[ p ];
      if( src.basePath[ p ] === undefined )
      {
        filter.basePath = filter.basePath || Object.create( null );
        filter.basePath[ filePath ] = filePath;
      }
    }

  }

  if( src.basePath && filter.basePath )
  {

    if( _.strIs( src.basePath ) )
    src.basePath = src.basePathFrom( src.filePath || {}, src.basePath );
    _.assert( _.mapIs( src.basePath ) || _.strIs( src.basePath ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathFrom( filter.filePath || {}, filter.basePath );
    _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) );

  }

  /* */

  if( filter.filePath && src.filePath )
  {

    let dstSrcPath = filter.filePathSrcArrayGet();
    let dstDstPath = filter.filePathDstArrayGet();

    // debugger;

    if( dstSrcNonBoolPaths.length === 0 && !dstSrcIsDot )
    {
      if( filter.src && !_.mapIs( filter.src ) )
      filter.filePath = path.mapExtend( null, filter.filePath, null );

      if( src.src && !_.mapIs( src.src ) )
      src.filePath = path.mapExtend( null, src.filePath, null );

      filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
    }
    else if( path.isEmpty( dstSrcPath ) )
    {
      // let dstDstPath = filter.filePathDstArrayGet();
      if( !dstDstPath.length )
      dstDstPath = null;
      filter.filePath = path.mapExtend( null, src.filePathSrcArrayGet(), dstDstPath );
    }
    else
    {
      if( Object.keys( srcOnlyBoolPathMap ).length )
      {
        // if( filter.src && !_.mapIs( filter.src ) )
        // filter.filePath = path.mapExtend( null, filter.filePath, null );
        filter.filePath = path.mapExtend( filter.filePath, srcOnlyBoolPathMap, null );
      }
      if( srcDstNonBoolPaths.length )
      {
        // debugger;
        filter.filePath = path.mapExtend( filter.filePath, null, srcDstNonBoolPaths );
      }
    }

    // if( dstSrcNonBoolPaths.length === 0 && !dstSrcIsDot )
    // {
    //   if( filter.src && !_.mapIs( filter.src ) )
    //   filter.filePath = path.mapExtend( null, filter.filePath, null );
    //
    //   if( src.src && !_.mapIs( src.src ) )
    //   src.filePath = path.mapExtend( null, src.filePath, null );
    //
    //   filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
    // }
    // else if( Object.keys( srcOnlyBoolPathMap ).length )
    // {
    //   if( filter.src && !_.mapIs( filter.src ) )
    //   filter.filePath = path.mapExtend( null, filter.filePath, null );
    //   filter.filePath = path.mapExtend( filter.filePath, srcOnlyBoolPathMap, null );
    // }
    // else
    // {
    //   let dstSrcPath = filter.filePathSrcArrayGet();
    //   // if( dstSrcPath.length === 1 && dstSrcPath[ 0 ] === '.' ) // yyy
    //   if( path.isEmpty( dstSrcPath ) )
    //   {
    //     let dstDstPath = filter.filePathDstArrayGet();
    //     if( !dstDstPath.length )
    //     dstDstPath = null;
    //     filter.filePath = path.mapExtend( null, src.filePathSrcArrayGet(), dstDstPath );
    //   }
    // }

  }
  else
  {
    filter.filePath = filter.filePath || src.filePath;
  }

  /* */

  if( src.basePath && filter.basePath )
  {

    if( _.mapIs( filter.basePath ) )
    for( let filePath in filter.basePath )
    {
      if( _.boolLike( srcFilePath[ filePath ] ) && !srcFilePath[ filePath ] )
      delete filter.basePath[ filePath ];
    }

    _.assert( _.mapIs( filter.filePath ) || filter.filePath === null );
    if( _.mapIs( src.basePath ) )
    for( let filePath in src.basePath )
    {
      let basePath = src.basePath[ filePath ];
      if( filter.filePath[ filePath ] !== undefined )
      if( !filter.basePath[ filePath ] )
      filter.basePath[ filePath ] = basePath;
    }

  }
  else
  {
    filter.basePath = filter.basePath || src.basePath;
  }

  /* */

  if( paired && filter.src && filter.src.filePath !== filter.filePath )
  filter.src.filePath = filter.filePath;

  if( paired && filter.dst && filter.dst.filePath !== filter.filePath )
  filter.dst.filePath = filter.filePath;

  return filter;
}

// //
//
// function pathsExtend( src )
// {
//   let filter = this;
//
//   if( arguments.length > 1 )
//   {
//     for( let a = 0 ; a < arguments.length ; a++ )
//     filter.pathsExtend( arguments[ a ] );
//     return filter;
//   }
//
//   if( Config.debug )
//   if( src && !( src instanceof filter.Self ) )
//   _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );
//
//   _.assert( _.instanceIs( filter ) );
//   _.assert( !filter.formed || filter.formed <= 1 );
//   _.assert( !src.formed || src.formed <= 1 );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( filter.formedFilterMap === null );
//   _.assert( filter.applyTo === null );
//   _.assert( filter.filePath === null );
//   _.assert( !filter.hubFileProvider || !src.hubFileProvider || filter.hubFileProvider === src.hubFileProvider );
//   _.assert( src !== filter );
//   _.assert( src.filePath === null || src.filePath === undefined || filter.filePath === null );
//
//   let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider || src.effectiveFileProvider || src.hubFileProvider || src.defaultFileProvider;
//   let path = fileProvider.path;
//
//   let replacing =
//   {
//
//     hubFileProvider : null,
//     basePath : null,
//     filePath : null,
//     prefixPath : null,
//     postfixPath : null,
//
//   }
//
//   /* */
//
//   for( let s in replacing )
//   {
//     if( src[ s ] === null || src[ s ] === undefined )
//     continue;
//     filter[ s ] = src[ s ];
//   }
//
//   return filter;
// }

// --
// base path
// --

/**
 * @summary Returns relative path for provided path `filePath`.
 * @function relativeFor
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @summary Returns base path for provided path `filePath`.
 * @param {String|Boolean} filePath Source file path.
 * @function basePathForFilePath
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

/**
 * @summary Returns base path for provided path `filePath`.
 * @param {String|Boolean} filePath Source file path.
 * @function basePathFor
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

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

  if( result )
  return result;

  let basePath = _.mapExtend( null, filter.basePath );
  for( let f in basePath )
  {
    let b = basePath[ f ];
    delete basePath[ f ];
    basePath[ path.fromGlob( f ) ] = b;
  }

  result = basePath[ filePath ];

  if( !result && !_.strBegins( filePath, '..' ) && !_.strBegins( filePath, '/..' ) )
  {

    let filePath2 = path.join( filePath, '..' );
    while( filePath2 !== '..' && filePath2 !== '/..' )
    {
      result = basePath[ filePath2 ];
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
  return _.longUnduplicate( null, _.mapVals( filter.basePath ) )
  else if( _.strIs( filter.basePath ) )
  return [ filter.basePath ];
  else
  return [];
}

//

function basePathFrom( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( basePath === undefined )
  basePath = filter.basePath
  if( filePath === undefined )
  filePath = filter.prefixPath || filter.filePath;

  _.assert( basePath === null || _.strIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 2 );

  if( basePath )
  basePath = filter.pathLocalize( basePath );
  filePath = filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => _.strIs( e ) && e );
  // filePath = filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => e !== null ); // yyy

  let basePath2 = Object.create( null );

  if( basePath )
  {
    for( let s = 0 ; s < filePath.length ; s++ )
    {
      let thisFilePath = filePath[ s ];
      if( path.isRelative( basePath ) )
      basePath2[ thisFilePath ] = path.detrail( path.join( path.fromGlob( thisFilePath ), basePath ) );
      else
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

  for( let filePath in basePathMap )
  {
    let basePath = basePathMap[ filePath ];

    _.assert( _.strIs( basePath ) );
    _.assert( _.strIs( filePath ) );
    _.assert( !path.isGlob( basePath ) );

    filePath = filter.pathLocalize( filePath );
    basePath = filter.pathLocalize( basePath );
    basePathMap2[ filePath ] = basePath;
  }

  return basePathMap2;
}

//

function basePathNormalize( filePath, basePath )
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
    basePath = filter.basePathFrom( filePath, basePath );
  }
  else if( _.mapIs( basePath ) )
  {
    basePath = filter.basePathMapNormalize( basePath );
  }
  else _.assert( 0 );

  _.assert( _.mapIs( basePath ) || basePath === null || filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => e !== null ).length === 0 );
  // _.assert( _.mapIs( basePath ) || basePath === null || _.mapKeys( filePath ).length === 0 );

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

function basePathDotUnwrap()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) && filter.basePath !== '.' )
  return;

  if( _.mapIs( filter.basePath ) && !_.mapsAreIdentical( filter.basePath, { '.' : '.' } ) )
  return;

  debugger;
  let filePath = filter.filePathArrayNonBoolGet(); // xxx : boolFallingBack?

  let basePath = _.mapIs( filter.basePath ) ? filter.basePath : Object.create( null );
  delete basePath[ '.' ];
  filter.basePath = basePath;

  filePath.forEach( ( fp ) => basePath[ fp ] = fp );

}

//

function basePathEach( onEach )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( arguments.length === 1 );

  /*
  don't use file path neither prefix path
  */

  let basePath = filter.basePath;

  // if( !_.mapIs( basePath ) )
  // {
  //   // basePath = filter.basePathFrom( filter.filePath, basePath ); // yyy
  //   basePath = filter.basePathFrom( filter.prefixPath || filter.filePath, basePath );
  // }

  if( _.strIs( basePath ) )
  {
    let r = onEach( null, basePath );
    _.assert( r === undefined || _.strIs( r ) || _.mapIs( r ) );
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

//

function basePathUse( basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  filter = fileProvider.recordFilter( filter );

  if( filter.basePath || basePath )
  filter.basePath = path.join( basePath || '.', filter.basePath || '.' );

  if( basePath )
  filter.prefixPath = path.s.join( basePath, filter.prefixPath || '.' )

  filter.prefixesApply();

  if( !filter.basePath && path.s.anyAreGlob( filter.filePath ) )
  filter.basePath = filter.basePathFrom();
  filter.basePath = filter.basePath || path.current();
  filter.prefixPath = path.current();
  filter.prefixesApply();

  basePath = path.resolve( basePath || filter.basePaths[ 0 ] );

  return basePath;
}

// --
// file path
// --

function filePathCopy( o )
{

  _.assertRoutineOptions( filePathCopy, arguments );

  /* get */

  if( o.value === null )
  if( _.instanceIs( o.srcInstance ) )
  {
    o.value = o.srcInstance[ filePathSymbol ];
  }
  else if( o.srcInstance )
  {
    debugger;
    o.value = o.srcInstance.filePath;
  }

  if( o.srcInstance && o.dstInstance )
  {
    o.value = _.entityShallowClone( o.value );
  }

  /* set */

  if( _.instanceIs( o.dstInstance ) )
  {
    _.assert( o.value === null || _.strIs( o.value ) || _.arrayIs( o.value ) || _.mapIs( o.value ) );

    if( o.dstInstance.src )
    {
      let fileProvider = o.dstInstance.hubFileProvider || o.dstInstance.effectiveFileProvider || o.dstInstance.defaultFileProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( o.value, null );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.value !== o.dstInstance.src.filePath )
      o.dstInstance.src[ filePathSymbol ] = o.value;
    }
    else if( o.dstInstance.dst )
    {
      let fileProvider = o.dstInstance.hubFileProvider || o.dstInstance.effectiveFileProvider || o.dstInstance.defaultFileProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( null, o.value );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.value !== o.dstInstance.dst.filePath )
      o.dstInstance.dst[ filePathSymbol ] = o.value;
    }

    o.dstInstance[ filePathSymbol ] = o.value;
  }
  else if( o.dstInstance )
  {
    debugger;
    o.dstInstance.filePath = o.value;
  }

  /* */

  return o;
}

filePathCopy.defaults =
{
  dstInstance : null,
  srcInstance : null,
  instanceKey : null,
  srcContainer : null,
  dstContainer : null,
  containerKey : null,
  value : null,
}

//

function filePathGet()
{
  let filter = this;
  return filter[ filePathSymbol ];
}

//

function basePathSet( src )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;

  if( 0 )
  if( Config.debug )
  if( src && fileProvider )
  {
    let path = fileProvider.path;
    path.filter( src, ( basePath, it ) =>
    {
      if( it.side === 'src' )
      return;
      _.assert( !path.isGlob( basePath ), () => 'Base path should be non-glob, but ' + _.strQuote( basePath ) + ' is glob' );
    });
  }

  if( _.mapIs( src ) )
  src = _.mapExtend( null, src );

  return filter[ basePathSymbol ] = src;
}

//

function filePathSet( src )
{
  let filter = this;

  _.assert( src === null || _.strIs( src ) || _.arrayIs( src ) || _.mapIs( src ) );

  if( filter.src )
  {
    let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
    let path = fileProvider.path;
    if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
    src = path.mapsPair( src, null );
    _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
    if( src !== filter.src.filePath )
    filter.src[ filePathSymbol ] = src;
  }
  else if( filter.dst )
  {
    let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
    let path = fileProvider.path;
    if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
    src = path.mapsPair( null, src );
    _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
    if( src !== filter.dst.filePath )
    filter.dst[ filePathSymbol ] = src;
  }

  filter[ filePathSymbol ] = src;

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
  filePath = path.mapExtend( null, filePath );

  if( filter.src )
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

  if( filter.src )
  {
    debugger;

    for( let srcPath in filePath )
    {

      let dstPath = filePath[ srcPath ];
      let b = basePath[ dstPath ];

      if( path.isAbsolute( dstPath ) )
      continue;
      if( !b )
      continue;
      if( !path.isAbsolute( b ) )
      continue;

      _.assert( path.isAbsolute( b ) );

      let joinedPath = path.join( b, dstPath );
      if( joinedPath !== dstPath )
      {
        delete basePath[ dstPath ];
        basePath[ joinedPath ] = b;
        delete filePath[ srcPath ];
        path.mapExtend( filePath, srcPath, joinedPath );
      }

    }

    debugger;
  }
  // {
  //
  //   debugger;
  //   for( let srcPath in filePath )
  //   {
  //
  //     let dstPath = filePath[ srcPath ];
  //     let b = basePath[ dstPath ];
  //     if( !_.strIs( dstPath ) || path.isAbsolute( dstPath ) )
  //     continue;
  //
  //     _.assert( path.isAbsolute( b ) );
  //
  //     let joinedPath = path.join( b, dstPath );
  //     if( joinedPath !== dstPath )
  //     {
  //       delete basePath[ dstPath ];
  //       basePath[ joinedPath ] = b;
  //       filePath[ srcPath ] = joinedPath;
  //     }
  //
  //   }
  //   debugger;
  //
  // }
  else
  {

    for( let srcPath in filePath )
    {

      let dstPath = filePath[ srcPath ];
      let b = basePath[ srcPath ];

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
        path.mapExtend( filePath, joinedPath, dstPath );
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
  // _.assert( !filter.src );

  // if( !filter.src )
  // debugger;

  let relativePath = _.mapExtend( null, filePath );

  for( let r in relativePath )
  if( path.isRelative( r ) )
  {
    delete basePath[ r ];
    delete filePath[ r ];
  }
  else
  {
    delete relativePath[ r ];
  }

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
      if( !_.boolLike( dstPath ) )
      basePath[ srcPath ] = currentBasePath;
    }
  }

}

//

function filePathAbsolutize()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  if( _.mapKeys( filter.filePath ).length === 0 )
  return;

  // _.assert( _.mapIs( filter.basePath ) );
  _.assert( _.mapIs( filter.filePath ) );

  let filePath = filter.filePathArrayGet().filter( ( e ) => _.strIs( e ) && e );

  if( path.s.anyAreRelative( filePath ) )
  {
    if( path.s.anyAreAbsolute( filePath ) )
    filter.filePathMultiplyRelatives( filter.filePath, filter.basePath );
    else
    filter.filePathPrependBasePath( filter.filePath, filter.basePath );
  }

}

//

/*
Easy optimization. No need to enable slower glob searching if glob is "**".
Result of such glob is equivalent to result of recursive searching.
*/

// function filePathGlobSimplify( basePath, filePath )
function filePathGlobSimplify( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filePath || filter.filePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( !filter.src, 'Not applicable to destination filter, only to source filter' );

  let dst = filter.filePathDstArrayGet();

  if( _.any( dst, ( e ) => _.boolIs( e ) ) )
  return filePath

  for( let src in filePath )
  {
    if( _.strEnds( src, '/**' ) || src === '**' )
    simplify( src, '**' )
  }

  return filePath;

  /* */

  function simplify( src, what )
  {
    let src2 = path.canonize( _.strRemoveEnd( src, what ) );
    if( !path.isGlob( src2 ) )
    {
      _.assert( filePath[ src2 ] === undefined )
      filePath[ src2 ] = filePath[ src ];
      delete filePath[ src ];

      if( _.mapIs( basePath ) )
      {
        _.assert( basePath[ src2 ] === undefined || basePath[ src2 ] === basePath[ src ], () => 'Base path for file path ' + _.strQuote( src2 ) + ' is already defined and has value ' + _.strQuote( basePath[ src2 ] ) );
        _.assert( basePath[ src ] !== undefined, () => 'No base path for file path ' + _.strQuote( src ) );
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
    filter.filePath = path.s.join( filter.prefixPath || '.', filter.postfixPath || '.' );
    _.assert( path.s.allAreAbsolute( filter.filePath ), 'Can deduce file path' );
  }

  return filter.filePath;
}

//

function filePathSimplest( filePath )
{
  let filter = this;

  filePath = filePath || filter.filePathArrayNonBoolGet();
  // filePath = filePath || filter.filePathNormalizedGet();

  _.assert( !_.mapIs( filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( _.arrayIs( filePath ) && filePath.length === 1 )
  return filePath[ 0 ];

  if( _.arrayIs( filePath ) && filePath.length === 0 )
  return null;

  return filePath;
}

//
// //
//
// function filePathSimplest()
// {
//   let filter = this;
//
//   let filePath = filter.filePathNormalizedGet();
//
//   _.assert( !_.mapIs( filePath ) );
//
//   if( _.arrayIs( filePath ) && filePath.length === 1 )
//   return filePath[ 0 ];
//
//   if( _.arrayIs( filePath ) && filePath.length === 0 )
//   return null;
//
//   return filePath;
// }

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

  return path.filterInplace( filePath, ( e ) => _.boolLike( e ) && e ? null : e );
}

//

function filePathHasGlob( filePath )
{
  let filter = this;
  let fileProvider = filter.effectiveFileProvider || filter.hubFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  /*
    should use effectiveFileProvider because of option globbing of file provider
  */

  filePath = filePath || filter.filePath;

  let globFound = true;
  if( _.none( path.s.areGlob( filePath ) ) )
  if( !filter.filePathDstArrayGet( filePath ).filter( ( e ) => _.boolLike( e ) ).length )
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

function filePathMapOnlyBools( filePath )
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

  if( filter.src )
  {
    return path.mapDstFromDst( filePath );
  }
  else
  {
    return path.mapDstFromSrc( filePath );
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

  if( filter.src )
  {
    return path.mapSrcFromDst( filePath );
  }
  else
  {
    return path.mapSrcFromSrc( filePath );
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

  if( filter.src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapSrcFromSrc( filePath );
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

  // if( boolFallingBack === undefined )
  // boolFallingBack = true;

  if( boolFallingBack === undefined )
  boolFallingBack = false;

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter.src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapDstFromSrc( filePath );
  }

  let filePath2 = filePath.filter( ( e ) => !_.boolLike( e ) );
  if( filePath2.length || !boolFallingBack )
  {
    filePath = filePath2;
  }
  else
  {
    filePath = _.filter( filePath, ( e ) =>
    {
      if( !_.boolLike( e ) )
      return e;
      if( e )
      return null;
      return undefined;
    });
  }

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

  // if( boolFallingBack === undefined )
  // boolFallingBack = true;

  if( boolFallingBack === undefined )
  boolFallingBack = false;

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
    if( filter.src )
    {
      filePath = path.mapSrcFromDst( filePath );
    }
    else
    {
      filePath = path.mapSrcFromSrc( filePath );
    }
  }

  _.assert( _.arrayIs( filePath ) );
  _.longUnduplicate( filePath );

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

  if( filter.src )
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

  if( filter.src )
  {
    filePath = path.mapDstFromDst( filePath );
  }
  else
  {
    filePath = path.mapDstFromSrc( filePath );
  }

  let filePath2 = _.filter( filePath, ( e ) => _.boolLike( e ) ? !!e : undefined );
  filePath = _.longUnduplicate( null, filePath2 );

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
    let r = [];

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
    filePath = [];
    // if( filter.src )
    // {
    //   filePath = path.mapSrcFromDst( filePath );
    // }
    // else
    // {
    //   filePath = path.mapSrcFromSrc( filePath );
    // }
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

  if( filter.src )
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
      debugger;
      _.assert( 0, 'not tested' );
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
  if( filter.src )
  return filter.filePathDstNormalizedGet( filePath );
  else
  return filter.filePathSrcNormalizedGet( filePath );
}

//

function filePathCommon( filePath )
{
  let filter = this;
  if( filter.src )
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

function pairedFilterGet()
{
  let filter = this;
  _.assert( arguments.length === 0 );
  if( filter.src )
  return filter.src
  else
  return filter.dst;
}

//

function pairWithDst( dst )
{
  let filter = this;

  _.assert( dst instanceof Self );
  _.assert( filter instanceof Self );
  _.assert( filter.dst === null || filter.dst === dst );
  _.assert( dst.src === null || dst.src === filter );

  filter.dst = dst;
  dst.src = filter;

  return filter;
}

//

function pairRefineLight()
{
  let src = this;
  let dst = src.dst;
  let fileProvider = src.hubFileProvider || src.effectiveFileProvider || src.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( dst instanceof Self );
  _.assert( src instanceof Self );
  _.assert( dst.src === src );
  _.assert( src.dst === dst );
  _.assert( arguments.length === 0 );

  src.filePath = dst.filePath = path.mapsPair( dst.filePath, src.filePath );

  _.assert( src.filePath !== undefined );
  _.assert( _.mapIs( src.filePath ) || src.filePath === null );
  _.assert( src.filePath === dst.filePath );

}

//

function isPaired( aFilter )
{
  let src = this;
  let dst = src.dst;

  aFilter = aFilter || src.dst || src.src;

  if( src.src )
  {
    dst = src;
    src = src.src;
    if( aFilter !== src )
    return false;
  }
  else
  {
    if( aFilter !== dst )
    return false;
  }

  _.assert( !!dst );
  _.assert( src.dst === dst );
  _.assert( dst.src === src );
  _.assert( src.src === null );
  _.assert( dst.dst === null );

  return true;
}

// --
// etc
// --

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
    // let it = Object.create( null );
    // it.fieldName = fieldName;
    // it.side = null;
    // it.value = thePath;
    // let result = path.pathMapIterate({ iteration : it, filePath : thePath, onEach : o.onEach });

    // debugger;
    let result = o.inplace ? path.filterInplace( thePath, o.onEach ) : path.filter( thePath, o.onEach );
    // debugger;

    // filter[ fieldName ] = it.value;
    if( o.inplace )
    filter[ fieldName ] = result;

    // return it.result;
    return result;
  }

}

allPaths.defaults =
{
  onEach : null,
  fixes : 1,
  basePath : 1,
  filePath : 1,
  inplace : 1,
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
  o2.inplace = 0;

  return filter.allPaths( o2 );

  /* - */

  function onEach( element, it )
  {
    debugger;
    _.assert( 0, 'not tested' );
    if( it.value === null )
    return;
    if( path.isRelative( it.value ) )
    return;
    // it.value = false; // yyy
    return it.value;
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
  o2.inplace = 0;

  return filter.allPaths( o2 );

  /* - */

  function onEach( element, it )
  {
    _.sure
    (
      it.value === null || path.isRelative( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has  ' + _.toStr( it.value )
    );
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
  o2.inplace = 0;

  let result = filter.allPaths( o2 );

  return result;

  /* - */

  function onEach( element, it )
  {
    _.sure
    (
      it.value === null || _.boolLike( it.value ) || path.s.allAreRelative( it.value ) || path.s.allAreGlobal( it.value ),
      () => 'Filter should have relative ' + it.fieldName + ', but has ' + _.toStr( it.value )
    );
  }

}

sureRelative.defaults =
{
  fixes : 1,
  basePath : 1,
  filePath : 1,
}

//

function sureBasePath( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  basePath = basePath || filter.basePath;
  filePath = filter.filePathArrayNonBoolGet( filePath || filter.filePath, 1 );
  filePath = filePath.filter( ( e ) => _.strIs( e ) && e );

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( !_.arrayIs( basePath ) );

  if( !basePath || _.strIs( basePath ) )
  return;

  let diff = _.arraySetDiff( path.s.fromGlob( _.mapKeys( basePath ) ), path.s.fromGlob( filePath ) );
  _.sure( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );

  for( let g in basePath )
  {
    _.sure
    (
      !path.isGlob( basePath[ g ] ),
      () => 'Base path should not be glob, but base path ' + _.strQuote( basePath[ g ] ) + ' for file path ' + _.strQuote( g ) + ' is glob'
    );
  }

}

//

function assertBasePath( filePath, basePath )
{
  let filter = this;

  if( !Config.debug )
  return;

  _.assert( arguments.length === 0 || arguments.length === 2 );

  return filter.sureBasePath( filePath, basePath );
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

  if( _.any( filter.prefixPath, ( e ) => _.strIs( e ) && e ) )
  return true;

  if( _.any( filter.postfixPath, ( e ) => _.strIs( e ) && e ) )
  return true;

  // let filePath = filter.filePathArrayGet();
  let filePath = filter.filePathArrayNonBoolGet();

  if( filePath.length === 1 )
  if( filePath[ 0 ] === '.' || filePath[ 0 ] === '' || filePath[ 0 ] === null ) // xxx
  {
    /*
    exception for dst filter
    actually, exception for src filter
    */
    if( filter.src )
    if( filePath[ 0 ] === '.' ) // xxx
    return true;
    return false;
  }

  if( filePath.length )
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

function moveTextualReport()
{
  let filter = this;
  let fileProvider = filter.hubFileProvider || filter.effectiveFileProvider || filter.defaultFileProvider;
  let path = fileProvider.path;

  _.assert( filter.isPaired() );

  filter = filter.pairedClone();
  filter._formPaths();
  filter.pairedFilter._formPaths();

  let srcFilter = filter.src ? filter.src : filter;
  let dstFilter = srcFilter.dst;

  let srcPath = srcFilter.filePathSrcCommon();
  let dstPath = dstFilter.filePathDstCommon();
  let result = path.moveTextualReport( dstPath, srcPath );

  return result;
}

//

function compactField( it )
{
  let filter = this;

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

  result += 'Filter';

  for( let m in filter.MaskNames )
  {
    let maskName = filter.MaskNames[ m ];
    if( filter[ maskName ] !== null )
    {
      if( !filter[ maskName ].isEmpty )
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

  if( _.strHas( record.absolute, 'node_modules/wTools/proto/dwtools/abase/l1/cErr.s' ) )
  debugger;

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

/**
 * @typedef {Object} Fields
 * @property {String} filePath
 * @property {String} basePath
 * @property {String} prefixPath
 * @property {String} postfixPath
 *
 * @property {String} hasExtension
 * @property {String} begins
 * @property {String} ends
 *
 * @property {String|Array|RegExp} maskTransientAll
 * @property {String|Array|RegExp} maskTransientTerminal,
 * @property {String|Array|RegExp} maskTransientDirectory
 * @property {String|Array|RegExp} maskAll
 * @property {String|Array|RegExp} maskTerminal
 * @property {String|Array|RegExp} maskDirectory
 *
 * @property {Date} notOlder
 * @property {Date} notNewer
 * @property {Date} notOlderAge
 * @property {Date} notNewerAge
 * @memberof module:Tools/mid/Files.wFileRecordFilter
*/

let isTransientSymbol = Symbol.for( 'isTransient' );
let isActualSymbol = Symbol.for( 'isActual' );
let filePathSymbol = Symbol.for( 'filePath' );
let basePathSymbol = Symbol.for( 'basePath' );

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

  applyTo : null,
  formed : 0,

  src : null,
  dst : null,

}

let Medials =
{
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
  distinct : 'distinct',
  globFound : 'globFound',

}

let Accessors =
{

  filePath : {},
  basePath : { setter : basePathSet },
  basePaths : { getter : basePathsGet, readOnly : 1 },
  pairedFilter : { getter : pairedFilterGet, readOnly : 1 },

}

// --
// declare
// --

let Extend =
{

  TollerantFrom,
  init,
  copy,
  pairedClone,

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
  prefixPathFromFilePath,
  pathLocalize,
  pathsNormalize,
  globalsFromLocals,

  // combiner

  And,
  and,
  _pathsJoin,
  pathsJoin,
  pathsJoinWithoutNull,
  pathsExtend,
  pathsInherit,
  // pathsExtend,

  // base path

  relativeFor,
  basePathForFilePath,
  basePathFor,
  basePathsGet,
  basePathFrom,
  basePathMapNormalize,
  basePathNormalize,
  basePathSimplify,
  basePathDotUnwrap,
  basePathEach, /* qqq : cover routine basePathEach */
  basePathUse,

  // file path

  filePathCopy,
  // filePathGet,
  // filePathSet,

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
  filePathMapOnlyBools,

  filePathDstArrayGet,
  filePathSrcArrayGet,
  filePathArrayGet,

  filePathDstArrayNonBoolGet,
  filePathSrcArrayNonBoolGet,
  filePathArrayNonBoolGet,

  filePathDstArrayBoolGet,
  filePathSrcArrayBoolGet,
  filePathArrayBoolGet,

  filePathDstNormalizedGet, /* xxx : remove maybe? */
  filePathSrcNormalizedGet, /* xxx : remove maybe? */
  filePathNormalizedGet, /* xxx : remove maybe? */

  filePathCommon,
  filePathDstCommon,
  filePathSrcCommon,

  // pair

  pairedFilterGet,
  // pairFor,
  pairWithDst,
  pairRefineLight,
  isPaired,

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

  moveTextualReport,
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
