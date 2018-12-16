( function _Git_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../Tools.s' );
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let GitConfig;

//

let Parent = _.FileProvider.Partial;
let Self = function wFileProviderGit( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Git';

_.assert( !_.FileProvider.Git );

// --
// inter
// --

function finit()
{
  let self = this;
  Parent.prototype.finit.call( self );
}

//

function init( o )
{
  let self = this;

  if( !GitConfig )
  GitConfig = require( 'gitconfiglocal' );

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

function pathIsolateGlobalAndLocal( filePath )
{
  let self = this;
  let path = self.path;

  let parsed = path.parseConsecutive( filePath );
  let splits = _.strIsolateBeginOrAll( parsed.longPath, '.git/' );

  parsed.longPath = splits[ 0 ] + splits[ 1 ];

  let globalPath = path.str( parsed );

  return [ globalPath, splits[ 2 ] ]
}

//

function pathParse( remotePath )
{
  let self = this;
  let path = self.path;
  let result = Object.create( null );

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( remotePath ) );
  _.assert( path.isGlobal( remotePath ) )

  let parsed1 = path.parseConsecutive( remotePath );
  parsed1.hash = parsed1.hash || 'master';
  parsed1.longPath = self.pathIsolateGlobalAndLocal( parsed1.longPath )[ 0 ];

  /* */

  let parsed2 = _.mapExtend( null, parsed1 );
  parsed2.protocol = null;
  parsed2.hash = null;
  parsed2.longPath = _.strRemoveBegin( parsed2.longPath, '/' )
  result.stripped = path.str( parsed2 );

  /* */

  let parsed3 = _.mapExtend( null, parsed1 );
  parsed3.protocols = parsed3.protocol ? parsed3.protocol.split( '+' ) : [];
  if( parsed3.protocols.length > 0 && parsed3.protocols[ 0 ].toLowerCase() === 'git' )
  {
    parsed3.protocols.splice( 0,1 );
    parsed3.longPath = _.strRemoveBegin( parsed3.longPath, '/' )
  }
  parsed3.protocol = null;
  parsed3.hash = null;
  result.compact = path.str( parsed3 );

  /* */

  _.mapExtend( result, parsed1 );

  return result
}

//

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;
  let con2 = new _.Consequence();

  o.extra = o.extra || Object.create( null );
  _.routineOptions( filesReflectSingle_body, o.extra, filesReflectSingle_body.extra );

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

  /* */

  let dstFileProvider = o.dstFilter.determineEffectiveFileProvider();
  let srcPath = o.srcPath;
  let dstPath = o.dstPath;
  let srcCurrentPath;

  if( _.mapIs( srcPath ) )
  {
    _.assert( _.mapVals( srcPath ).length === 1 );
    _.assert( _.mapVals( srcPath )[ 0 ] === true );
    srcPath = _.mapKeys( srcPath )[ 0 ];
  }

  let paths = self.pathParse( srcPath );

  /* */

  _.sure( _.strDefined( paths.stripped ) );
  _.sure( _.strDefined( paths.compact ) );
  _.sure( _.strDefined( paths.hash ) );
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

  // console.log( 'filesReflectSingle', o.verbosity );

  let result = _.Consequence().take( null );
  let shell = _.sheller
  ({
    verbosity : o.verbosity - 2,
    con : result,
    currentPath : dstPath,
  });

  let shellAll = _.sheller
  ({
    verbosity : o.verbosity - 2,
    con : result,
    currentPath : dstPath,
    throwingExitCode : 0,
    outputCollecting : 1,
  });

  if( !dstFileProvider.fileExists( dstPath ) )
  dstFileProvider.dirMake( dstPath );

  let gitConfigExists = dstFileProvider.fileExists( path.join( dstPath, '.git' ) );

  /* already have repository here */

  if( gitConfigExists )
  result
  .got( () => GitConfig( dstFileProvider.path.nativize( dstPath ), result.tolerantCallback() ) )
  .ifNoErrorThen( function( arg )
  {

    _.sure
    (
      !!arg.remote && !!arg.remote.origin && _.strIs( arg.remote.origin.url ),
      'GIT config does not have {-remote.origin.url-}'
    );

    srcCurrentPath = arg.remote.origin.url;

    _.sure
    (
      _.strEnds( srcCurrentPath, paths.stripped ),
      () => 'GIT repository at directory ' + _.strQuote( dstPath ) + '\n' +
      'Has origin ' + _.strQuote( srcCurrentPath ) + '\n' +
      'Should have ' + _.strQuote( paths.compact )
    );

    return arg || null;
  });

  /* no repository yet */

  if( !gitConfigExists )
  {
    if( !dstFileProvider.fileExists( path.join( dstPath, '.git' ) ) )
    shell( 'git clone ' + paths.compact + ' ' + '.' );
  }
  else
  {
    if( o.extra.fetching )
    shell( 'git fetch origin' );
  }

  let localChanges = false;
  if( gitConfigExists )
  {
    shellAll
    ([
      'git status',
    ]);
    result
    .ifNoErrorThen( function( arg )
    {
      _.assert( arg.length === 2 );
      localChanges = _.strHas( arg[ 0 ].output, 'Changes to be committed' );
      return localChanges;
    })
  }

  /* stash changes and checkout branch/commit */

  // result.except( con2 ); // xxx qqq !!!
  result.except( ( err ) =>
  {
    con2.error( err );
  });

  result.ifNoErrorThen( ( arg ) =>
  {

    if( localChanges )
    shell( 'git stash' );
    shell( 'git checkout ' + paths.hash );
    if( paths.hash.length < 7 || !_.strIsHex( paths.hash ) ) /* qqq : probably does not work for all cases */
    shell( 'git merge' );
    if( localChanges )
    shell({ path : 'git stash pop', throwingExitCode : 0 });

    result.finally( con2 );

    return arg;
  });

  /* handle error if any */

  con2
  .finally( function( err, arg )
  {
    if( err )
    throw _.err( err );
    return recordsMake();
  });

  return con2;

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

}

_.routineExtend( filesReflectSingle_body, _.FileProvider.Find.prototype.filesReflectSingle );

var extra = filesReflectSingle_body.extra = Object.create( null );

extra.fetching = 1;

var defaults = filesReflectSingle_body.defaults;

let filesReflectSingle = _.routineFromPreAndBody( _.FileProvider.Find.prototype.filesReflectSingle.pre, filesReflectSingle_body );

//

function isUpToDate( o )
{
  let self = this;
  let path = self.path;

  _.routineOptions( isUpToDate, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  // console.log( 'isUpToDate:begin' );

  let srcCurrentPath;
  let dstFileProvider = self.hub.providerForPath( o.localPath );
  let paths = self.pathParse( o.remotePath );
  let result = _.Consequence().take( null );

  let shell = _.sheller
  ({
    verbosity : o.verbosity - 2,
    // verbosity : 2,
    con : result,
    currentPath : o.localPath,
  });

  let shellAll = _.sheller
  ({
    verbosity : o.verbosity - 2,
    // verbosity : 2,
    con : result,
    currentPath : o.localPath,
    throwingExitCode : 0,
    outputCollecting : 1,
  });

  _.assert( dstFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  if( !dstFileProvider.fileExists( o.localPath ) )
  return false;

  let gitConfigExists = dstFileProvider.fileExists( path.join( o.localPath, '.git' ) );

  if( !gitConfigExists )
  return false;

  if( gitConfigExists )
  result
  .got( () => GitConfig( dstFileProvider.path.nativize( o.localPath ), result.tolerantCallback() ) )
  .ifNoErrorThen( function( arg )
  {
    if( !arg.remote || !arg.remote.origin || !_.strIs( arg.remote.origin.url ) )
    return false;

    srcCurrentPath = arg.remote.origin.url;

    if( !_.strEnds( srcCurrentPath, paths.stripped ) )
    return false;

    return true;
  });

  shell( 'git fetch origin' );

  result.finally( ( err, arg ) =>
  {
    // console.log( 'isUpToDate:1' );
    if( err )
    throw _.err( err );
    return null;
  });

  shellAll
  ([
    // 'git diff origin/master --quiet --exit-code',
    // 'git diff --quiet --exit-code',
    // 'git branch -v',
    'git status',
  ]);

  result
  .ifNoErrorThen( function( arg )
  {
    _.assert( arg.length === 2 );

    // self.logger.log( o.remotePath, arg[ 0 ].output );

    let result = !_.strHas( arg[ 0 ].output, 'Your branch is behind' );

    if( o.verbosity )
    self.logger.log( o.remotePath, result ? 'is up to date' : 'is not up to date' );

    return result;
  })
  // .ifNoErrorThen( function( arg )
  // {
  //   // console.log( 'isUpToDate:2' );
  //   _.assert( arg.length === 5 );
  //   let diffRemote = arg[ 0 ].exitCode !== 0;
  //   let diffLocal = arg[ 1 ].exitCode !== 0;
  //   let commitsRemote = _.strHas( arg[ 2 ].output, '[ahead' );
  //   let commitsLocal = _.strHas( arg[ 3 ].output, 'Changes to be committed' );
  //   let result = !diffRemote && !commitsRemote;
  //
  //   if( o.verbosity )
  //   self.logger.log( o.remotePath, result ? 'is up to date' : 'is not up to date' );
  //
  //   return result;
  // })
  ;

  result
  .finally( function( err, arg )
  {
    // console.log( 'isUpToDate:end' );
    if( err )
    throw _.err( err );
    return arg;
  });

  return result.split();
}

var defaults = isUpToDate.defaults = Object.create( null );

defaults.localPath = null;
defaults.remotePath = null;
defaults.verbosity = 0;

//

function isDownloaded( o )
{
  let self = this;
  let path = self.path;

  _.routineOptions( isUpToDate, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  // logger.log( 'isDownloaded:begin' );

  let srcCurrentPath;
  let dstFileProvider = self.hub.providerForPath( o.localPath );
  let paths = self.pathParse( o.remotePath );
  let result = _.Consequence().take( null );

  _.assert( dstFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  if( !dstFileProvider.fileExists( o.localPath ) )
  return false;

  let gitConfigExists = dstFileProvider.fileExists( path.join( o.localPath, '.git' ) );

  if( !gitConfigExists )
  return false;

  if( gitConfigExists )
  result
  .got( () => GitConfig( dstFileProvider.path.nativize( o.localPath ), result.tolerantCallback() ) )
  .ifNoErrorThen( function( arg )
  {
    if( !arg.remote || !arg.remote.origin || !_.strIs( arg.remote.origin.url ) )
    return false;

    srcCurrentPath = arg.remote.origin.url;

    if( !_.strEnds( srcCurrentPath, paths.stripped ) )
    return false;

    return true;
  });

  result
  .finally( function( err, arg )
  {
    // logger.log( 'isDownloaded:end' );
    if( err )
    throw _.err( err );
    return arg;
  });

  return result.split();
}

var defaults = isUpToDate.defaults = Object.create( null );

defaults.localPath = null;
defaults.remotePath = null;
defaults.verbosity = 0;

// --
// relationship
// --

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'git', 'git+http', 'git+https', 'git+ssh' ]),

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
}

let Statics =
{
  Path : _.uri.CloneExtending({ fileProvider : Self }),
}

let Forbids =
{
  claimMap : 'claimMap',
  claimProvider : 'claimProvider'
}

// --
// declare
// --

let Proto =
{

  finit,
  init,

  // path

  localFromGlobal,
  pathIsolateGlobalAndLocal,
  pathParse,

  // etc

  filesReflectSingle,
  isUpToDate,
  isDownloaded,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,

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

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
