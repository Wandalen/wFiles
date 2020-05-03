( function _Git_ss_( ) {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = require( '../../../../dwtools/Tools.s' );
  if( !_.FileProvider )
  require( '../UseMid.s' );

  _.include( 'wGitTools' )
}

let _global = _global_;
let _ = _global_.wTools;

//

/**
 @classdesc Class that allows file manipulations on a git repository. For example, cloning of the repositoty.
 @class wFileProviderGit
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

let Parent = _.FileProvider.Partial;
let Self = function wFileProviderGit( o )
{
  return _.workpiece.construct( Self, this, arguments );
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

  Parent.prototype.init.call( self,o );

}

// --
// vcs
// --

/**
 * @typedef {Object} RemotePathComponents
 * @property {String} protocol
 * @property {String} hash
 * @property {String} longPath
 * @property {String} localVcsPath
 * @property {String} remoteVcsPath
 * @property {String} remoteVcsLongerPath
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

/**
 * @summary Parses provided `remotePath` and returns object with components {@link module:Tools/mid/Files.wTools.FileProvider.wFileProviderGit.RemotePathComponents}.
 * @param {String} remotePath Remote path.
 * @function pathParse
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function pathParse( remotePath )
{
  let self = this;
  return _.git.pathParse( remotePath );
}

//

/**
 * @summary Returns true if remote path `filePath` contains hash of specific commit.
 * @param {String} filePath Global path.
 * @function pathIsFixated
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function pathIsFixated( filePath )
{
  let self = this;
  return _.git.pathIsFixated( filePath );
}



//

/**
 * @summary Changes hash in provided path `o.remotePath` to hash of latest commit available.
 * @param {Object} o Options map.
 * @param {String} o.remotePath Remote path.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function pathFixate
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function pathFixate( o )
{
  let self = this;
  return _.git.pathFixate( o );
}

//

function versionLocalChange( o )
{
  let self = this;
  return _.git.versionLocalChange( o );
}

//

/**
 * @summary Returns hash of latest commit from git repository located at `o.localPath`.
 * @param {Object} o Options map.
 * @param {String} o.localPath Path to git repository on hard drive.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function versionLocalRetrive
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function versionLocalRetrive( o )
{
  let self = this;
  return _.git.versionLocalRetrive( o );
}

//

/**
 * @summary Returns hash of latest commit from git repository using its remote path `o.remotePath`.
 * @param {Object} o Options map.
 * @param {String} o.remotePath Remote path to git repository.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function versionRemoteLatestRetrive
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function versionRemoteLatestRetrive( o )
{
  let self = this;
  return _.git.versionRemoteLatestRetrive( o );
}

//

/**
 * @summary Returns commit hash from remote path `o.remotePath`.
 * @description Returns hash of latest commit if no hash specified in remote path.
 * @param {Object} o Options map.
 * @param {String} o.remotePath Remote path.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function versionRemoteCurrentRetrive
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function versionRemoteCurrentRetrive( o )
{
  let self = this;
  return _.git.versionRemoteCurrentRetrive( o );
}

//

/**
 * @summary Returns true if local copy of repository `o.localPath` is up to date with remote repository `o.remotePath`.
 * @param {Object} o Options map.
 * @param {String} o.localPath Local path to repository.
 * @param {String} o.remotePath Remote path to repository.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function isUpToDate
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function isUpToDate( o )
{
  let self = this;
  return _.git.isUpToDate( o );
}

//

/**
 * @summary Returns true if path `o.localPath` contains a git repository.
 * @param {Object} o Options map.
 * @param {String} o.localPath Local path to package.
 * @param {Number} o.verbosity=0 Level of verbosity.
 * @function hasFiles
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function hasFiles( o )
{
  let self = this;
  return _.git.hasFiles( o );
}

//

function isRepository( o )
{
  let self = this;
  return _.git.isRepository( o );
}

//

function hasRemote( o )
{
  let self = this;
  return _.git.hasRemote( o );
}

// --
// etc
// --

/*
qqq : investigate please, fix and cover
  if error then new directory should no be made
  if error and directory ( possibly empty ) existed then it should not be deleted
qqq : make sure downloading works if empty directory exists

 = Message
    Process returned exit code 128
    Launched as "git clone https://github.com/Wandalen/wPathBasic.git ."
     -> Stderr
     -  Cloning into '.'...
     -  fatal: unable to access 'https://github.com/Wandalen/wPathBasic.git/': Could not resolve host: github.com
     -
     -< Stderr
    Failed to download module::reflect-get-path / opener::PathBasic
    Failed to download submodules

*/

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;
  let con = new _.Consequence();

  o.extra = o.extra || Object.create( null );
  _.routineOptions( filesReflectSingle_body, o.extra, filesReflectSingle_body.extra );

  _.assertRoutineOptions( filesReflectSingle_body, o );
  // _.assert( o.mandatory === undefined )
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.routineIs( o.onUp ) && o.onUp.composed && o.onUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onDown ) && o.onDown.composed && o.onDown.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteDstUp ) && o.onWriteDstUp.composed && o.onWriteDstUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteDstDown ) && o.onWriteDstDown.composed && o.onWriteDstDown.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteSrcUp ) && o.onWriteSrcUp.composed && o.onWriteSrcUp.composed.elements.length === 0, 'Not supported options' );
  _.assert( _.routineIs( o.onWriteSrcDown ) && o.onWriteSrcDown.composed && o.onWriteSrcDown.composed.elements.length === 0, 'Not supported options' );
  // _.assert( o.outputFormat === 'record' || o.outputFormat === 'nothing', 'Not supported options' );
  _.assert( o.outputFormat === undefined );
  _.assert( o.linking === 'fileCopy' || o.linking === 'hardLinkMaybe' || o.linking === 'softLinkMaybe', 'Not supported options' );
  _.assert( !o.src.hasFiltering(), 'Not supported options' );
  _.assert( !o.dst.hasFiltering(), 'Not supported options' );
  _.assert( o.src.formed === 3 );
  _.assert( o.dst.formed === 3 );
  _.assert( o.srcPath === undefined );
  // _.assert( o.filter === null || !o.filter.hasFiltering(), 'Not supported options' );
  _.assert( o.filter === undefined );
  // _.assert( !!o.recursive, 'Not supported options' );

  /* */

  let localProvider = o.dst.providerForPath();
  let srcPath = o.src.filePathSimplest();
  let dstPath = o.dst.filePathSimplest();
  // let srcPath = o.srcPath;
  // let dstPath = o.dstPath;
  let srcCurrentPath;

  // if( _.mapIs( srcPath ) )
  // {
  //   _.assert( _.mapVals( srcPath ).length === 1 );
  //   _.assert( _.mapVals( srcPath )[ 0 ] === true || _.mapVals( srcPath )[ 0 ] === dstPath );
  //   srcPath = _.mapKeys( srcPath )[ 0 ];
  // }

  let parsed = self.pathParse( srcPath );

  if( parsed.hash && !parsed.isFixated )
  {
    // let err = _.err( `Source path: ${_.color.strFormat( String( srcPath ), 'path' )} is fixated, but hash: ${_.color.strFormat( String( parsed.hash ), 'path' ) } doesn't look like commit hash.` )
    let err = _.err( `Source path: ( ${_.color.strFormat( String( srcPath ), 'path' )} ) looks like path with tag, but defined as path with version. Please use @ instead of # to specify tag` );
    con.error( err );
    return con;
  }

  /* */

  _.sure( _.strDefined( parsed.remoteVcsPath ) );
  _.sure( _.strDefined( parsed.remoteVcsLongerPath ) );
  _.sure( _.strDefined( parsed.hash ) || _.strDefined( parsed.tag ) );
  _.sure( !parsed.tag || !parsed.hash, 'Does not expected both hash and tag in srcPath:', _.strQuote( srcPath ) );
  _.sure( _.strIs( dstPath ) );
  _.assert( localProvider instanceof _.FileProvider.HardDrive || localProvider.originalFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );
  _.sure( !o.src || !o.src.hasFiltering(), 'Does not support filtering, but {o.src} is not empty' );
  _.sure( !o.dst || !o.dst.hasFiltering(), 'Does not support filtering, but {o.dst} is not empty' );
  // _.sure( !o.filter || !o.filter.hasFiltering(), 'Does not support filtering, but {o.filter} is not empty' );

  /* */

  let ready = _.Consequence().take( null );
  let shell = _.process.starter
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : dstPath,
  });

  let shellAll = _.process.starter
  ({
    verbosity : o.verbosity - 1,
    ready : ready,
    currentPath : dstPath,
    throwingExitCode : 0,
    outputCollecting : 1,
  });

  let dstPathCreated = false;
  if( !localProvider.fileExists( dstPath ) )
  {
    localProvider.dirMake( dstPath );
    dstPathCreated = true;
  }

  let gitConfigExists = localProvider.fileExists( path.join( dstPath, '.git' ) );
  let gitMergeFailed = false;

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
  // .give( () => GitConfig( localProvider.path.nativize( dstPath ), ready.tolerantCallback() ) )
  .then( () => _.git.configRead( dstPath ) )
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
      'Should have ' + _.strQuote( parsed.remoteVcsPath )
    );

    return arg || null;
  });

  /* no repository yet */

  if( !gitConfigExists )
  {
    /* !!! delete dst dir maybe */
    if( !localProvider.fileExists( path.join( dstPath, '.git' ) ) )
    shell( 'git clone ' + parsed.remoteVcsLongerPath + ' ' + '.' );
  }
  else
  {
    if( o.extra.fetching ) /* qqq : what is it for? */
    shell( 'git fetch origin' );
  }

  let localChanges = false;
  let mergeIsNeeded = false;
  let hashIsBranchName = false;
  if( gitConfigExists )
  {
    shellAll
    ([
      'git status',
      'git branch'
    ]);
    ready
    .ifNoErrorThen( function( arg )
    {
      _.assert( arg.length === 2 );
      localChanges = _.strHasAny( arg[ 0 ].output, [ 'Changes to be committed', 'Changes not staged for commit' ] );
      mergeIsNeeded = !_.strHasAny( arg[ 0 ].output, [ 'Your branch is up to date', 'Your branch is up-to-date' ] );
      if( parsed.tag )
      hashIsBranchName = _.strHas( arg[ 1 ].output, parsed.tag );
      return localChanges;
    })
  }

  /* stash changes and checkout branch/commit */

  ready.catch( ( err ) =>
  {
    con.error( err );
    throw err;
  });

  ready.ifNoErrorThen( ( arg ) =>
  {
    if( localChanges )
    if( o.extra.stashing )
    shell( 'git stash' );

    ready.then( () => gitCheckout() )

    if( mergeIsNeeded && hashIsBranchName )
    {
      if( localChanges && !o.extra.stashing )
      {
        let err = _.err( 'Failed to merge remote-tracking branch in repository at', _.strQuote( dstPath ), ', repository has local changes and stashing is disabled.' );
        con.error( err );
        throw err;
      }

      ready.then( () => gitMerge() )
    }

    if( localChanges )
    if( o.extra.stashing )
    ready.then( () => gitStashPop() )

    ready.finally( con );

    return arg;
  });

  /* handle error if any */

  con
  .finally( function( err, arg )
  {
    if( err )
    {
      if( dstPathCreated )
      localProvider.filesDelete( dstPath );
      throw _.err( err );
    }
    return recordsMake();
  });

  return con;

  /* */

  function recordsMake()
  {
    /* xxx : fast solution to return records instead of empty array */
    o.result = localProvider.filesReflectEvaluate
    ({
      src : { filePath : dstPath },
      dst : { filePath : dstPath },
    });
    return o.result;
  }

  /* */

  function gitCheckout()
  {
    if( parsed.tag )
    {
      let repoHasTag = _.git.repositoryHasTag({ localPath : dstPath, tag : parsed.tag });
      if( !repoHasTag )
      throw _.err
      (
        `Specified tag: ${_.strQuote( parsed.tag )} doesn't exist in local and remote copy of the repository.\
        \nLocal path: ${_.color.strFormat( String( dstPath ), 'path' )}\
        \nRemote path: ${_.color.strFormat( String( parsed.remoteVcsPath ), 'path' )}`
      );
    }

    let shellOptions =
    {
      execPath : 'git checkout ' + ( parsed.hash || parsed.tag ),
      outputCollecting : 1,
      ready : null
    }

    let con = shell( shellOptions );

    con.finally( ( err, got ) =>
    {
      if( err )
      {
        if( localChanges )
        if( o.extra.stashing )
        shell
        ({
          execPath : 'git stash pop',
          sync : 1,
          deasync : 0,
          throwingExitCode : 0,
          ready : null
        })

        if( !_.strHasAny( shellOptions.output, [ 'fatal: reference', 'error: pathspec' ] ) )
        throw _.err( err );
        _.errAttend( err );
        handleGitError( 'Failed to checkout, branch/commit: ' + _.strQuote( parsed.hash || parsed.tag ) + ' doesn\'t exist in repository at ' + _.strQuote( dstPath ) );
      }
      return null;
    })

    return con;
  }

  /*  */

  function gitMerge()
  {
    let con = shell
    ({
      execPath : 'git config merge.defaultToUpstream true',
      ready : null
    });

    con.then( () =>
    {
      let o =
      {
        execPath : 'git merge',
        outputCollecting : 1,
        ready : null
      }

      return shell( o )
      .finally( ( err, got ) =>
      {
        if( err )
        {
          if( !_.strHas( o.output, 'CONFLICT' ) )
          throw _.err( err )
          _.errAttend( err );
          gitMergeFailed = true;
          handleGitError( 'Automatic merge of remote-tracking branch failed in repository at ' + _.strQuote( dstPath ) + '. Fix conflict(s) manually.' );
        }
        return null;
      })
    })

    return con;
  }

  /* */

  function gitStashPop()
  {
    if( gitMergeFailed )
    {
      if( o.verbosity >= 1 )
      self.logger.log( 'Can\'t pop stashed changes due merge conflict at ' + _.strQuote( dstPath ) );
      return null;
    }

    let o =
    {
      execPath : 'git stash pop',
      outputCollecting : 1,
      ready : null
    };

    let con = shell( o );

    con.finally( ( err, got ) =>
    {
      if( err )
      {
        if( !_.strHas( o.output, 'CONFLICT' ) )
        throw _.err( err );
        _.errAttend( err );
        handleGitError( 'Automatic merge of stashed changes failed in repository at ' + _.strQuote( dstPath ) + '. Fix conflict(s) manually.' );
      }
      return null;
    })

    return con;
  }

  /* */

  function handleGitError( err )
  {
    if( self.throwingGitErrors )
    throw _.errBrief( err );
    else if( o.verbosity )
    self.logger.log( err );
  }

}

_.routineExtend( filesReflectSingle_body, _.FileProvider.Find.prototype.filesReflectSingle );

var extra = filesReflectSingle_body.extra = Object.create( null );
extra.fetching = 1;
extra.stashing = 0;

var defaults = filesReflectSingle_body.defaults;
let filesReflectSingle = _.routineFromPreAndBody( _.FileProvider.Find.prototype.filesReflectSingle.pre, filesReflectSingle_body );

// --
// relationship
// --

/**
 * @typedef {Object} Fields
 * @property {Boolean} safe
 * @property {String[]} protocols=[ 'git', 'git+http', 'git+https', 'git+ssh' ]
 * @property {Boolean} resolvingSoftLink=0
 * @property {Boolean} resolvingTextLink=0
 * @property {Boolean} limitedImplementation=1
 * @property {Boolean} isVcs=1
 * @property {Boolean} usingGlobalPath=1
 * @class wFileProviderGit
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'git', 'git+http', 'git+https', 'git+ssh', 'git+hd' ]),

  resolvingSoftLink : 0,
  resolvingTextLink : 0,
  limitedImplementation : 1,
  isVcs : 1,
  usingGlobalPath : 1,
  globing : 0,

  throwingGitErrors : 1

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

  pathParse,
  pathIsFixated,
  pathFixate,

  versionLocalChange,
  versionLocalRetrive,
  versionRemoteLatestRetrive,
  versionRemoteCurrentRetrive,

  isUpToDate,
  hasFiles,
  isRepository,
  hasRemote,

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

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})( );
