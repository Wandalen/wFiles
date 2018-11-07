( function _Npm_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{
  let _global = _global_;
  let _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

}

let _global = _global_;
let _ = _global_.wTools;
// let Npm;

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

  // if( !Npm )
  // Npm = require( 'simple-git/promise' );
  //
  // if( !NpmConfig )
  // NpmConfig = require( 'gitconfiglocal' );

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

function _filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assertRoutineOptions( _filesReflectSingle_body, o );
  _.assert( o.mandatory === undefined )
  _.assert( arguments.length === 1, 'expects single argument' );

  /* */

  o.dstFilter.inFilePath = o.dstPath;
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
  _.sure( !o.srcFilter || o.srcFilter.isEmpty(), 'Does not support filtering, but {o.srcFilter} is not empty' );
  _.sure( !o.dstFilter || o.dstFilter.isEmpty(), 'Does not support filtering, but {o.dstFilter} is not empty' );
  _.sure( !o.filter || o.filter.isEmpty(), 'Does not support filtering, but {o.filter} is not empty' );

  /* log */

  logger.log( '' );
  logger.log( 'srcPath', srcPath );
  logger.log( 'srcStrippedPath', srcStrippedPath );
  logger.log( 'dstPath', dstPath );
  logger.log( '' );

  /* */

  let result = [];
  let shell = _.sheller
  ({
    verbosity : 1,
  });

  if( !dstFileProvider.fileExists( path.dir( dstPath ) ) )
  dstFileProvider.directoryMake( path.dir( dstPath ) );

  let exists = dstFileProvider.fileExists( dstPath );
  let directoryIs = dstFileProvider.directoryIs( dstPath );
  if( exists && !directoryIs )
  throw occupiedErr;

  if( exists )
  {
    if( dstFileProvider.directoryRead( dstPath ).length === 0 )
    {
      dstFileProvider.fileDelete( dstPath );
      exists = false;
    }
  }

  if( !exists )
  {

    let tmpPath = dstPath + '-' + _.idWithGuid();
    let tmpEssentialPath = path.join( tmpPath, 'node_modules', srcPath );
    result = shell( 'npm install -g --prefix ' + dstFileProvider.path.nativize( tmpPath ) + ' ' + srcPath )
    result.ifNoErrorThen( () => dstFileProvider.fileRename( dstPath, tmpEssentialPath ) )
    result.ifNoErrorThen( () => dstFileProvider.fileDelete( path.dir( tmpEssentialPath ) ) )
    result.ifNoErrorThen( () => dstFileProvider.fileDelete( path.dir( path.dir( tmpEssentialPath ) ) ) )

    /* handle error if any */

    result
    .doThen( function( err, arg )
    {
      if( err )
      throw _.err( err );
      return [];
    });

  }
  else
  {
    let packageFilePath = path.join( dstPath, 'package.json' );
    if( !dstFileProvider.terminalIs( packageFilePath ) )
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
  }

  return result;

  /* */

  function occupiedErr()
  {
    return _.err( 'Cant download NPM package to', _.strQuote( dstPath ), 'it is occupied' )
  }

}

_.routineExtend( _filesReflectSingle_body, _.FileProvider.Find.prototype.filesReflectSingle );

var defaults = _filesReflectSingle_body.defaults;

let filesReflectSingle = _.routineFromPreAndBody( _.FileProvider.Find.prototype.filesReflectSingle.pre, _filesReflectSingle_body );

// --
// relationship
// --

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'npm' ]),

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

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
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
