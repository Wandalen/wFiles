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

function pathParse( remotePath )
{
  let self = this;
  let path = self.path;
  let result = Object.create( null );

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( remotePath ) );
  _.assert( path.isGlobal( remotePath ) )

  /* */

  let parsed1 = path.parseConsecutive( remotePath );
  _.mapExtend( result, parsed1 );

  let p = pathIsolateGlobalAndLocal( parsed1.longPath );
  result.localVcsPath = p[ 1 ];

  /* */

  let parsed2 = _.mapExtend( null, parsed1 );
  parsed2.protocol = null;
  parsed2.hash = null;
  parsed2.longPath = p[ 0 ];
  result.remoteVcsPath = path.str( parsed2 );

  /* */

  let parsed3 = _.mapExtend( null, parsed1 );
  parsed3.longPath = parsed2.longPath;
  parsed3.protocol = null;
  parsed3.hash = null;
  result.longerRemoteVcsPath = path.str( parsed3 );
  if( parsed1.hash )
  result.longerRemoteVcsPath += '@' + parsed1.hash;

  /* */

  return result

/*

  remotePath : 'npm:///wColor/out/wColor#0.3.100'

  protocol : 'npm',
  hash : '0.3.100',
  longPath : '/wColor/out/wColor',
  localVcsPath : 'out/wColor',
  remoteVcsPath : 'wColor',
  longerRemoteVcsPath : 'wColor@0.3.100'

*/

  /* */

  function pathIsolateGlobalAndLocal( longPath )
  {
    let parsed = path.parseConsecutive( longPath );
    let splits = _.strIsolateLeftOrAll( parsed.longPath, /^\/?\w+\/?/ );
    parsed.longPath = _.strRemoveEnd( _.strRemoveBegin( splits[ 1 ], '/' ), '/' );
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
  let latestVersion = self.versionLatestRetrive
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

function versionCurrentRetrive( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { localPath : o }

  _.routineOptions( versionCurrentRetrive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  if( !self.isDownloaded( o ) )
  return false;

  let localProvider = self.hub.providerForPath( o.localPath );

  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  let currentVersion;
  try
  {
    let read = localProvider.fileRead({ filePath : path.join( o.localPath, 'package.json' ), encoding : 'json' });
    currentVersion = read.version;
  }
  catch( err )
  {
    debugger;
    return null;
  }

  return currentVersion || null;
}

var defaults = versionCurrentRetrive.defaults = Object.create( null );
defaults.localPath = null;
defaults.verbosity = 0;

//

function versionLatestRetrive( o )
{
  let self = this;
  let path = self.path;

  if( !_.mapIs( o ) )
  o = { remotePath : o }

  _.routineOptions( versionLatestRetrive, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( !!self.hub );

  let parsed = self.pathParse( o.remotePath );
  let shell = _.sheller
  ({
    verbosity : o.verbosity - 1,
    outputCollecting : 1,
    sync : 1,
    deasync : 0,
  });

  let got = shell( 'npm show ' + parsed.remoteVcsPath );
  let latestVersion = /latest.*?:.*?([0-9\.][0-9\.][0-9\.]+)/.exec( got.output );

  if( !latestVersion )
  {
    debugger;
    throw _.err( 'Failed to get information about NPM package', parsed.remoteVcsPath );
  }

  latestVersion = latestVersion[ 1 ];

  return latestVersion;
}

var defaults = versionLatestRetrive.defaults = Object.create( null );
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

  let parsed = self.pathParse( o.remotePath );

  let currentVersion = self.versionCurrentRetrive
  ({
    localPath : o.localPath,
    verbosity : o.verbosity,
  });

  if( !currentVersion )
  return false;

  if( parsed.hash === currentVersion )
  return true;

  let latestVersion = self.versionLatestRetrive
  ({
    remotePath : o.remotePath,
    verbosity : o.verbosity,
  });

  return currentVersion === latestVersion;
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

  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );

  if( !localProvider.fileExists( o.localPath ) )
  return false;

  // if( !localProvider.isDir( path.join( o.localPath, 'node_modules' ) ) )
  // return false;

  if( !localProvider.isTerminal( path.join( o.localPath, 'package.json' ) ) )
  return false;

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

  defaults.dstRewriting = 1;
  defaults.dstRewritingByDistinct = 1;
  defaults.dstRewritingPreserving = 0;

  /* */

  let localProvider = o.dstFilter.providerForPath();
  let srcPath = o.srcPath;
  let dstPath = o.dstPath;

  if( _.mapIs( srcPath ) )
  {
    _.assert( _.mapVals( srcPath ).length === 1 );
    _.assert( _.mapVals( srcPath )[ 0 ] === true || _.mapVals( srcPath )[ 0 ] === dstPath );
    srcPath = _.mapKeys( srcPath )[ 0 ];
  }

  let parsed = self.pathParse( srcPath );

  /* */

  _.sure( _.strIs( srcPath ) );
  _.sure( _.strIs( dstPath ) );
  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );
  _.sure( !o.srcFilter || !o.srcFilter.hasFiltering(), 'Does not support filtering, but {o.srcFilter} is not empty' );
  _.sure( !o.dstFilter || !o.dstFilter.hasFiltering(), 'Does not support filtering, but {o.dstFilter} is not empty' );
  _.sure( !o.filter || !o.filter.hasFiltering(), 'Does not support filtering, but {o.filter} is not empty' );

  /* */

  let result = [];
  let shell = _.sheller
  ({
    verbosity : o.verbosity - 1,
    sync : 1,
    deasync : 0,
    outputCollecting : 1,
  });

  if( !localProvider.fileExists( path.dir( dstPath ) ) )
  localProvider.dirMake( path.dir( dstPath ) );

  let exists = localProvider.fileExists( dstPath );
  let isDir = localProvider.isDir( dstPath );
  if( exists && !isDir )
  throw occupiedErr();

  /* */

  if( exists )
  {
    if( localProvider.dirRead( dstPath ).length === 0 )
    {
      localProvider.fileDelete( dstPath );
      exists = false;
    }
  }

  if( exists )
  {

    let packageFilePath = path.join( dstPath, 'package.json' );
    if( !localProvider.isTerminal( packageFilePath ) )
    throw occupiedErr( '. Directory is occupied!' );

    try
    {
      let read = localProvider.fileRead({ filePath : packageFilePath, encoding : 'json' });
      if( !read || read.name !== parsed.remoteVcsPath )
      throw _.err( 'Directory is occupied!' );
    }
    catch( err )
    {
      throw _.err( occupiedErr( '' ), err );
    }

    localProvider.filesDelete( dstPath );

  }

  /* */

  let tmpPath = dstPath + '-' + _.idWithGuid();
  let tmpEssentialPath = path.join( tmpPath, 'node_modules', parsed.remoteVcsPath );
  let got = shell( 'npm install --prefix ' + localProvider.path.nativize( tmpPath ) + ' ' + parsed.longerRemoteVcsPath )

  _.assert( got.exitCode === 0 );

  localProvider.fileRename( dstPath, tmpEssentialPath )
  localProvider.fileDelete( path.dir( tmpEssentialPath ) );
  localProvider.fileDelete( path.dir( path.dir( tmpEssentialPath ) ) );

  return recordsMake();

  /* */

  function recordsMake()
  {
    /* xxx : fast solution to return some records instead of empty arrray */
    o.result = localProvider.filesReflectEvaluate
    ({
      srcPath : dstPath,
      dstPath : dstPath,
    });
    return o.result;
  }

  /* */

  function occupiedErr( msg )
  {
    debugger;
    return _.err( 'Cant download NPM package ' + _.color.strFormat( parsed.longerRemoteVcsPath, 'path' ) + ' to ' + _.color.strFormat( dstPath, 'path' ) + ( msg || '' ) )
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
}

// --
// declare
// --

let Proto =
{

  finit,
  init,


  // vcs

  pathParse,
  pathIsFixated,
  pathFixate,
  versionCurrentRetrive,
  versionLatestRetrive,
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
