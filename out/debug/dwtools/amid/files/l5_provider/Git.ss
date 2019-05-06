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
let GitConfig, Ini;

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

  if( !Ini )
  Ini = require( 'ini' );

  Parent.prototype.init.call( self,o );

}

//

function _gitConfigRead( filePath )
{
  let self = this;
  let path = self.path;
  let hd = self.hub.providersWithProtocolMap.file;

  // debugger;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( filePath ) );

  let read = hd.fileRead( path.join( filePath, '.git/config' ) );
  let config = Ini.parse( read );

  // debugger;

  //   let read = localProvider.fileRead( path.join( dstPath, '.git/config' ) );
  //   let config = Ini.parse( read );

  return config;
}

// --
// vcs
// --

function pathParse( remotePath )
{
  let self = this;
  let path = self.path;
  let result = Object.create( null );

  if( _.mapIs( remotePath ) )
  return remotePath;

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( remotePath ) );
  _.assert( path.isGlobal( remotePath ) )

  /* */

  let parsed1 = path.parseConsecutive( remotePath );
  parsed1.hash = parsed1.hash || 'master';
  _.mapExtend( result, parsed1 );

  let p = pathIsolateGlobalAndLocal( parsed1.longPath );
  result.localVcsPath = p[ 1 ];

  /* */

  let parsed2 = _.mapExtend( null, parsed1 );
  parsed2.protocol = null;
  parsed2.hash = null;
  parsed2.longPath = _.strRemoveEnd( _.strRemoveBegin( p[ 0 ], '/' ), '/' );
  result.remoteVcsPath = path.str( parsed2 );

  /* */

  let parsed3 = _.mapExtend( null, parsed1 );
  parsed3.protocols = parsed3.protocol ? parsed3.protocol.split( '+' ) : [];
  parsed3.longPath = parsed2.longPath;
  if( parsed3.protocols.length > 0 && parsed3.protocols[ 0 ].toLowerCase() === 'git' )
  {
    parsed3.protocols.splice( 0,1 );
  }
  parsed3.protocol = null;
  parsed3.hash = null;
  result.longerRemoteVcsPath = path.str( parsed3 );

  result.isFixated = self.pathIsFixated( result );

  /* */

  return result

/*

  remotePath : 'git+https:///github.com/Wandalen/wTools.git/out/wTools#master'

  protocol : 'git+https',
  hash : 'master',
  longPath : '/github.com/Wandalen/wTools.git/out/wTools',
  localVcsPath : 'out/wTools',
  remoteVcsPath : 'github.com/Wandalen/wTools.git',
  longerRemoteVcsPath : 'https://github.com/Wandalen/wTools.git'

*/

  /* */

  function pathIsolateGlobalAndLocal( remotePath )
  {
    let parsed = path.parseConsecutive( remotePath );
    let splits = _.strIsolateLeftOrAll( parsed.longPath, '.git/' );
    parsed.longPath = splits[ 0 ] + ( splits[ 1 ] || '' );
    let globalPath = path.str( parsed );
    return [ globalPath, splits[ 2 ] ];
  }

}

//

function pathIsFixated( filePath )
{
  let self = this;
  let path = self.path;
  let parsed = self.pathParse( filePath );

  if( !parsed.hash )
  return false;

  if( parsed.hash.length < 7 )
  return false;

  if( !/[0-9a-f]+/.test( parsed.hash ) )
  return false;

  return true;
}

//

function pathFixate( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { remotePath : o }
  _.routineOptions( pathFixate, o );
  _.assert( arguments.length === 1, 'Expects single argument' );

  let parsed = self.pathParse( o.remotePath );
  let latestVersion = self.versionRemoteLatestRetrive
  ({
    remotePath : o.remotePath,
    verbosity : o.verbosity,
  });

  let result = path.str
  ({
    protocol : parsed.protocol,
    longPath : parsed.longPath,
    hash : latestVersion,
  });

  return result;
}

var defaults = pathFixate.defaults = Object.create( null );
defaults.remotePath = null;
defaults.verbosity = 0;

//

function versionLocalRetrive( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { localPath : o }

  _.routineOptions( versionLocalRetrive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  if( !self.isDownloaded( o ) )
  return false;

  let localProvider = self.hub.providerForPath( o.localPath );

  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  let currentVersion = localProvider.fileRead( path.join( o.localPath, '.git/HEAD' ) );
  let r = /^ref: refs\/heads\/(.+)\s*$/;

  let found = r.exec( currentVersion );
  if( found )
  currentVersion = found[ 1 ];

  return currentVersion.trim() || null;
}

var defaults = versionLocalRetrive.defaults = Object.create( null );
defaults.localPath = null;
defaults.verbosity = 0;

//

function versionRemoteLatestRetrive( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { remotePath : o }

  _.routineOptions( versionRemoteLatestRetrive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  let parsed = self.pathParse( o.remotePath );
  let shell = _.sheller
  ({
    verbosity : self.verbosity - 1,
    sync : 1,
    deasync : 0,
    outputCollecting : 1,
  });

  let got = shell( 'git ls-remote ' + parsed.longerRemoteVcsPath );
  let latestVersion = /([0-9a-f]+)\s+HEAD/.exec( got.output );
  if( !latestVersion || !latestVersion[ 1 ] )
  return null;

  latestVersion = latestVersion[ 1 ];

  return latestVersion;
}

var defaults = versionRemoteLatestRetrive.defaults = Object.create( null );
defaults.remotePath = null;
defaults.verbosity = 0;

//

function versionRemoteCurrentRetrive( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { remotePath : o }

  _.routineOptions( versionRemoteCurrentRetrive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  let parsed = self.pathParse( o.remotePath );
  if( parsed.isFixated )
  return parsed.hash;

  return self.versionRemoteLatestRetrive( o );
}

var defaults = versionRemoteCurrentRetrive.defaults = Object.create( null );
defaults.remotePath = null;
defaults.verbosity = 0;

//

function isUpToDate( o )
{
  let self = this;
  let path = self.path;

  _.routineOptions( isUpToDate, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  let srcCurrentPath;
  let localProvider = self.hub.providerForPath( o.localPath );
  let parsed = self.pathParse( o.remotePath );
  let ready = _.Consequence().take( null );

  let shell = _.sheller
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : o.localPath,
  });

  let shellAll = _.sheller
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : o.localPath,
    throwingExitCode : 0,
    outputCollecting : 1,
  });

  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  if( !localProvider.fileExists( o.localPath ) )
  return false;

  let gitConfigExists = localProvider.fileExists( path.join( o.localPath, '.git' ) );

  if( !gitConfigExists )
  return false;

  if( gitConfigExists )
  ready
  // .got( () => GitConfig( localProvider.path.nativize( o.localPath ), ready.tolerantCallback() ) )
  .then( () => self._gitConfigRead( o.localPath ) )
  .ifNoErrorThen( function( arg )
  {

    debugger;

    if( !arg[ 'remote "origin"' ] || !arg[ 'remote "origin"' ] || !_.strIs( arg[ 'remote "origin"' ].url ) )
    return false;

    srcCurrentPath = arg[ 'remote "origin"' ].url;

    if( !_.strEnds( srcCurrentPath, parsed.remoteVcsPath ) )
    return false;

    return true;
  });

  shell( 'git fetch origin' );

  ready.finally( ( err, arg ) =>
  {
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

  ready
  .ifNoErrorThen( function( arg )
  {
    _.assert( arg.length === 2 );

    let result = !_.strHas( arg[ 0 ].output, 'Your branch is behind' );

    if( o.verbosity )
    self.logger.log( o.remotePath, result ? 'is up to date' : 'is not up to date' );

    return result;
  })

  ready
  .finally( function( err, arg )
  {
    if( err )
    throw _.err( err );
    return arg;
  });

  return ready.split();
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

  _.routineOptions( isDownloaded, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  let srcCurrentPath;
  let localProvider = self.hub.providerForPath( o.localPath );
  let result = false;

  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  if( !localProvider.fileExists( o.localPath ) )
  return false;

  let gitConfigExists = localProvider.fileExists( path.join( o.localPath, '.git' ) );

  if( !gitConfigExists )
  return false;

  if( gitConfigExists )
  {
    if( !localProvider.isTerminal( path.join( o.localPath, '.git/config' ) ) )
    return false;
  }

  return true;
}

var defaults = isDownloaded.defaults = Object.create( null );
defaults.localPath = null;
defaults.verbosity = 0;

// --
// etc
// --

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;
  let con = new _.Consequence();

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
  _.assert( o.srcFilter.filePath === o.srcPath );
  _.assert( o.filter === null || !o.filter.hasFiltering(), 'Not supported options' );
  _.assert( !!o.recursive, 'Not supported options' );

  /* */

  let localProvider = o.dstFilter.providerForPath();
  let srcPath = o.srcPath;
  let dstPath = o.dstPath;
  let srcCurrentPath;

  if( _.mapIs( srcPath ) )
  {
    _.assert( _.mapVals( srcPath ).length === 1 );
    _.assert( _.mapVals( srcPath )[ 0 ] === true || _.mapVals( srcPath )[ 0 ] === dstPath );
    srcPath = _.mapKeys( srcPath )[ 0 ];
  }

  let parsed = self.pathParse( srcPath );

  /* */

  _.sure( _.strDefined( parsed.remoteVcsPath ) );
  _.sure( _.strDefined( parsed.longerRemoteVcsPath ) );
  _.sure( _.strDefined( parsed.hash ) );
  _.sure( _.strIs( dstPath ) );
  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );
  _.sure( !o.srcFilter || !o.srcFilter.hasFiltering(), 'Does not support filtering, but {o.srcFilter} is not empty' );
  _.sure( !o.dstFilter || !o.dstFilter.hasFiltering(), 'Does not support filtering, but {o.dstFilter} is not empty' );
  _.sure( !o.filter || !o.filter.hasFiltering(), 'Does not support filtering, but {o.filter} is not empty' );

  /* */

  let ready = _.Consequence().take( null );
  let shell = _.sheller
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : dstPath,
  });

  let shellAll = _.sheller
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : dstPath,
    throwingExitCode : 0,
    outputCollecting : 1,
  });

  if( !localProvider.fileExists( dstPath ) )
  localProvider.dirMake( dstPath );

  let gitConfigExists = localProvider.fileExists( path.join( dstPath, '.git' ) );

  /* already have repository here */

  // !!! : remove GitConfig
  // if( gitConfigExists )
  // {
  //   debugger;
  //   let read = localProvider.fileRead( path.join( dstPath, '.git/config' ) );
  //   let config = Ini.parse( read );
  //   debugger;
  // }

  // if( gitConfigExists )
  // debugger;

  if( gitConfigExists )
  ready
  // .got( () => GitConfig( localProvider.path.nativize( dstPath ), ready.tolerantCallback() ) )
  .then( () => self._gitConfigRead( dstPath ) )
  .ifNoErrorThen( function( arg )
  {

    // debugger;
    _.sure
    (
      !!arg[ 'remote "origin"' ] && !!arg[ 'remote "origin"' ] && _.strIs( arg[ 'remote "origin"' ].url ),
      'GIT config does not have {-remote.origin.url-}'
    );

    srcCurrentPath = arg[ 'remote "origin"' ].url;

    _.sure
    (
      _.strEnds( _.strRemoveEnd( srcCurrentPath, '/' ), _.strRemoveEnd( parsed.remoteVcsPath, '/' ) ),
      () => 'GIT repository at directory ' + _.strQuote( dstPath ) + '\n' +
      'Has origin ' + _.strQuote( srcCurrentPath ) + '\n' +
      'Should have ' + _.strQuote( parsed.longerRemoteVcsPath )
    );

    return arg || null;
  });

  /* no repository yet */

  if( !gitConfigExists )
  {
    /* !!! delete dst dir maybe */
    if( !localProvider.fileExists( path.join( dstPath, '.git' ) ) )
    shell( 'git clone ' + parsed.longerRemoteVcsPath + ' ' + '.' );
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
    ready
    .ifNoErrorThen( function( arg )
    {
      _.assert( arg.length === 2 );
      localChanges = _.strHas( arg[ 0 ].output, 'Changes to be committed' );
      return localChanges;
    })
  }

  /* stash changes and checkout branch/commit */

  ready.except( ( err ) =>
  {
    con.error( err );
    throw err;
  });

  ready.ifNoErrorThen( ( arg ) =>
  {

    if( localChanges )
    shell( 'git stash' );
    shell( 'git checkout ' + parsed.hash );
    if( parsed.hash.length < 7 || !_.strIsHex( parsed.hash ) ) /* qqq : probably does not work for all cases */
    shell( 'git merge' );
    if( localChanges )
    shell({ path : 'git stash pop', throwingExitCode : 0 });

    ready.finally( con );

    return arg;
  });

  /* handle error if any */

  con
  .finally( function( err, arg )
  {
    if( err )
    throw _.err( err );
    return recordsMake();
  });

  return con;

  /* */

  function recordsMake()
  {
    /* xxx : fast solution to return records instead of empty array */
    o.result = localProvider.filesReflectEvaluate
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
  isVcs : 1,
  usingGlobalPath : 1,

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

  // vcs

  _gitConfigRead,

  pathParse,
  pathIsFixated,
  pathFixate,
  versionLocalRetrive,
  versionRemoteLatestRetrive,
  versionRemoteCurrentRetrive,
  isUpToDate,
  isDownloaded,

  // etc

  filesReflectSingle,

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
