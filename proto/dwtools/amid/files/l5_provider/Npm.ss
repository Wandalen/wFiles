( function _Npm_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../Tools.s' );
  if( !_.FileProvider )
  require( '../UseMid.s' );
}

let _global = _global_;
let _ = _global_.wTools;

//

let Parent = _.FileProvider.Partial;
let Self = function wFileProviderNpm( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Npm';

_.assert( !_.FileProvider.Npm );

// --
// inter
// --

function finit()
{
  let self = this;
  if( self.claimMap )
  self.claimEnd();
  Parent.prototype.finit.call( self );
}

//

function init( o )
{
  let self = this;
  Parent.prototype.init.call( self,o );
}

// --
// path
// --

function localFromGlobal( uri )
{
  let self = this;
  let path = self.path;
  return path.str( uri );
}

//

function pathIsolateGlobalAndLocal( longPath )
{
  let self = this;
  let path = self.path;
  return [ longPath, '' ]
}

//

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assertRoutineOptions( filesReflectSingle_body, o );
  _.assert( o.mandatory === undefined )
  _.assert( arguments.length === 1, 'Expects single argument' );

  _.assert( _.routineIs( o.onUp ) && o.onUp.composed && o.onUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onDown ) && o.onDown.composed && o.onDown.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteDstUp ) && o.onWriteDstUp.composed && o.onWriteDstUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteDstDown ) && o.onWriteDstDown.composed && o.onWriteDstDown.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteSrcUp ) && o.onWriteSrcUp.composed && o.onWriteSrcUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteSrcDown ) && o.onWriteSrcDown.composed && o.onWriteSrcDown.composed.elements.length === 0, 'Not supported options' );
  _.assert( o.outputFormat === 'record' || o.outputFormat === 'nothing', 'Not supported options' );
  _.assert( o.linking === 'fileCopy' || o.linking === 'hardLinkMaybe' || o.linking === 'softLinkMaybe', 'Not supported options' );
  _.assert( !o.srcFilter.hasFiltering(), 'Not supported options' );
  _.assert( !o.dstFilter.hasFiltering(), 'Not supported options' );
  _.assert( o.srcFilter.formed === 5 );
  _.assert( o.dstFilter.formed === 5 );
  _.assert( o.srcFilter.stemPath === o.srcPath );
  _.assert( o.dstFilter.stemPath === o.dstPath );
  _.assert( o.filter === null || !o.filter.hasFiltering(), 'Not supported options' );
  _.assert( !!o.recursive, 'Not supported options' );

  // o.onWriteDstUp = _.routinesCompose( o.onWriteDstUp );
  // o.onWriteDstDown = _.routinesCompose( o.onWriteDstDown );
  // o.onWriteSrcUp = _.routinesCompose( o.onWriteSrcUp );
  // o.onWriteSrcDown = _.routinesCompose( o.onWriteSrcDown );
  //
  // if( !_.arrayIs( o.onUp ) )
  // o.onUp = o.onUp ? [ o.onUp ] : [];
  // if( !_.arrayIs( o.onDown ) )
  // o.onDown = o.onDown ? [ o.onDown ] : [];
  // if( o.result === null )
  // o.result = [];

  defaults.dstRewriting = 1;
  defaults.dstRewritingByDistinct = 1;
  defaults.dstRewritingPreserving = 0;

  /* */

  // o.dstFilter.inFilePath = o.dstPath;
  let dstFileProvider = o.dstFilter.determineEffectiveFileProvider();
  let srcPath = o.srcPath;
  let dstPath = o.dstPath;

  if( _.mapIs( srcPath ) )
  {
    _.assert( _.mapVals( srcPath ).length === 1 );
    _.assert( _.mapVals( srcPath )[ 0 ] === true );
    srcPath = _.mapKeys( srcPath )[ 0 ];
  }

  let srcCurrentPath, parsed;
  let srcOriginalPath = srcPath;
  let srcParsed = path.parseConsecutive( srcPath );
  srcParsed.hash = srcParsed.hash || 'master';

  parsed = _.mapExtend( null, srcParsed );
  parsed.protocol = null;
  parsed.hash = null;
  let srcStrippedPath = path.str( parsed );

  parsed = _.mapExtend( null, srcParsed );
  parsed.protocols = null;
  parsed.protocol = null;
  parsed.hash = null;
  srcPath = path.relative( '/', path.str( parsed ) );

  /* */

  _.sure( _.strIs( srcPath ) );
  _.sure( _.strIs( dstPath ) );
  _.sure( dstFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );
  _.sure( !o.srcFilter || !o.srcFilter.hasFiltering(), 'Does not support filtering, but {o.srcFilter} is not empty' );
  _.sure( !o.dstFilter || !o.dstFilter.hasFiltering(), 'Does not support filtering, but {o.dstFilter} is not empty' );
  _.sure( !o.filter || !o.filter.hasFiltering(), 'Does not support filtering, but {o.filter} is not empty' );

  /* log */

  // logger.log( '' );
  // logger.log( 'srcPath', srcPath );
  // logger.log( 'srcStrippedPath', srcStrippedPath );
  // logger.log( 'dstPath', dstPath );
  // logger.log( '' );

  /* */

  let result = [];
  let shell = _.sheller
  ({
    verbosity : o.verbosity >= 3 ? 1 : 0,
  });

  if( !dstFileProvider.fileExists( path.dir( dstPath ) ) )
  dstFileProvider.dirMake( path.dir( dstPath ) );

  let exists = dstFileProvider.fileExists( dstPath );
  let isDir = dstFileProvider.isDir( dstPath );
  if( exists && !isDir )
  throw occupiedErr;

  if( exists )
  {
    if( dstFileProvider.dirRead( dstPath ).length === 0 )
    {
      dstFileProvider.fileDelete( dstPath );
      exists = false;
    }
  }

  if( !exists )
  {

    let tmpPath = dstPath + '-' + _.idWithGuid();
    let tmpEssentialPath = path.join( tmpPath, 'node_modules', srcPath );
    result = shell( 'npm install --prefix ' + dstFileProvider.path.nativize( tmpPath ) + ' ' + srcPath )
    result.ifNoErrorThen( ( arg ) => dstFileProvider.fileRename( dstPath, tmpEssentialPath ) );
    result.ifNoErrorThen( ( arg ) => dstFileProvider.fileDelete( path.dir( tmpEssentialPath ) ) || null );
    result.ifNoErrorThen( ( arg ) => dstFileProvider.fileDelete( path.dir( path.dir( tmpEssentialPath ) ) ) || null );

    /* handle error if any */

    result
    .finally( function( err, arg )
    {
      if( err )
      throw _.err( err );
      debugger;
      return recordsMake();
    });

  }
  else
  {
    let packageFilePath = path.join( dstPath, 'package.json' );
    if( !dstFileProvider.isTerminal( packageFilePath ) )
    throw occupiedErr();
    try
    {
      let read = dstFileProvider.fileRead({ filePath : packageFilePath, encoding : 'json' });
      if( !read || read.name !== srcPath )
      throw _.err( occupiedErr );
    }
    catch( err )
    {
      throw _.err( occupiedErr, err );
    }
    result = recordsMake();
  }

  return result;

  /* */

  function recordsMake()
  {
    /* xxx : fast solution to return some records instead of empty arrray */
    o.result = dstFileProvider.filesReflectEvaluate
    ({
      srcPath : dstPath,
      dstPath : dstPath,
    });
    return o.result;
  }

  /* */

  function occupiedErr()
  {
    return _.err( 'Cant download NPM package to', _.strQuote( dstPath ), 'it is occupied' )
  }

}

_.routineExtend( filesReflectSingle_body, _.FileProvider.Find.prototype.filesReflectSingle );

var defaults = filesReflectSingle_body.defaults;

let filesReflectSingle = _.routineFromPreAndBody( _.FileProvider.Find.prototype.filesReflectSingle.pre, filesReflectSingle_body );

// --
// relationship
// --

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'npm' ]),

  resolvingSoftLink : 0,
  resolvingTextLink : 0,
  limitedImplementation : 1,

}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
  // claimMap : _.define.own({}),
  // claimProvider : null,
}

let Statics =
{
  Path : _.uri.CloneExtending({ fileProvider : Self }),
}

let Forbids =
{
}

// --
// declare
// --

let Proto =
{

  finit : finit,
  init : init,

  // path

  localFromGlobal : localFromGlobal,
  pathIsolateGlobalAndLocal : pathIsolateGlobalAndLocal,

  // etc

  filesReflectSingle : filesReflectSingle,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,
  Forbids : Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

//

_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
{ /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
