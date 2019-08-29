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
let Parent = _.FileRecordContext;
let Self = function wFileRecordFilter( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'FileRecordFilter';

_.assert( !_.FileRecordFilter );
_.assert( !!_.regexpsEscape );

// --
// inter
// --

// /**
//  * @summary Creates filter instance ignoring unknown options.
//  * @param {Object} o Options map.
//  * @function TolerantFrom
//  * @memberof module:Tools/mid/Files.wFileRecordFilter
// */
//
// function TolerantFrom( o )
// {
//   _.assert( arguments.length >= 1, 'Expects at least one argument' );
//   _.assert( _.objectIs( Self.prototype.Composes ) );
//   o = _.mapsExtend( null, arguments );
//   return new Self( _.mapOnly( o, Self.prototype.fieldsOfCopyableGroups ) );
// }

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

  let result = Parent.prototype._formAssociations.apply( filter, arguments );

  // /* find file system */
  //
  // if( !filter.system )
  // if( filter.effectiveProvider && filter.effectiveProvider instanceof _.FileProvider.System )
  // {
  //   filter.system = filter.effectiveProvider;
  //   filter.effectiveProvider = null;
  // }
  //
  // if( !filter.system )
  // if( filter.effectiveProvider && filter.effectiveProvider.system && filter.effectiveProvider.system instanceof _.FileProvider.System )
  // {
  //   filter.system = filter.effectiveProvider.system;
  // }
  //
  // if( !filter.system )
  // if( filter.defaultProvider && filter.defaultProvider instanceof _.FileProvider.System )
  // {
  //   filter.system = filter.defaultProvider;
  // }
  //
  // if( !filter.system )
  // if( filter.defaultProvider && filter.defaultProvider.system && filter.defaultProvider.system instanceof _.FileProvider.System )
  // {
  //   filter.system = filter.defaultProvider.system;
  // }
  //
  // if( filter.system )
  // if( filter.system.system && filter.system.system !== filter.system )
  // {
  //   _.assert( !( filter.system instanceof _.FileProvider.System ) );
  //   if( !filter.effectiveProvider )
  //   filter.effectiveProvider = filter.system;
  //   filter.system = filter.system.system;
  // }
  //
  // /* find effective provider */
  //
  // if( filter.effectiveProvider && filter.effectiveProvider instanceof _.FileProvider.System )
  // {
  //   _.assert( filter.system === null || filter.system === filter.effectiveProvider );
  //   filter.system = filter.effectiveProvider;
  //   filter.effectiveProvider = null;
  // }
  //
  // /* reset system */
  //
  // if( filter.effectiveProvider && filter.effectiveProvider.system )
  // {
  //   _.assert( filter.system === null || filter.system === filter.effectiveProvider.system );
  //   filter.system = filter.effectiveProvider.system;
  // }
  //
  // /* find default provider */
  //
  // if( !filter.defaultProvider )
  // {
  //   filter.defaultProvider = filter.defaultProvider || filter.effectiveProvider || filter.system;
  // }
  //
  // /* reset system */
  //
  // if( filter.system && !( filter.system instanceof _.FileProvider.System ) )
  // {
  //   _.assert( filter.system === filter.defaultProvider || filter.system === filter.effectiveProvider )
  //   filter.system = null;
  // }
  //
  // /* */
  //
  // _.assert
  // (
  //   !filter.system || filter.system instanceof _.FileProvider.System,
  //   () => '{- filter.system -} should be instance of {- _.FileProvider.System -}, but it is ' + _.toStrShort( filter.system )
  // );
  // _.assert
  // (
  //   !filter.effectiveProvider || !( filter.effectiveProvider instanceof _.FileProvider.System ),
  //   () => '{- filter.effectiveProvider -} cant be instance of {- _.FileProvider.System -}, but it is'
  // );
  // _.assert
  // (
  //   filter.defaultProvider instanceof _.FileProvider.Abstract,
  //   () => '{- filter.system -} should be instance of {- _.FileProvider.Abstract -}, but it is ' + _.toStrShort( filter.defaultProvider )
  // );

  /* */

  filter.maskAll = _.RegexpObject( filter.maskAll );
  filter.maskTerminal = _.RegexpObject( filter.maskTerminal );
  filter.maskDirectory = _.RegexpObject( filter.maskDirectory );

  filter.maskTransientAll = _.RegexpObject( filter.maskTransientAll );
  filter.maskTransientTerminal = _.RegexpObject( filter.maskTransientTerminal );
  filter.maskTransientDirectory = _.RegexpObject( filter.maskTransientDirectory );

  /* */

  filter.formed = 1;
  return result;
}

//

function _formPre()
{
  let filter = this;

  if( filter.formed < 1 )
  filter._formAssociations();

  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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

  if( filter.formed > 2 )
  return;
  if( filter.formed < 2 )
  filter._formPre();

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );

  filter.pathsRefine();
  filter.assertBasePath();

  filter.formed = 3;
}

//

function _formMasks()
{
  let filter = this;

  if( filter.formed < 3 )
  filter._formPaths();

  let fileProvider = filter.effectiveProvider || filter.defaultProvider || filter.system;
  let path = fileProvider.path;

  /* */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 3 );

    if( filter.basePath )
    filter.assertBasePath();

    // _.assert // yyy
    // (
    //      ( _.arrayIs( filter.filePath ) && filter.filePath.length === 0 )
    //   || ( _.mapIs( filter.filePath ) && _.mapKeys( filter.filePath ).length === 0 )
    //   || ( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length > 0 )
    //   || _.strIs( filter.basePath )
    //   , 'Cant deduce base path'
    // );

    _.assert( _.mapIs( filter.basePath ) || !!filter.src ); // xxx
    _.assert( _.mapIs( filter.filePath ), 'filePath of file record filter is not defined' );

    if( filter.basePath )
    filter.basePathEach( ( filePath, basePath ) =>
    {
      _.assert( filter.src || filter.filePath[ filePath ] !== undefined, () => 'Not found file path ' + _.strQuote( filePath ) );
      _.assert( path.isAbsolute( basePath ), () => 'Expects absolute base path, but ' + _.strQuote( basePath ) + ' is not' );
    });

  }

  /* */

  filter.maskExtensionApply();
  filter.maskBeginsApply();
  filter.maskEndsApply();
  filter.masksGenerate();

  filter.formed = 4;
}

//

function _formFinal()
{
  let filter = this;

  if( filter.formed < 4 )
  filter._formMasks();

  /*
    should use effectiveProvider because of option globbing of file provider
  */

  let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider;
  let path = fileProvider.path;

  /* - */

  if( Config.debug )
  {

    _.assert( arguments.length === 0 );
    _.assert( filter.formed === 4 );
    _.assert( _.strIs( filter.filePath ) || _.arrayIs( filter.filePath ) || _.mapIs( filter.filePath ) );
    _.assert( !!filter.src || _.mapIs( filter.formedBasePath ) || _.mapKeys( filter.formedFilePath ).length === 0 );
    _.assert( !!filter.src || _.mapIs( filter.formedFilePath ) );
    _.assert( _.objectIs( filter.effectiveProvider ) );
    _.assert( filter.system === filter.effectiveProvider.system || filter.system === filter.effectiveProvider );
    _.assert( filter.system instanceof _.FileProvider.Abstract );
    _.assert( filter.defaultProvider instanceof _.FileProvider.Abstract );

    let filePath = filter.filePathArrayGet( filter.formedFilePath ).filter( ( e ) => _.strIs( e ) && e );
    _.assert( path.s.noneAreGlob( filePath ) );
    _.assert
    (
      path.s.allAreAbsolute( filePath ) || path.s.allAreGlobal( filePath ),
      () => 'Expects absolute or global file path, but got\n' + _.toJson( filePath )
    );

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

  if( filter.recursive === null )
  filter.recursive = 2;

  filter.applyTo = filter._applyToRecordNothing;

  if( filter.notOlder || filter.notNewer || filter.notOlderAge || filter.notNewerAge )
  filter.applyTo = filter._applyToRecordFull;
  else if( filter.hasMask() )
  filter.applyTo = filter._applyToRecordMasks;

  filter.formed = 5;
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

  // if( Config.debug )
  // if( src && !( src instanceof filter.Self ) )
  // _.assertMapHasOnly( src, filter.fieldsOfCopyableGroups );

  if( src === null )
  return filter;

  let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider;
  if( !( src instanceof _.FileRecordFilter ) )
  src = fileProvider.recordFilter( src );

  _.assert( filter instanceof _.FileRecordFilter );
  _.assert( src instanceof _.FileRecordFilter );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !src.formed || src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.effectiveProvider || !src.effectiveProvider || filter.effectiveProvider === src.effectiveProvider );
  _.assert( !filter.system || !src.system || filter.system === src.system );

  if( src === filter )
  return filter;

  /* */

  if( src.effectiveProvider )
  filter.effectiveProvider = src.effectiveProvider

  if( src.system )
  filter.system = src.system

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
    recursive : null,
    notOlder : null,
    notNewer : null,
    notOlderAge : null,
    notNewerAge : null,
  }

  for( let n in once )
  {
    _.assert( !filter[ n ] || !src[ n ], 'Cant "and" filter with another filter, them both have field', n );
    if( filter[ n ] === null && src[ n ] !== null )
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

// //
//
// function _pathsJoin_pre( routine, args )
// {
//   let filter = this;
//   let o;
//
//   if( _.mapIs( args[ 0 ] ) )
//   o = args[ 0 ];
//   else
//   o = { src : args }
//
//   _.assert( arguments.length === 2 );
//   _.routineOptions( routine, o );
//
//   return o;
// }
//
// //
//
// function _pathsJoin_body( o )
// {
//   let filter = this;
//
//   if( _.arrayLike( o.src ) )
//   {
//     for( let a = 0 ; a < o.src.length ; a++ )
//     {
//       let o2 = _.mapExtend( null, o );
//       o2.src = o2.src[ a ];
//       filter._pathsJoin.body.call( filter, o2 );
//     }
//     return filter;
//   }
//
//   if( Config.debug )
//   if( o.src && !( o.src instanceof filter.Self ) )
//   _.assertMapHasOnly( o.src, filter.fieldsOfCopyableGroups );
//
//   _.assert( _.instanceIs( filter ) );
//   _.assert( !filter.formed || filter.formed <= 1 );
//   _.assert( !o.src.formed || o.src.formed <= 1 );
//   _.assert( arguments.length === 1, 'Expects single argument' );
//   _.assert( filter.formedFilterMap === null );
//   _.assert( filter.applyTo === null );
//   _.assert( !filter.system || !o.src.system || filter.system === o.src.system );
//   _.assert( o.src !== filter );
//   _.assert( _.objectIs( o.src ) );
//   // _.assert( o.src.filePath === null || o.src.filePath === undefined || o.src.filePath === '.' || _.strIs( o.src.filePath ) );
//
//   let fileProvider = filter.system || filter.defaultProvider || filter.effectiveProvider || o.src.system || o.src.defaultProvider || o.src.effectiveProvider;
//   let path = fileProvider.path;
//
//   if( o.src.system )
//   filter.system = o.src.system;
//
//   /* */
//
//   for( let n in o.joiningAsPathMap )
//   if( o.src[ n ] !== undefined && o.src[ n ] !== null )
//   {
//     if( filter[ n ] === null )
//     {
//       filter[ n ] = o.src[ n ];
//       continue;
//     }
//     if( filter.src )
//     {
//       debugger;
//       if( !_.mapIs( filter[ n ] ) )
//       filter[ n ] = path.mapExtend( null, null, filter[ n ] );
//       path.mapExtend( filter[ n ], o.src[ n ], null );
//     }
//     else
//     {
//       path.mapExtend( filter[ n ], o.src[ n ], null );
//     }
//   }
//
//   /* */
//
//   for( let n in o.joiningWithoutNullMap )
//   if( o.src[ n ] !== undefined && o.src[ n ] !== null )
//   {
//     _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
//     _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
//     filter[ n ] = path.join( filter[ n ], o.src[ n ] );
//   }
//
//   /* */
//
//   for( let n in o.joiningMap )
//   if( o.src[ n ] !== undefined )
//   {
//     _.assert( o.src[ n ] === null || _.strIs( o.src[ n ] ) );
//     _.assert( filter[ n ] === null || _.strIs( filter[ n ] ) );
//     filter[ n ] = path.join( filter[ n ], o.src[ n ] );
//   }
//
//   /* */
//
//   for( let n in o.baseMap )
//   if( o.src[ n ] )
//   {
//     o.src[ n ] = o.src.basePathMapFromString( o.src.filePath, o.src[ n ], 0 );
//     if( filter[ n ] )
//     filter[ n ] = filter.basePathMapFromString( filter.filePath, o.src[ n ], 0 );
//     _.assert( _.mapIs( o.src[ n ] ) );
//     _.assert( filter[ n ] === null || _.mapIs( filter[ n ] ) );
//     filter[ n ] = _.mapExtend( filter[ n ], o.src[ n ] );
//   }
//
//   /* */
//
//   for( let a in o.appendingMap )
//   {
//     if( o.src[ a ] === null || o.src[ a ] === undefined )
//     continue;
//
//     _.assert( _.strIs( o.src[ a ] ) || _.strsAreAll( o.src[ a ] ) );
//     _.assert( filter[ a ] === null || _.strIs( filter[ a ] ) || _.strsAreAll( filter[ a ] ) );
//
//     if( filter[ a ] === null )
//     {
//       filter[ a ] = o.src[ a ];
//     }
//     else
//     {
//       if( _.strIs( filter[ a ] ) )
//       filter[ a ] = [ filter[ a ] ];
//       _.arrayAppendOnce( filter[ a ], o.src[ a ] );
//     }
//
//   }
//
//   return filter;
// }
//
// _pathsJoin_body.defaults =
// {
//
//   src : null,
//
//   joiningAsPathMap :
//   {
//     filePath : null,
//   },
//
//   joiningWithoutNullMap :
//   {
//   },
//
//   joiningMap :
//   {
//     basePath : null,
//   },
//
//   baseMap :
//   {
//     // basePath : null,
//   },
//
//   appendingMap :
//   {
//     prefixPath : null,
//     postfixPath : null,
//   },
//
// }
//
// let _pathsJoin = _.routineFromPreAndBody( _pathsJoin_pre, _pathsJoin_body );
//
// //
//
// function pathsJoin()
// {
//   let filter = this;
//   return filter._pathsJoin
//   ({
//     src : arguments,
//     joiningAsPathMap :
//     {
//       filePath : null,
//     },
//     joiningWithoutNullMap :
//     {
//     },
//     joiningMap :
//     {
//       basePath : null,
//     },
//     baseMap :
//     {
//       // basePath : null,
//     },
//     appendingMap :
//     {
//       prefixPath : null,
//       postfixPath : null,
//     },
//   });
// }
//
// //
//
// function pathsJoinWithoutNull()
// {
//   let filter = this;
//   return filter._pathsJoin
//   ({
//     src : arguments,
//     joiningAsPathMap :
//     {
//       filePath : null,
//     },
//     joiningWithoutNullMap :
//     {
//       basePath : null,
//     },
//     joiningMap :
//     {
//     },
//     baseMap :
//     {
//       // basePath : null,
//     },
//     appendingMap :
//     {
//       prefixPath : null,
//       postfixPath : null,
//     },
//   });
// }
//
// //
//
// function pathsSupplementJoining( src )
// {
//   let filter = this;
//   let paired = false;
//
//   if( filter.src && filter.src.filePath === filter.filePath )
//   paired = true;
//
//   if( filter.dst && filter.dst.filePath === filter.filePath )
//   paired = true;
//
//   if( arguments.length > 1 )
//   {
//     for( let a = 0 ; a < arguments.length ; a++ )
//     filter.pathsJoin( arguments[ a ] );
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
//   _.assert( !filter.system || !src.system || filter.system === src.system );
//   _.assert( src !== filter );
//
//   let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider || src.effectiveProvider || src.system || src.defaultProvider;
//   let path = fileProvider.path;
//
//   /* */
//
//   if( src.system )
//   filter.system = src.system;
//
//   /* */
//
//   if( !( src instanceof Self ) )
//   src = fileProvider.recordFilter( src );
//
//   if( src.prefixPath && filter.prefixPath )
//   {
//     let prefixPath = filter.prefixPath;
//     src.prefixesApply();
//     filter.prefixesApply();
//     _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
//     if( filter.filePath === null )
//     filter.prefixPath = prefixPath;
//   }
//
//   _.assert( src.prefixPath === null || filter.prefixPath === null );
//   _.assert( src.postfixPath === null || filter.postfixPath === null );
//   _.assert( src.postfixPath === null && filter.postfixPath === null, 'not implemented' );
//
//   filter.prefixPath = filter.prefixPath || src.prefixPath;
//   filter.postfixPath = filter.postfixPath || src.postfixPath;
//
//   /* */
//
//   let dstSrcNonBoolPaths = filter.filePathSrcArrayNonBoolGet( filter.filePath, 0 );
//   let srcOnlyBoolPathMap = src.filePathMapOnlyBools( src.filePath );
//   let srcSrcNonBoolPaths = src.filePathSrcArrayNonBoolGet( src.filePath, 0 );
//   let srcDstNonBoolPaths = src.filePathDstArrayNonBoolGet( src.filePath, 0 ).filter( ( p ) => !path.isEmpty( p ) );
//
//   let dstFilePath = filter.filePath;
//   let srcFilePath = src.filePath;
//   if( dstSrcNonBoolPaths.length === 0 && srcSrcNonBoolPaths.length === 0 )
//   {
//     if( dstFilePath )
//     dstFilePath = path.filter( dstFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
//     if( srcFilePath )
//     srcFilePath = path.filter( srcFilePath, ( e ) => _.boolLike( e ) && e ? null : e );
//   }
//
//   let dstSrcIsDot = false;
//   if( dstSrcNonBoolPaths.length === 1 )
//   if( dstSrcNonBoolPaths[ 0 ] === '.' || dstSrcNonBoolPaths[ 0 ] === '' ) // yyy
//   {
//     dstSrcIsDot = true;
//     dstSrcNonBoolPaths = [];
//   }
//
//   /* */
//
//   if( filter.basePath === null && _.mapIs( src.basePath ) )
//   {
//
//     for( let p = 0 ; p < dstSrcNonBoolPaths.length ; p++ )
//     {
//       let filePath = dstSrcNonBoolPaths[ p ];
//       if( src.basePath[ p ] === undefined )
//       {
//         filter.basePath = filter.basePath || Object.create( null );
//         filter.basePath[ filePath ] = filePath;
//       }
//     }
//
//   }
//
//   if( src.basePath && filter.basePath )
//   {
//
//     if( _.strIs( src.basePath ) )
//     src.basePath = src.basePathMapFromString
//     ({
//       filePath : src.filePath || {},
//       basePath : src.basePath,
//       prefixingWithFilePath : 0,
//     });
//     _.assert( _.mapIs( src.basePath ) || _.strIs( src.basePath ) );
//
//     if( _.strIs( filter.basePath ) )
//     filter.basePath = filter.basePathMapFromString
//     ({
//       filePath : filter.filePath || {},
//       basePath : filter.basePath,
//       prefixingWithFilePath : 0,
//     });
//     _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) );
//
//   }
//
//   /* */
//
//   if( filter.filePath && src.filePath )
//   {
//
//     let dstSrcPath = filter.filePathSrcArrayGet();
//     let dstDstPath = filter.filePathDstArrayGet();
//
//     if( dstSrcNonBoolPaths.length === 0 && !dstSrcIsDot )
//     {
//       if( filter.src && !_.mapIs( filter.src ) )
//       filter.filePath = path.mapExtend( null, filter.filePath, null );
//
//       if( src.src && !_.mapIs( src.src ) )
//       src.filePath = path.mapExtend( null, src.filePath, null );
//
//       filter.filePath = path.mapExtend( filter.filePath, src.filePath, null );
//     }
//     else if( path.isEmpty( dstSrcPath ) )
//     {
//       if( !dstDstPath.length )
//       dstDstPath = null;
//       filter.filePath = path.mapExtend( null, src.filePathSrcArrayGet(), dstDstPath );
//     }
//     else
//     {
//       if( Object.keys( srcOnlyBoolPathMap ).length )
//       {
//         filter.filePath = path.mapExtend( filter.filePath, srcOnlyBoolPathMap, null );
//       }
//       if( srcDstNonBoolPaths.length )
//       {
//         // debugger;
//         filter.filePath = path.mapExtend( filter.filePath, null, srcDstNonBoolPaths );
//       }
//     }
//
//   }
//   else
//   {
//     filter.filePath = filter.filePath || src.filePath;
//   }
//
//   /* */
//
//   if( src.basePath && filter.basePath )
//   {
//
//     if( _.mapIs( filter.basePath ) && srcFilePath )
//     for( let filePath in filter.basePath )
//     {
//       if( _.boolLike( srcFilePath[ filePath ] ) && !srcFilePath[ filePath ] )
//       delete filter.basePath[ filePath ];
//     }
//
//     _.assert( _.mapIs( filter.filePath ) || filter.filePath === null );
//     if( _.mapIs( src.basePath ) )
//     for( let filePath in src.basePath )
//     {
//       let basePath = src.basePath[ filePath ];
//       if( filter.filePath )
//       if( filter.filePath[ filePath ] !== undefined )
//       if( !filter.basePath[ filePath ] )
//       filter.basePath[ filePath ] = basePath;
//     }
//
//   }
//   else
//   {
//     filter.basePath = filter.basePath || src.basePath;
//   }
//
//   /* */
//
//   if( paired && filter.src && filter.src.filePath !== filter.filePath )
//   filter.src.filePath = filter.filePath;
//
//   if( paired && filter.dst && filter.dst.filePath !== filter.filePath )
//   filter.dst.filePath = filter.filePath;
//
//   return filter;
// }

//

function _pathsAmmend( o )
{
  let filter = this;

  if( _.arrayIs( o.src.length ) )
  {
    for( let a = 0 ; a < o.src.length ; a++ )
    filter.pathsJoin({ src : o.src[ a ], joining : o.joining });
    return filter;
  }

  _.assertRoutineOptions( _pathsAmmend, arguments );
  _.assert( _.instanceIs( filter ) );
  _.assert( !filter.formed || filter.formed <= 1 );
  _.assert( !o.src.formed || o.src.formed <= 1 );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( filter.formedFilterMap === null );
  _.assert( filter.applyTo === null );
  _.assert( !filter.system || !o.src.system || filter.system === o.src.system );
  _.assert( o.src !== filter );

  let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider || o.src.effectiveProvider || o.src.system || o.src.defaultProvider;
  let path = fileProvider.path;

  /* */

  if( o.src.system )
  filter.system = o.src.system;
  if( !( o.src instanceof Self ) )
  o.src = fileProvider.recordFilter( o.src );

  /* fixes */

  let dstFilePathArrayNonBool = filter.filePathArrayNonBoolGet();
  let srcFilePathArrayNonBool = o.src.filePathArrayNonBoolGet();
  let filePathDeducingFromFixes = !dstFilePathArrayNonBool.length && !srcFilePathArrayNonBool.length;
  let booleanFallingBack = filePathDeducingFromFixes ? true : false;
  filePathDeducingFromFixes = true;
  booleanFallingBack = false;

  if( o.src.prefixPath && filter.prefixPath )
  {
    let prefixPath = o.src.prefixPath;
    o.src.prefixesApply({ filePathDeducingFromFixes, booleanFallingBack });
    filter.prefixesApply({ filePathDeducingFromFixes, booleanFallingBack });
    _.assert( !_.mapIs( filter.filePath ) || !!_.mapKeys( filter.filePath ).length );
    // if( filter.filePath === null ) // yyy
    // filter.prefixPath = prefixPath;
  }

  if( o.src.prefixPath && ( o.src.filePath || o.src.basePath ) )
  {
    o.src.prefixesApply({ filePathDeducingFromFixes, booleanFallingBack });
  }

  if( filter.prefixPath && ( filter.filePath || filter.basePath ) )
  {
    filter.prefixesApply({ filePathDeducingFromFixes, booleanFallingBack });
  }

  if( filter.prefixPath === '' )
  {
    filter.prefixPath = null;
    debugger; /* qqq : cover please */
  }

  if( filter.postfixPath === '' )
  {
    filter.postfixPath = null;
    debugger; /* qqq : cover please */
  }

  _.assert( o.src.prefixPath === '' || o.src.prefixPath === null || filter.prefixPath === null );
  _.assert( o.src.postfixPath === '' || o.src.postfixPath === null || filter.postfixPath === null );

  if( o.src.prefixPath !== null )
  filter.prefixPath = o.src.prefixPath || null;

  if( o.src.postfixPath !== null )
  filter.postfixPath = o.src.postfixPath || null;

  /* base path */

  let basePathReady = false;
  if( o.src.basePath && filter.basePath )
  {

    let srcBaseMap = o.src.basePath;
    if( _.strIs( srcBaseMap ) )
    srcBaseMap = o.src.basePathMapFromString
    ({
      filePath : o.src.filePath || {},
      basePath : srcBaseMap,
      // prefixingWithFilePath : o.joining,
      prefixingWithFilePath : 0,
      booleanFallingBack : booleanFallingBack,
    });
    _.assert( _.mapIs( srcBaseMap ) || _.strIs( srcBaseMap ) );

    if( _.strIs( filter.basePath ) )
    filter.basePath = filter.basePathMapFromString
    ({
      filePath : filter.filePath || {},
      basePath : filter.basePath,
      prefixingWithFilePath : 0,
      // prefixingWithFilePath : o.joining,
      booleanFallingBack : booleanFallingBack,
    });
    _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) );

    if( o.joining )
    {
      if( path.isEmpty( filter.filePath ) && path.isEmpty( o.src.filePath ) )
      {

        basePathReady = true;
        if( !filter.basePath || !o.src.basePath )
        {
          filter.basePath = filter.basePath || srcBaseMap;
        }
        else
        {
          let dstBasePath = filter.basePath;
          let srcBasePath = o.src.basePath;

          filter.basePath = path.simplifyDst( filter.basePath );
          srcBaseMap = path.simplifyDst( srcBaseMap );

          if( filter.basePath === '' )
          {
            filter.basePath === srcBaseMap;
          }
          else if( _.mapIs( srcBaseMap ) || _.mapIs( filter.basePath ) )
          {
            if( !_.mapIs( filter.basePath ) )
            filter.basePath = { '' : filter.basePath };
            if( !_.mapIs( srcBaseMap ) )
            srcBaseMap = { '' : srcBaseMap };

            let baseMap2 = Object.create( null );
            if( o.supplementing )
            for( let filePath in filter.basePath )
            {
              let basePath = filter.basePath[ filePath ];
              let basePath2 = srcBaseMap[ filePath ];
              if( !basePath2 )
              baseMap2[ filePath ] = basePath;
              else
              baseMap2[ filePath ] = path.join( basePath2, basePath );
            }
            else for( let filePath in srcBaseMap )
            {
              let basePath = filter.basePath[ filePath ];
              let basePath2 = srcBaseMap[ filePath ];
              if( !basePath )
              baseMap2[ filePath ] = basePath2;
              else
              baseMap2[ filePath ] = path.join( basePath, basePath2 );
            }

            filter.basePath = path.simplifyDst( baseMap2 );
            if( filter.basePath === '' )
            filter.basePath = null;
          }
          else
          {

            if( o.supplementing )
            filter.basePath = path.join( srcBaseMap, filter.basePath );
            else
            filter.basePath = path.join( filter.basePath, srcBaseMap );

          }

        }
      }
    }
    else if( !o.joining )
    {
      if( _.mapIs( filter.basePath ) && _.mapIs( srcBaseMap ) )
      {
        if( o.supplementing )
        filter.basePath = _.mapSupplement( filter.basePath, srcBaseMap );
        else
        filter.basePath = _.mapExtend( filter.basePath, srcBaseMap );
      }
      else
      {

        if( o.supplementing )
        filter.basePath = filter.basePath || srcBaseMap;
        else
        filter.basePath = srcBaseMap || filter.basePath;

      }
    }

  }
  else
  {
    basePathReady = true;
    if( o.src.basePath === '' )
    filter.basePath = null;
    else
    filter.basePath = filter.basePath || o.src.basePath;
  }

  /* file path */

  let basePath2 = Object.create( null );

  if( o.joining )
  {

    if( !_.mapIs( filter.filePath ) && !_.mapIs( o.src.filePath ) )
    {
      if( filter.filePath || o.src.filePath )
      filter.filePath = path.filter( filter.filePath, ( dstFilePath ) =>
      {
        return path.filter( o.src.filePath, ( srcFilePath ) =>
        {
          return join( dstFilePath, srcFilePath );
        });
      });
    }
    else
    {

      let boolsMap = Object.create( null );
      let dstFilePath = path.filterPairs( filter.filePath, ( it1 ) =>
      {
        _.assert( it1.dst !== null );
        if( !_.strIs( it1.dst ) )
        boolsMap[ it1.src ] = it1.dst;
        else
        return { [ it1.src ] : it1.dst }
      });
      let srcFilePath = path.filterPairs( o.src.filePath, ( it2 ) =>
      {
        _.assert( it2.dst !== null );
        if( !_.strIs( it2.dst ) )
        {
          if( !o.supplementing || boolsMap[ it2.src ] === undefined )
          boolsMap[ it2.src ] = it2.dst;
        }
        else
        return { [ it2.src ] : it2.dst }
      });

      let filePath = path.filterPairs( dstFilePath, ( it1 ) =>
      {
        if( !_.strIs( it1.dst ) )
        return;
        return path.filterPairs( srcFilePath, ( it2 ) =>
        {
          if( !_.strIs( it2.dst ) )
          return;
          let src = join( it1.src, it2.src, 'src' );
          let dst = join( it1.dst, it2.dst, 'dst' );
          return { [ src ] : dst };
        });
      });

      if( filter.src )
      filter.src.filePath = filePath;
      else
      filter.filePath = filePath;

      if( Object.keys( boolsMap ).length )
      filter.filePath = path.mapExtend( filter.filePath, boolsMap );

    }

    // if( !path.isEmpty( filter.filePath ) || !path.isEmpty( o.src.filePath ) )
    if( !basePathReady )
    {
      basePathReady = true;
      if( _.mapKeys( basePath2 ).length === 0 && !filter.basePath )
      {}
      else if( _.mapKeys( basePath2 ).length === 1 && basePath2[ '' ] !== undefined )
      filter.basePath = basePath2[ '' ];
      else
      filter.basePath = basePath2;
    }

  }
  else
  {

    let isDst = !!filter.src || !!o.src.src;

    if( !filter.filePath || !o.src.filePath )
    {
      filter.filePath = filter.filePath || o.src.filePath;
    }
    else if( ( _.mapIs( filter.filePath ) && _.mapIs( o.src.filePath ) ) || !isDst )
    {
      if( o.supplementing )
      filter.filePath = path.mapSupplement( filter.filePath, o.src.filePath, null );
      else
      filter.filePath = path.mapExtend( filter.filePath, o.src.filePath, null );
    }
    else if( !_.mapIs( filter.filePath ) )
    {
      _.assert( isDst );
      _.assert( _.mapIs( o.src.filePath ), 'not tested' ); /* qqq : cover it */
      if( o.supplementing )
      filter.filePath = path.mapSupplement( null, o.src.filePath, filter.filePath );
      else
      filter.filePath = path.mapExtend( null, o.src.filePath, filter.filePath );
    }

  }

  /* */

  return filter;

  /* */

  function join( dstFilePath, srcFilePath, side )
  {
    if( !side )
    side = filter.src ? 'dst' : 'src';
    let result;

    if( o.supplementing )
    result = path.join( srcFilePath, dstFilePath );
    else
    result = path.join( dstFilePath, srcFilePath );

    if( !basePathReady )
    if( side === ( filter.src ? 'dst' : 'src' ) )
    {
      let dstBasePath = filter.basePathForStemPath( dstFilePath );
      let srcBasePath = o.src.basePathForStemPath( srcFilePath );
      if( srcBasePath || dstBasePath )
      if( o.supplementing )
      basePath2[ result ] = path.join( srcBasePath || '.', dstBasePath || '.' );
      else
      basePath2[ result ] = path.join( dstBasePath || '.', srcBasePath || '.' );
    }

    return result;
  }

  // /* */
  //
  // function extend( dstFilePath, srcFilePath )
  // {
  //   let result;
  //
  //   if( o.supplementing )
  //   result = path.mapSupplement( dstFilePath, srcFilePath, null );
  //   else
  //   result = path.mapExtend( dstFilePath, srcFilePath, null );
  //
  //   return result;
  // }

}

_pathsAmmend.defaults =
{
  src : null,
  joining : 0,
  supplementing : 0,
}

//

function pathsExtend( src )
{
  let filter = this;
  return filter._pathsAmmend
  ({
    src : src,
    joining : 0,
    supplementing : 0,
  });
}

//

function pathsExtendJoining( src )
{
  let filter = this;
  return filter._pathsAmmend
  ({
    src : src,
    joining : 1,
    supplementing : 0,
  });
}

//

function pathsSupplement( src )
{
  let filter = this;
  return filter._pathsAmmend
  ({
    src : src,
    joining : 0,
    supplementing : 1,
  });
}

//

function pathsSupplementJoining( src )
{
  let filter = this;
  return filter._pathsAmmend
  ({
    src : src,
    joining : 1,
    supplementing : 1,
  });
}

// --
// prefix path
// --

/**
 * @descriptionNeeded
 * @param {Object} o Options map.
 * @param {Boolean} o.applyingToTrue=false
 * @function prefixesApply
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function prefixesApply( o )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filter.prefixPath === null && filter.postfixPath === null )
  return filter;

  let paired = filter.isPaired();
  let prefixArray = _.arrayAs( filter.prefixPath || '.' );
  let postfixArray = _.arrayAs( filter.postfixPath || '.' );

  o = _.routineOptions( prefixesApply, arguments );
  _.assert( filter.prefixPath === null || _.strIs( filter.prefixPath ) || _.strsAreAll( filter.prefixPath ) );
  _.assert( filter.postfixPath === null || _.strIs( filter.postfixPath ) || _.strsAreAll( filter.postfixPath ) );
  _.assert( filter.postfixPath === null, 'not implemented' );
  // if( filter.basePath && filter.filePath )
  // filter.assertBasePath();

  let dstArray = filter.filePathDstArrayGet();
  let regularPathHaving = dstArray.filter( ( e ) => !_.boolLike( e ) ).length;
  if( o.booleanFallingBack )
  if( o.applyingToTrue === null )
  {
    o.applyingToTrue = false;
    if( filter.filePath )
    o.applyingToTrue = !regularPathHaving;
  }

  /* */

  let basePath2 = Object.create( null );

  if( filter.filePath )
  filter.filePath = path.filterInplace( filter.filePath, filePathEach );

  if( o.filePathDeducingFromFixes && !regularPathHaving )
  if( !o.applyingToTrue || !dstArray.length )
  filePathDeduceFromFixes();

  basePathUpdate();

  /* */

  filter.prefixPath = null;
  filter.postfixPath = null;

  if( !Config.debug )
  return filter;

  _.assert( !_.arrayIs( filter.basePath ) );
  _.assert( _.mapIs( filter.basePath ) || _.strIs( filter.basePath ) || filter.basePath === null );

  if( filter.basePath && filter.filePath )
  filter.assertBasePath();

  return filter;

  /* */

  function basePathUpdate()
  {

    if( _.mapKeys( basePath2 ).length )
    {
      for( let filePath in basePath2 )
      if( _.arrayIs( basePath2[ filePath ] ) )
      basePath2[ filePath ] = basePath2[ filePath ][ 0 ];

      if( _.mapIs( filter.basePath ) )
      {
        _.mapDelete( filter.basePath ); // xxx : cover
        _.mapExtend( filter.basePath, basePath2 );
      }
      else
      {
        filter.basePath = basePath2;
        filter.basePath = filter.basePathSimplest();
      }
    }

  }

  /* */

  function filePathDeduceFromFixes()
  {
    let negatives = Object.create( null );
    if( _.mapIs( filter.filePath ) )
    for( let f in filter.filePath )
    if( _.boolLike( filter.filePath[ f ] ) && !filter.filePath[ f ] )
    negatives[ f ] = filter.filePath[ f ];
    prefixArray.forEach( ( prefixPath ) =>
    {
      postfixArray.forEach( ( postfixPath ) =>
      {
        let filePathFromPrefixes = path.join( prefixPath, postfixPath );
        let addedBase = basePathsForFilePaths( filePathFromPrefixes, prefixPath, postfixPath, filter.basePath );
        if( filter.src )
        filter.filePath = path.mapExtend( filter.filePath, { '' : filePathFromPrefixes } );
        else
        filter.filePath = path.mapExtend( filter.filePath, filePathFromPrefixes );
      });
    });
    if( Object.keys( negatives ).length )
    {
      for( let src in negatives )
      {
        let dst = negatives[ src ];
        if( basePath2[ src ] )
        delete basePath2[ src ];
        filter.filePath[ src ] = dst;
      }
    }
    filter.filePath = path.simplify( filter.filePath );
  }

  /* */

  function filePathEach( element, it )
  {

    _.assert( it.value === null || _.strIs( it.value ) || _.boolLike( it.value ) || _.arrayIs( it.value ) );

    if( filter.src )
    {
      if( it.side === 'src' )
      return it.value;
    }
    else if( filter.dst || filter.src === null )
    {
      if( it.side === 'dst' )
      {
        if( o.applyingToTrue && _.boolLike( it.value ) && it.value )
        {
          debugger;
          return '';
        }
        return it.value;
      }
    }

    let value = it.value;
    let result = [];

    if( it.side === 'dst' && _.strIs( it.value ) )
    it.value = path.fromGlob( it.value );

    prefixArray.forEach( ( prefixPath ) =>
    {
      postfixArray.forEach( ( postfixPath ) =>
      {
        let currentValue = it.value;

        // debugger;
        if( _.boolLike( it.value ) && it.side === 'dst' )
        if( !it.value || !o.applyingToTrue )
        {
          result.push( !!it.value );
          return;
        }

        if( it.value === null || it.value === '' || _.boolLike( it.value ) )
        {
          currentValue = path.s.join( prefixPath, postfixPath );
        }
        else
        {
          _.assert( _.strIs( it.value ) );
          currentValue = path.s.join( prefixPath, it.value, postfixPath );
        }

        _.arrayAppendOnce( result, currentValue );

        if( !_.boolLike( it.dst ) || ( it.dst && o.applyingToTrue ) )
        {
          if( _.mapIs( filter.basePath ) && _.strIs( value ) )
          {
            let basePath = filter.basePath[ value ];
            if( basePath )
            {
              _.assert( !!basePath, 'No base path for ' + value );
              delete filter.basePath[ value ];
              filter.basePath[ currentValue ] = basePath;
            }
          }
          basePathsForFilePaths( currentValue, prefixPath, postfixPath, _.mapIs( filter.basePath ) );
        }
        else if( !o.filePathDeducingFromFixes && _.mapIs( filter.basePath ) && _.strIs( value ) && filter.basePath[ value ] )
        {
          let basePath = filter.basePath[ value ];
          delete filter.basePath[ value ];
          filter.basePath[ currentValue ] = basePath;
          basePathsForFilePaths( currentValue, prefixPath, postfixPath, _.mapIs( filter.basePath ) );
        }

      });
    });

    it.value = result;
    return it.value;
  }

  /* */

  function basePathsForFilePaths( filePath, prefixPath, postfixPath, addingAnyway )
  {

    _.assert( arguments.length === 4 );

    if( _.arrayIs( filePath ) )
    {
      let any = [];
      filePath.forEach( ( filePath ) => any.push( basePathsForFilePaths( filePath, prefixPath, postfixPath, addingAnyway ) ) );
      return any.some( ( e ) => e );
    }

    _.assert( _.strIs( filePath ) );

    let basePath = filter.basePathForStemPath( filePath );
    if( basePath )
    {
      let extend = basePathEach( filePath, basePath, prefixPath, postfixPath );
      return true;
    }
    if( addingAnyway )
    {
      let extend = basePathEach( filePath, path.fromGlob( filePath ), '.', '.' );
      return true;
    }

  }

  /* */

  function basePathEach( filePath, basePath, prefixPath, postfixPath )
  {
    _.assert( _.strIs( filePath ) );

    let prefixPath2 = prefixPath;
    if( prefixPath2 )
    prefixPath2 = path.s.fromGlob( prefixPath2 );

    let postfixPath2 = postfixPath;
    if( postfixPath2 )
    postfixPath2 = path.s.fromGlob( postfixPath2 );

    let r = Object.create( null );

    basePath = path.s.join( prefixPath2 || '.', basePath, postfixPath2 || '.' );

    _.assert( !_.boolLike( filePath ) );

    if( _.arrayIs( filePath ) )
    {
      for( let f = 0 ; f < filePath.length ; f++ )
      r[ filePath[ f ] ] = basePath;
    }
    else
    {
      r[ filePath ] = basePath;
    }

    path.mapSupplement( basePath2, r );

    return r;
  }

}

prefixesApply.defaults =
{
  filePathDeducingFromFixes : 1,
  booleanFallingBack : 0,
  applyingToTrue : null,
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.routineOptions( prefixPathFromFilePath, arguments );

  if( o.filePath === null )
  o.filePath = filter.filePath;

  let result = o.filePath || filter.filePath;

  if( result === null || result === '' )
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
  usingBools : 1, /* xxx : default to false */
}

//

function prefixPathAbsoluteFrom( o )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  o = _.routineOptions( prefixPathAbsoluteFrom, arguments );

  if( o.filePath === null )
  o.filePath = filter.filePath;
  if( o.basePath === null )
  o.basePath = filter.basePath;

  let result = o.filePath || filter.filePath;

  if( result === null || result === '' )
  return null;

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !!result );

  if( o.usingBools )
  result = filter.filePathArrayGet( result );
  else
  result = filter.filePathArrayNonBoolGet( result, 1 );

  result = result.filter( ( filePath ) => _.strIs( filePath ) && filePath );
  result = result.filter( ( filePath ) => path.isAbsolute( filePath ) );

  if( result && result.length )
  {
    result = path.common( result );
  }
  else if( o.basePath )
  {

    result = o.basePath;

    if( _.mapIs( result ) )
    {
      result = _.mapVals( result );
    }
    else
    {
      result = [ o.basePath ];
    }

    result = result.filter( ( filePath ) => path.isAbsolute( filePath ) );

    if( result && result.length )
    {
      result = path.common( result );
    }
    else
    {
      result = null;
    }

    _.assert( result === null || _.strIs( result ) );
  }
  else result = null;

  if( _.strIs( result ) )
  result = path.fromGlob( path.detrail( result ) );

  _.assert( result === null || path.isAbsolute( result ) );

  return result;
}

prefixPathAbsoluteFrom.defaults =
{
  filePath : null,
  basePath : null,
  usingBools : 0,
}

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
  let basePath = filter.basePathForStemPath( filePath );
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  relativePath = path.relative( basePath, filePath );

  return relativePath;
}

//

function basePathSet( src )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;

  _.assert
  (
    src === null || _.strIs( src ) || _.mapIs( src ),
    () => 'Base path can be null, string or map, but not ' + _.strType( src )
  )

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

/**
 * @summary Returns base path for provided path `filePath`.
 * @param {String|Boolean} filePath Source file path.
 * @function basePathForStemPath
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function basePathForStemPath( filePath )
{
  let filter = this;
  let result = null;

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) )
  return filter.basePath;

  if( _.boolLike( filePath ) )
  {
    if( _.strIs( filter.basePath ) )
    return filter.basePath;
    _.assert( _.mapIs( filter.basePath ) && _.mapKeys( filter.basePath ).length === 1 );
    return _.mapVals( filter.basePath )[ 0 ];
  }

  _.assert( _.mapIs( filter.basePath ) );

  result = filter.basePath[ filePath ];

  // _.assert( result !== undefined, 'No base path for ' + filePath );

  return result;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( _.strIs( filePath ), 'Expects string' );
  _.assert( arguments.length === 1 );

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

function basePathMapFromString( o )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  o = _.routineOptions( basePathMapFromString, arguments );
  _.assert( o.basePath === null || _.strIs( o.basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( o.basePath === null )
  o.basePath = filter.basePath
  if( o.filePath === null )
  o.filePath = filter.prefixPath || filter.filePath;

  o.filePath = filter.filePathArrayNonBoolGet( o.filePath, o.booleanFallingBack ).filter( ( e ) => _.strIs( e ) && e );

  let basePath2 = Object.create( null );

  if( o.basePath )
  {
    for( let s = 0 ; s < o.filePath.length ; s++ )
    {
      let thisFilePath = o.filePath[ s ];
      if( o.prefixingWithFilePath && path.isRelative( o.basePath ) ) // yyy xxx
      basePath2[ thisFilePath ] = path.detrail( path.join( path.fromGlob( thisFilePath ), o.basePath ) );
      else
      basePath2[ thisFilePath ] = o.basePath;
    }
  }
  else
  {
    for( let s = 0 ; s < o.filePath.length ; s++ )
    {
      let thisFilePath = o.filePath[ s ];
      basePath2[ thisFilePath ] = path.fromGlob( thisFilePath );
    }
  }

  if( !o.basePath || _.mapKeys( basePath2 ).length )
  return basePath2;
  else
  return o.basePath;
}

basePathMapFromString.defaults =
{
  filePath : null,
  basePath : null,
  booleanFallingBack : 1,
  prefixingWithFilePath : 0,
}

//

function basePathMapLocalize( basePathMap )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  let basePathMap2 = Object.create( null );
  basePathMap = basePathMap || filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  for( let filePath in basePathMap )
  {
    let basePath = basePathMap[ filePath ];
    _.assert( _.strIs( basePath ) );
    _.assert( _.strIs( filePath ) );
    _.assert( !path.isGlob( basePath ), () => 'Base path should be not glob, but ' + _.strQuote( basePath ) );
    filePath = filter.pathLocalize( filePath );
    basePath = filter.pathLocalize( basePath );
    basePathMap2[ filePath ] = basePath;
  }

  return basePathMap2;
}

//

function basePathFromDecoratedFilePath( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;
  let basePath = Object.create( null );

  if( filePath === undefined )
  filePath = filter.filePath;

  /* */

  path.filterPairs( filePath, ( it ) =>
  {

    if( filter.src )
    {
      if( !_.strIs( it.dst ) )
      return;
      if( !_.strHas( it.dst, '()' ) && !_.strHas( it.dst, '\0' ) )
      return;
      basePath[ path.undot( path.canonize( it.dst ) ) ] = path.fromGlob( it.dst );
    }
    else
    {
      if( !_.strIs( it.src ) )
      return;
      if( !_.strHas( it.src, '()' ) && !_.strHas( it.src, '\0' ) )
      return;
      basePath[ path.undot( path.canonize( it.src ) ) ] = path.fromGlob( it.src );
    }

  });

  return basePath;
}

//

function basePathNormalize( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;
  if( basePath === undefined )
  basePath = filter.basePath;

  _.assert( !_.arrayIs( basePath ) );
  _.assert( arguments.length === 0 || arguments.length === 2 );

  /* */

  if( basePath === null || _.strIs( basePath ) )
  {
    if( basePath )
    basePath = filter.pathLocalize( basePath );
    basePath = filter.basePathMapFromString
    ({
      filePath : filePath,
      basePath : basePath,
      // prefixingWithFilePath : 0,
      prefixingWithFilePath : 1, // yyy
    });
  }
  else if( _.mapIs( basePath ) )
  {
    basePath = filter.basePathMapLocalize( basePath );
  }
  else _.assert( 0 );

  _.assert
  (
       basePath === null
    || _.mapIs( basePath )
    || filter.filePathArrayNonBoolGet( filePath, 1 ).filter( ( e ) => e !== null ).length === 0
  );

  return basePath;
}

//

function basePathSimplest( basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( basePath === undefined )
  basePath = filter.basePath;

  if( !basePath || _.strIs( basePath ) )
  return basePath;

  let vals = _.arrayAppendArrayOnce( [], _.mapVals( basePath ) );

  if( vals.length !== 1 )
  return basePath;
  else if( vals.length === 0 )
  return null;

  basePath = vals[ 0 ];

  return basePath;
}

// xxx : remove maybe?

function basePathDotUnwrap()
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( !filter.basePath )
  return;

  if( _.strIs( filter.basePath ) && filter.basePath !== '.' )
  return;

  if( _.mapIs( filter.basePath ) && !_.mapsAreIdentical( filter.basePath, { '.' : '.' } ) )
  return;

  debugger;
  let filePath = filter.filePathArrayNonBoolGet(); // xxx : booleanFallingBack?

  let basePath = _.mapIs( filter.basePath ) ? filter.basePath : Object.create( null );
  delete basePath[ '.' ];
  filter.basePath = basePath;

  filePath.forEach( ( fp ) => basePath[ fp ] = fp );

}

//

function basePathEach( onEach )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );
  _.assert( arguments.length === 1 );

  /*
  don't use file path neither prefix path
  */

  let basePath = filter.basePath;

  // if( !_.mapIs( basePath ) )
  // {
  //   // basePath = filter.basePathMapFromString( filter.filePath, basePath ); // yyy
  //   basePath = filter.basePathMapFromString( filter.prefixPath || filter.filePath, basePath );
  // }

  // if( _.strIs( basePath ) )
  // {
  //   let r = onEach( '', basePath );
  //   // let r = onEach( null, basePath );
  //   _.assert( r === undefined || _.strIs( r ) || _.mapIs( r ) );
  //   if( r )
  //   basePath = r;
  // }
  // else if( _.mapIs( basePath ) )
  // for( let b in basePath )
  // {
  //   if( b === null )
  //   b = '';
  //   let r = onEach( b, basePath[ b ] );
  //   _.assert( r === undefined || _.mapIs( r ) );
  //   if( r )
  //   {
  //     delete basePath[ b ];
  //     _.mapExtend( basePath, r );
  //   }
  // }
  // else _.assert( 0 );

  basePath = path.filterPairs( basePath, handleEach );

  // filter.basePath = basePath;

  return basePath;

  function handleEach( it )
  {
    if( _.mapIs( basePath ) )
    {
      return onEach( it.src, it.dst );
    }
    else
    {
      _.assert( it.dst === '' );
      return onEach( it.dst, it.src );
    }
  }

}

//

function basePathUse( basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  filter = fileProvider.recordFilter( filter );

  if( filter.basePath || basePath )
  filter.basePath = path.join( basePath || '.', filter.basePath || '.' );

  if( basePath )
  filter.prefixPath = path.s.join( basePath, filter.prefixPath || '.' )

  filter.prefixesApply();

  // if( !filter.basePath && path.s.anyAreGlobal( filter.filePath ) )
  if( !filter.basePath )
  filter.basePath = filter.basePathMapFromString();
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

    if( _.objectIs( o.dstInstance.src ) )
    {
      let fileProvider = o.dstInstance.system || o.dstInstance.effectiveProvider || o.dstInstance.defaultProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( o.value, null );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.dstInstance.src[ filePathSymbol ] !== o.value )
      {
        _.assert( o.dstInstance.src.formed < 5, 'Paired source filter is formed and cant be modified' );
        o.dstInstance.src[ filePathSymbol ] = o.value;
      }
    }
    else if( _.objectIs( o.dstInstance.dst ) )
    {
      let fileProvider = o.dstInstance.system || o.dstInstance.effectiveProvider || o.dstInstance.defaultProvider;
      let path = fileProvider.path;
      if( _.strIs( o.value ) || _.arrayIs( o.value ) || _.boolLike( o.value ) )
      o.value = path.mapsPair( null, o.value );
      _.assert( o.value === null || _.mapIs( o.value ), () => 'Paired filter could have only path map as file path, not ' + _.strType( o.value ) );
      if( o.dstInstance.dst[ filePathSymbol ] !== o.value )
      {
        _.assert( o.dstInstance.dst.formed < 5, 'Paired destination filter is formed and cant be modified' );
        o.dstInstance.dst[ filePathSymbol ] = o.value;
      }
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

// //
//
// function filePathGet()
// {
//   let filter = this;
//   return filter[ filePathSymbol ];
// }
//
// //
//
// function filePathSet( src )
// {
//   let filter = this;
//
//   _.assert( src === null || _.strIs( src ) || _.arrayIs( src ) || _.mapIs( src ) );
//
//   if( filter.src )
//   {
//     let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
//     let path = fileProvider.path;
//     if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
//     src = path.mapsPair( src, null );
//     _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
//     if( src !== filter.src.filePath )
//     filter.src[ filePathSymbol ] = src;
//   }
//   else if( filter.dst )
//   {
//     let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
//     let path = fileProvider.path;
//     if( _.strIs( src ) || _.arrayIs( src ) || _.boolLike( src ) )
//     src = path.mapsPair( null, src );
//     _.assert( src === null || _.mapIs( src ), () => 'Paired filter could have only path map as file path, not ' + _.strType( src ) );
//     if( src !== filter.dst.filePath )
//     filter.dst[ filePathSymbol ] = src;
//   }
//
//   filter[ filePathSymbol ] = src;
//
//   return src;
// }

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
  let fileProvider = src.system || src.effectiveProvider || src.defaultProvider;
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
    dst._formPaths(); // yyy
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
    src._formPaths(); // yyy
    _.assert( dst === null || src.filePath === dst.filePath );
  }
  catch( err )
  {
    debugger;
    throw _.err( 'Failed to form source filter\n', err );
  }

}

//

function filePathNormalize( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 1 );

  if( !_.mapIs( filePath ) )
  filePath = path.mapExtend( null, filePath );

  filePath = path.filterPairsInplace( filePath, ( it ) =>
  {
    if( filter.src )
    {
      if( !_.boolLike( it.dst ) )
      {
        it.dst = path.normalize( it.dst );
        it.dst = filter.pathLocalize( it.dst );
      }
    }
    else
    {
      it.src = path.normalize( it.src );
      it.src = filter.pathLocalize( it.src );
      // it.src = path.globNormalize( it.src );
    }
    return { [ it.src ] : it.dst }
  });

  _.assert( _.mapIs( filePath ) );

  return filePath;
}

//

function filePathPrependByBasePath( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) || basePath === null );

  if( basePath === null )
  return;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( _.mapIs( basePath ) );

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

function filePathFromBasePath( basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;
  let result = Object.create( null );

  _.assert( basePath === '' || basePath === null || _.mapIs( basePath ) || _.strIs( basePath ) );

  if( !basePath )
  return result;

  if( _.strIs( basePath ) )
  {
    if( filter.src )
    result[ '' ] = basePath;
    else
    result[ basePath ] = '';
  }
  else
  {
    if( filter.src )
    {
      for( let f in basePath )
      result[ '' ] = _.scalarAppend( result[ '' ], f );
    }
    else
    {
      for( let f in basePath )
      result[ f ] = '';
    }
  }

  return result;
}

//

function filePathAbsolutize( prefixPath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( _.mapIs( filter.filePath ) );
  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( !prefixPath || path.isAbsolute( prefixPath ) )

  if( prefixPath )
  {
    if( filter.prefixPath )
    filter.prefixesApply({ applyingToTrue : 0, filePathDeducingFromFixes : 0 });
    filter.prefixPath = prefixPath;
    filter.prefixesApply({ applyingToTrue : 0, filePathDeducingFromFixes : 0 });
    return;
  }

  if( _.mapKeys( filter.filePath ).length === 0 )
  return;

  let filePath = filter.filePathArrayGet().filter( ( e ) => _.strIs( e ) && e );

  if( path.s.anyAreRelative( filePath ) )
  {
    if( path.s.anyAreAbsolute( filePath ) )
    filter.filePathMultiplyRelatives( filter.filePath, filter.basePath );
    else
    filter.filePathPrependByBasePath( filter.filePath, filter.basePath );
  }

}

//

/*
Easy optimization. No need to enable slower glob searching if glob is "**".
Result of such glob is equivalent to result of recursive searching.
*/

function filePathGlobSimplify( filePath, basePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;
  if( basePath === undefined )
  basePath = filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( _.mapIs( filePath ) );
  _.assert( !filter.src, 'Not applicable to destination filter, only to source filter' );

  /**/

  // filePath = path.filterPairsInplace( filePath, ( it ) =>
  // {
  //   if( filter.src )
  //   {
  //   }
  //   else
  //   {
  //     let normalized = path.globNormalize( it.src );
  //     if( it.src !== normalized )
  //     if( _.mapIs( basePath ) && basePath[ it.src ] )
  //     {
  //       let base = basePath[ it.src ];
  //       delete basePath[ it.src ];
  //       basePath[ normalized ] = base;
  //     }
  //     it.src = normalized;
  //   }
  //   return { [ it.src ] : it.dst }
  // });

  /**/

  let dst = filter.filePathDstArrayGet();

  if( _.any( dst, ( e ) => _.boolLike( e ) ) )
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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

function filePathNullizeMaybe( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  let filePath2 = filter.filePathDstArrayGet( filePath );
  if( _.any( filePath2, ( e ) => !_.boolLike( e ) ) )
  return filePath;

  return path.filterInplace( filePath, ( e ) => _.boolLike( e ) && e ? '' : e );
}

//

function filePathIsComplex( filePath )
{
  let filter = this;
  let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider;
  let path = fileProvider.path;

  /*
    should use effectiveProvider because of option globbing of file provider
  */

  if( filePath === undefined )
  filePath = filter.filePath;

  if( filePath === '' || filePath === null )
  return false;

  let globFound = true;
  if( _.none( path.s.areGlob( filePath ) ) )
  if( !filter.filePathDstArrayGet( filePath ).filter( ( e ) => _.boolLike( e ) ).length )
  globFound = false;

  return globFound;
}

//

function filePathHasGlob( filePath )
{
  let filter = this;
  let fileProvider = filter.effectiveProvider || filter.system || filter.defaultProvider;
  let path = fileProvider.path;

  /*
    should use effectiveProvider because of option globbing of file provider
  */

  if( filePath === undefined )
  {
    filePath = filter.filePath;
    if( filePath === null )
    filePath = filter.prefixPath;
  }

  if( filePath === '' || filePath === null )
  return false;

  let globFound = true;
  if( _.none( path.s.areGlob( filePath ) ) )
  globFound = false;

  return globFound;
}

//

function filePathDstHasAllBools( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  filePath = filter.filePathDstArrayGet( filePath );

  if( !filePath.length )
  return true;

  return !filePath.filter( ( e ) => !_.boolLike( e ) ).length;
}

//

function filePathDstHasAnyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  filePath = filter.filePathDstArrayGet( filePath );

  return !!filePath.filter( ( e ) => _.boolLike( e ) ).length;
}

//

function filePathMapOnlyBools( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  if( filePath === null || _.strIs( filePath ) || _.arrayIs( filePath ) )
  return {};

  _.assert( arguments.length === 0 || arguments.length === 1 );
  _.assert( _.mapIs( filePath ) );

  let result = Object.create( null );
  for( let src in filePath )
  {
    if( _.boolLike( filePath[ src ] ) )
    result[ src ] = filePath[ src ];
  }

  return result;
}

//

function filePathMap( filePath, booleanFallingBack )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  if( filter.src )
  filePath = path.mapsPair( null, filePath );
  else
  filePath = path.mapsPair( filePath, null );

  if( !booleanFallingBack )
  return filePath;

  if( !filter.filePathDstHasAllBools( filePath ) )
  return filePath;

  for( let src in filePath )
  {
    if( _.boolLike( filePath[ src ] ) && filePath[ src ] )
    filePath[ src ] = '';
  }

  return filePath;
}

//

function filePathDstArrayGet( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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

function filePathDstArrayNonBoolGet( filePath, booleanFallingBack )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  if( booleanFallingBack === undefined )
  booleanFallingBack = false;

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
  if( filePath2.length || !booleanFallingBack )
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

function filePathSrcArrayNonBoolGet( filePath, booleanFallingBack )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  if( booleanFallingBack === undefined )
  booleanFallingBack = false;

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
    if( !r.length && booleanFallingBack )
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

function filePathArrayNonBoolGet( filePath, booleanFallingBack )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

  if( filePath === null )
  return [];

  _.assert( arguments.length === 0 || arguments.length === 1 || arguments.length === 2 );

  if( filter.src )
  return filter.filePathDstArrayNonBoolGet( filePath, booleanFallingBack );
  else
  return filter.filePathSrcArrayNonBoolGet( filePath, booleanFallingBack );

}

//

function filePathDstArrayBoolGet( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
      return filter.prefixPath || filter.basePathForStemPath( p ) || undefined;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;

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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  let filePath = filter.filePathDstNormalizedGet();

  return path.common.apply( path, filePath );
}

//

function filePathSrcCommon()
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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

  if( filter.dst !== dst )
  filter.dst = dst;
  if( dst.src !== filter )
  dst.src = filter;

  return filter;
}

//

function pairRefineLight()
{
  let src = this;
  let dst = src.dst;
  let fileProvider = src.system || src.effectiveProvider || src.defaultProvider;
  let path = fileProvider.path;

  _.assert( dst instanceof Self );
  _.assert( src instanceof Self );
  _.assert( dst.src === src );
  _.assert( src.dst === dst );
  _.assert( arguments.length === 0 );

  if( _.mapIs( src.filePath ) && src.filePath === dst.filePath )
  return;

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
    if( aFilter !== dst || !dst )
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

  if( !filter.effectiveProvider )
  filter.effectiveProvider = filter.defaultProvider;
  if( !filter.system )
  filter.system = filter.effectiveProvider;
  if( filter.system.system )
  filter.system = filter.system.system;

}

//

function providerForPath( filePath )
{
  let filter = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( filter.effectiveProvider )
  return filter.effectiveProvider;

  if( !filePath )
  filePath = filter.filePath;

  if( !filePath )
  filePath = filter.prefixPath;

  if( !filePath )
  filePath = filter.basePath

  _.assert( _.strIs( filePath ), 'Expects string' );

  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;

  filter.effectiveProvider = fileProvider.providerForPath( filePath );

  return filter.effectiveProvider;
}

/**
 * @summary Converts global path into local.
 * @param {String} filePath Input file path.
 * @function prefixesRelative
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function pathLocalize( filePath )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;
  let isGlobal = path.isGlobal( filePath );

  _.assert( _.strIs( filePath ) );

  filePath = path.canonize( filePath );

  if( filter.effectiveProvider && !isGlobal )
  return filePath;

  let effectiveProvider2;

  if( !isGlobal && filter.defaultProvider && !( filter.defaultProvider instanceof _.FileProvider.System ) )
  {
    effectiveProvider2 = filter.defaultProvider
  }
  else
  {
    effectiveProvider2 = fileProvider.providerForPath( filePath );
  }

  _.assert
  (
    filter.effectiveProvider === null || effectiveProvider2 === null || filter.effectiveProvider === effectiveProvider2,
    'Record filter should have paths of single file provider'
  );

  filter.effectiveProvider = filter.effectiveProvider || effectiveProvider2;

  if( filter.effectiveProvider )
  {

    if( !filter.system )
    filter.system = filter.effectiveProvider.system;
    _.assert( filter.effectiveProvider.system === null || filter.system === filter.effectiveProvider.system );
    _.assert( filter.effectiveProvider.system === null || filter.system instanceof _.FileProvider.System );

  }

  if( !isGlobal )
  return filePath;

  _.assert( !path.isTrailed( filePath ) );

  let provider = filter.effectiveProvider || filter.system || filter.defaultProvider;
  let result = provider.path.preferredFromGlobal( filePath );
  return result;
}

//

/**
 * @summary Normalizes path properties of the filter.
 * @function pathsRefine
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function pathsRefine()
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;
  let originalFilePath = filter.filePath;

  _.assert( arguments.length === 0 );
  _.assert( filter.formed === 2 );
  _.assert( filter.basePath === null || _.strIs( filter.basePath ) || _.mapIs( filter.basePath ) );

  filter.prefixesApply({ booleanFallingBack : 1 });

  _.assert( filter.prefixPath === null, 'Prefixes should be applied so far' );
  _.assert( filter.postfixPath === null, 'Posftixes should be applied so far' );

  let prefix = filter.prefixPathAbsoluteFrom();
  if( prefix )
  prefix = filter.pathLocalize( prefix );

  let basePath = filter.basePathFromDecoratedFilePath( filter.filePath );

  filter.filePath = filter.filePathNormalize( filter.filePath );
  _.assert( _.mapIs( filter.filePath ) );
  if( _.mapKeys( filter.filePath ).length === 0 )
  {
    let filePath = filter.filePathFromBasePath( filter.basePath );
    _.assert( _.mapIs( filePath ) )
    if( _.mapKeys( filePath ).length !== 0 )
    filter.filePath = filePath;
  }

  if( !filter.src || filter.basePath )
  filter.basePath = filter.basePathNormalize( filter.filePath, filter.basePath );

  if( _.mapKeys( basePath ).length )
  {
    _.assert( filter.basePath === null || _.mapIs( filter.basePath ) );
    basePath = path.filterPairs( basePath, ( it ) =>
    {
      let b = path.join( filter.basePathForStemPath( it.src ) || '', it.dst );
      return { [ it.src ] : b }
    });
    filter.basePath = _.mapExtend( filter.basePath, basePath );
  }

  filter.filePathAbsolutize( prefix );
  filter.providersNormalize();

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

  if( !filter.effectiveProvider )
  return;

  if( filter.basePath )
  filter.basePath = filter.effectiveProvider.globalsFromLocals( filter.basePath );

  if( filter.filePath )
  filter.filePath = filter.effectiveProvider.globalsFromLocals( filter.filePath );

}

// --
// iterative
// --

function allPaths( o )
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
    let result = o.inplace ? path.filterInplace( thePath, o.onEach ) : path.filter( thePath, o.onEach );
    if( o.inplace )
    filter[ fieldName ] = result;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  if( filePath === undefined )
  filePath = filter.filePath;
  if( basePath === undefined )
  basePath = filter.basePath;

  _.assert( arguments.length === 0 || arguments.length === 2 );
  _.assert( !_.arrayIs( basePath ) );

  if( !basePath || _.strIs( basePath ) )
  return;

  basePath = _.mapKeys( basePath );
  let originalBasePath = basePath.slice();
  basePath = path.s.join( filter.prefixPath || '', basePath );
  basePath = path.s.fromGlob( basePath );

  // let filePathWithFallback = filter.filePathArrayNonBoolGet( filePath, 1 );
  let originalFilePath = _.entityShallowClone( filePath );
  filePath = filter.filePathArrayNonBoolGet( filePath, 0 );
  filePath = filePath.filter( ( e ) => _.strIs( e ) && e );
  filePath = path.s.join( filter.prefixPath || '', filePath );
  if( !filePath.length && basePath.length && filter.prefixPath )
  filePath = _.arrayAs( filter.prefixPath || '' );

  if( !filePath.length )
  {
    filePath = filePathFromPrefix();
  }

  // if( !filePath.length && basePath.length )
  // {
  //   filePath = filter.filePathArrayNonBoolGet( originalFilePath, 1 );
  //   filePath = filePath.filter( ( e ) => _.strIs( e ) && e );
  //   filePath = path.s.join( filter.prefixPath || '', filePath );
  // }

  filePath = path.s.fromGlob( filePath );

  let diff = _.arraySetDiff( basePath, filePath );
  if( diff.length !== 0 )
  {
    debugger;
    let fileWithoutBasePath = _.arraySetBut( filePath.slice(), basePath );
    let baseWithoutFilePath = _.arraySetBut( basePath.slice(), filePath );
    let err = 'Each file path should have base path';
    if( fileWithoutBasePath.length )
    err += '\nFile path without base path : ' + _.strQuote( fileWithoutBasePath );
    if( baseWithoutFilePath.length )
    err += '\nBase path without file path : ' + _.strQuote( baseWithoutFilePath );
    err += '\nBase path : ' + _.strQuote( basePath );
    err += '\nFile path : ' + _.strQuote( filePath );

    debugger;
    throw _.err( err );
  }

  _.sure( diff.length === 0, () => 'Some file paths do not have base paths or opposite : ' + _.strQuote( diff ) );

  for( let g in basePath )
  {
    _.sure
    (
      !path.isGlob( basePath[ g ] ),
      () => 'Base path should not be glob, but base path ' + _.strQuote( basePath[ g ] ) + ' for file path ' + _.strQuote( g ) + ' is glob'
    );
  }

  function filePathFromPrefix()
  {
    let filePath = filter.filePathArrayNonBoolGet( originalFilePath, 1 );
    filePath = filePath.filter( ( e ) => _.strIs( e ) && e );
    filePath = path.s.join( filter.prefixPath || '', filePath );
    return filePath;
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

//

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

// --
// exporter
// --

function moveTextualReport()
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
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
    result += '\n' + '  ' + fieldName + ' :\n' + _.toJs( filter[ fieldName ], { levels : 2 } );
  }

  return result;
}

// --
// checker
// --

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
  if( filePath[ 0 ] === '' || filePath[ 0 ] === null ) // xxx
  {
    return false;
  }

  // if( filePath.length === 1 )
  // if( filePath[ 0 ] === '.' || filePath[ 0 ] === '' || filePath[ 0 ] === null ) // xxx
  // {
  //   /*
  //   exception for dst filter
  //   actually, exception for src filter
  //   */
  //   if( filter.src )
  //   if( filePath[ 0 ] === '.' ) // xxx
  //   return true;
  //   return false;
  // }

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
// mask
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
 * @function masksGenerate
 * @memberof module:Tools/mid/Files.wFileRecordFilter#
*/

function masksGenerate()
{
  let filter = this;
  let fileProvider = filter.system || filter.effectiveProvider || filter.defaultProvider;
  let path = fileProvider.path;

  _.assert( arguments.length === 0 );

  if( filter.src )
  {
    copy( path.s.fromGlob( filter.filePath ), path.s.fromGlob( filter.basePath || {} ) );
    return;
  }

  let filePath = filter.filePath;
  let basePath = filter.basePath;
  let globFound = filter.filePathIsComplex( filePath );
  if( !globFound )
  {
    copy( filePath, basePath );
    return;
  }

  _.assert( !filter.src );
  let filePath2 = _.mapExtend( null, filePath );
  let basePath2 = _.mapExtend( null, basePath );
  filter.filePathGlobSimplify( filePath2, basePath2 );
  if( !_.entityIdentical( filePath2, filePath ) )
  {
    globFound = filter.filePathIsComplex( filePath2 );
  }

  if( !globFound )
  {
    copy( filePath2, basePath2 );
    return;
  }

  _.assert( !filter.src );
  _.assert( filter.formedFilterMap === null );
  filter.formedFilterMap = Object.create( null );

  // debugger;
  let _processed = path.pathMapToRegexps( filePath2, basePath2  );
  // debugger;

  // filter.formedBasePath = _processed.unglobedBasePath;
  // filter.formedFilePath = _processed.unglobedFilePath;

  if( filter.recursive === 2 )
  {
    filter.formedBasePath = _processed.optimizedUnglobedBasePath;
    filter.formedFilePath = _processed.optimizedUnglobedFilePath;
  }
  else
  {
    filter.formedBasePath = _processed.unglobedBasePath;
    filter.formedFilePath = _processed.unglobedFilePath;
  }

  filter.assertBasePath( filter.formedFilePath, filter.formedBasePath );

  let regexpsMap = filter.recursive === 2 ? _processed.optimalRegexpsMap : _processed.regexpsMap;
  for( let stemPath in regexpsMap )
  masksSet( stemPath, regexpsMap[ stemPath ], filter.formedFilterMap );

  end();

  /* */

  function masksSet( stemPath, regexps, dstMap )
  {

    let basePath = filter.formedBasePath[ stemPath ];
    _.assert( _.strDefined( basePath ), 'No base path for', stemPath );
    // let relative = stemPath;
    // let regexps = _processed.optimalRegexpsMap[ stemPath ];
    _.assert( !dstMap[ stemPath ] );
    let subfilter = dstMap[ stemPath ] = Object.create( null );

    // subfilter.maskAll = _.RegexpObject.Extend( filter.maskAll.clone(), { includeAll : regexps.actualAll, includeAny : regexps.actualAny, excludeAny : regexps.actualNone } );
    // subfilter.maskTerminal = filter.maskTerminal.clone();
    // subfilter.maskDirectory = filter.maskDirectory.clone();

    // debugger;
    subfilter.maskAll = filter.maskAll.clone().extend
    ({
      includeAll : regexps.actualAll,
      includeAny : regexps.actualAny,
      excludeAny : regexps.actualNone,
    });
    subfilter.maskTerminal = filter.maskTerminal.clone();
    subfilter.maskDirectory = filter.maskDirectory.clone();

    // subfilter.maskTerminal = filter.maskTerminal.clone().extend
    // ({
    //   includeAny : regexps.actualAny2,
    // });
    // subfilter.maskDirectory = filter.maskDirectory.clone().extend
    // ({
    //   includeAny : regexps.actualAny2,
    // });

    subfilter.maskTransientAll = filter.maskTransientAll.clone();
    subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone().extend
    ({
      includeAny : /$_^/
    });
    subfilter.maskTransientDirectory = filter.maskTransientDirectory.clone().extend
    ({
      includeAny : regexps.transient
    });

    // subfilter.maskTransientTerminal = _.RegexpObject.Extend( filter.maskTransientTerminal.clone(), { includeAny : /$_^/ } );
    // // subfilter.maskTransientTerminal = filter.maskTransientTerminal.clone(); // zzz
    // // subfilter.maskTransientDirectory = _.RegexpObject.Extend( filter.maskTransientDirectory.clone(), { includeAny : regexps.transient } ); // yyy
    // subfilter.maskTransientDirectory = _.RegexpObject.Extend( filter.maskTransientDirectory.clone(), { includeAll : regexps.transient } );

    regexps.actualNone.forEach( ( none ) =>
    {
      let certainly = regexps.certainlyHash.get( none );
      if( certainly )
      subfilter.maskTransientDirectory.excludeAny.push( certainly );
    });

    // regexps.actualAll.forEach( ( none ) =>
    // {
    //   let certainly = regexps.certainlyHash.get( none );
    //   if( certainly )
    //   subfilter.maskTransientDirectory.excludeAny.push( certainly );
    // });

    _.assert( subfilter.maskAll !== filter.maskAll );

  }

  /* */

  function copy( filePath, basePath )
  {

    /* if base path is redundant then return empty map */
    if( _.mapIs( basePath ) )
    filter.formedBasePath = _.entityShallowClone( basePath );
    else
    filter.formedBasePath = Object.create( null );
    filter.formedFilePath = _.entityShallowClone( filePath );

    end();
  }

  /* */

  function end()
  {
    if( filter.src && filter.src.formed < 5 && filter.src.formedFilePath )
    filter.src.formedFilePath = filter.formedFilePath;
    if( filter.dst && filter.dst.formed < 5 && filter.dst.formedFilePath )
    filter.dst.formedFilePath = filter.formedFilePath;
  }

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
  let masks = filter;
  masks = filter.formedFilterMap ? filter.formedFilterMap[ f.stemPath ] : filter;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!masks, 'Cant resolve filter map for stem path', () => _.strQuote( f.stemPath ) );
  _.assert( !!f.formed, 'Record factor was not formed!' );

  // debugger;
  if( _.strEnds( record.absolute, '-ile' ) )
  debugger;
  // if( _.strEnds( record.absolute, 'proto' ) )
  // debugger;
  // if( _.strEnds( record.absolute, 'proto/f.js' ) )
  // debugger;
  // if( _.strHas( record.absolute, 'dir2' ) )
  // debugger;

  /* */

  if( record.isDir )
  {

    if( record.isTransient && masks.maskTransientAll )
    record[ isTransientSymbol ] = masks.maskTransientAll.test( relative );
    if( record.isTransient && masks.maskTransientDirectory )
    record[ isTransientSymbol ] = masks.maskTransientDirectory.test( relative );

    if( record.isActual && masks.maskAll )
    record[ isActualSymbol ] = masks.maskAll.test( relative );
    if( record.isActual && masks.maskDirectory )
    record[ isActualSymbol ] = masks.maskDirectory.test( relative );

  }
  else
  {

    if( record.isActual && masks.maskAll )
    record[ isActualSymbol ] = masks.maskAll.test( relative );
    if( record.isActual && masks.maskTerminal )
    record[ isActualSymbol ] = masks.maskTerminal.test( relative );

    if( record.isTransient && masks.maskTransientAll )
    record[ isTransientSymbol ] = masks.maskTransientAll.test( relative );
    if( record.isTransient && masks.maskTransientTerminal )
    record[ isTransientSymbol ] = masks.maskTransientTerminal.test( relative );

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
  recursive : null,

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
  effectiveProvider : null,
  defaultProvider : null,
  system : null,
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
  // TolerantFrom,
  And,
  MaskNames,
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
  hubFileProvider : 'hubFileProvider',
  effectiveFileProvider : 'effectiveFileProvider',
  defaultFileProvider : 'defaultFileProvider',

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

  // TolerantFrom,
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

  // combiner

  And,
  and,

  // _pathsJoin, /* xxx : deprecate maybe? */
  // pathsJoin, /* xxx : deprecate maybe? */
  // pathsJoinWithoutNull, /* xxx : deprecate maybe? */
  // pathsSupplementJoining, /* xxx : deprecate maybe? */
  // pathsSupplementJoining : pathsSupplementJoining,

  _pathsAmmend,
  pathsExtend,
  pathsExtendJoining,
  pathsSupplement,
  pathsSupplementJoining,

  // prefix path

  prefixesApply,
  prefixesRelative,
  prefixPathFromFilePath,
  prefixPathAbsoluteFrom,

  // base path

  relativeFor,
  basePathSet,
  basePathForStemPath,
  basePathForFilePath,
  basePathsGet,
  basePathMapFromString,
  basePathMapLocalize,
  basePathFromDecoratedFilePath,
  basePathNormalize,
  basePathSimplest, /* qqq : cover routine basePathSimplest */
  basePathDotUnwrap,
  basePathEach, /* qqq : cover routine basePathEach */
  basePathUse,

  // file path

  filePathCopy,
  // filePathGet,
  // filePathSet,

  filePathSelect,
  filePathNormalize,
  filePathPrependByBasePath, /* qqq : cover it */
  filePathMultiplyRelatives,
  filePathFromBasePath,
  filePathAbsolutize, /* qqq : cover it */
  filePathGlobSimplify,
  filePathFromFixes,
  filePathSimplest,
  filePathNullizeMaybe,
  filePathIsComplex, /* qqq : good coverage needed */
  filePathHasGlob, /* qqq : simple coverage needed */

  filePathDstHasAllBools,
  filePathDstHasAnyBools,
  filePathMapOnlyBools,
  filePathMap,

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
  pairWithDst,
  pairRefineLight,
  isPaired,

  // etc

  filteringClear,
  providersNormalize,
  providerForPath,

  pathLocalize,
  pathsRefine,
  globalsFromLocals,

  // iterative

  allPaths,
  isRelative,
  sureRelative,
  sureRelativeOrGlobal,
  sureBasePath,
  assertBasePath,

  // exporter

  moveTextualReport,
  compactField,
  toStr,

  // checker

  hasMask,
  hasFiltering,
  hasAnyPath,
  hasData,

  // mask

  maskExtensionApply,
  maskBeginsApply,
  maskEndsApply,
  masksGenerate,

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

_.mapExtend( _, Globals );

// _.Copyable.mixin( Self );

// --
// export
// --

_[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
