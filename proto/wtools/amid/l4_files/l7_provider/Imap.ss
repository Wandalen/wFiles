( function _Imap_ss_()
{

'use strict';

let Imap;

if( typeof module !== 'undefined' )
{
  Imap = require( 'imap-simple' );
}

let _global = _global_;
let _ = _global_.wTools;
let Abstract = _.FileProvider.Abstract;
let Partial = _.FileProvider.Partial;
let Find = _.FileProvider.FindMixin;

_.assert( _.routineIs( _.FileRecord ) );
_.assert( _.routineIs( Abstract ) );
_.assert( _.routineIs( Partial ) );
_.assert( !!Find );
_.assert( !_.FileProvider.Imap );

//

/**
 @classdesc Imap files provider.
 @class wFileProviderImap
 @namespace wTools.FileProvider
 @module Tools/mid/Files
*/

let Parent = Partial;
let Self = wFileProviderImap;
function wFileProviderImap( o )
{
  return _.workpiece.construct( Self, this, arguments );
}

Self.shortName = 'Imap';

// --
// inter
// --

function init( o )
{
  let self = this;
  Parent.prototype.init.call( self, o );
  self.ready = _.Consequence();
  self.form();
}

//

function form()
{
  let self = this;
  let path = self.path;

  _.assert( _.strDefined( self.login ) );
  _.assert( _.strDefined( self.password ) );
  _.assert( _.strDefined( self.hostUri ) );

  if( !path.isGlobal( self.hostUri ) )
  self.hostUri = '://' + self.hostUri;

  let parsed = path.parse( self.hostUri );
  let config =
  {
    imap :
    {
      user : self.login,
      password : self.password,
      host : parsed.host,
      port : parsed.port || 993,
      tls : self.tls,
      authTimeout : self.authTimeOut,
    }
  };

  // debugger;
  return _.Consequence.Try( () => Imap.connect( config ) )
  .then( function( connection )
  {
    self._connection = connection;
    self.ready.take( connection );
    return connection;
  })
  .catch( ( err ) =>
  {
    err = _.err( err );
    self.ready.error( err );
    throw err;
  });

}

//

function unform()
{
  let self = this;
  // let a = self._connection.imap.closeBox( true );
  self._connection.end();
  return self;
}

// --
// path
// --

/**
 * @summary Return path to current working directory.
 * @description Changes current path to `path` if argument is provided.
 * @param {String} [path] New current path.
 * @function pathCurrentAct
 * @class wFileProviderImap
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
*/

function pathCurrentAct()
{
  let self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  {
    let path = arguments[ 0 ];
    _.assert( self.path.is( path ) );
    self._currentPath = path;
  }

  let result = self._currentPath;

  return result;
}

//

/**
 * @summary Resolves soft link `o.filePath`.
 * @description Accepts single argument - map with options. Expects that map `o` contains all necessary options and don't have redundant fields.
 * Returns input path `o.filePath` if source file is not a soft link.
 * @param {Object} o Options map.
 * @param {String} o.filePath Path to soft link.
 * @param {Boolean} o.resolvingMultiple=0 Resolves chain of terminal links.
 * @param {Boolean} o.resolvingIntermediateDirectories=0 Resolves intermediate soft links.
 * @function pathResolveSoftLinkAct
 * @class wFileProviderImap
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function pathResolveSoftLinkAct( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.path.isAbsolute( o.filePath ) );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( pathResolveSoftLinkAct, Parent.prototype.pathResolveSoftLinkAct )

//

function pathParse( filePath )
{
  let self = this;
  let path = self.path;
  let result = Object.create( null );

  result.originalPath = filePath;
  result.unabsolutePath = path.unabsolute( filePath );
  result.dirPath = path.dir( result.originalPath );
  result.fullName = path.fullName( filePath );

  result.isTerminal = _.strInsideOf( result.fullName, '<', '>' );
  result.stripName = result.isTerminal ? result.isTerminal : result.fullName;
  result.isTerminal = !!result.isTerminal;

  return result;
}

// --
// read
// --

/**
 * @summary Reads content of a terminal file.
 * @description Accepts single argument - map with options. Expects that map `o` contains all necessary options and don't have redundant fields.
 * If `o.sync` is false, return instance of wConsequence, that gives a message with concent of a file when reading is finished.
 * @param {Object} o Options map.
 * @param {String} o.filePath Path to terminal file.
 * @param {String} o.encoding Desired encoding of a file concent.
 * @param {*} o.advanced
 * @param {Boolean} o.resolvingSoftLink Enable resolving of soft links.
 * @param {String} o.sync Determines how to read a file, synchronously or asynchronously.
 * @function fileReadAct
 * @class wFileProviderImap
 * @namespace wTools.FileProvider
 * @module Tools/mid/Files
 */

function fileReadAct( o )
{
  let self = this;
  let path = self.path;
  let ready = self.ready.split();
  let result = null;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( fileReadAct, o );
  _.assert( _.strIs( o.encoding ) );
  o.advanced = _.routineOptions( null, o.advanced || Object.create( null ), fileReadAct.advanced );

  let parsed = self.pathParse( o.filePath );
  parsed.dirPath = path.unabsolute( parsed.dirPath );

  if( !parsed.isTerminal )
  throw _.err( `${o.filePath} is not a terminal` );

  ready.then( () => _read() );
  ready.then( () => result );

  if( o.sync )
  {
    ready.deasync();
    return ready.sync();
  }

  return ready;

  /* */

  function _read()
  {
    return self._connection.openBox( parsed.dirPath ).then( function ( extra ) /* xxx : need to close? */
    {
      let searchCriteria = [ `${parsed.stripName}` ];
      let bodies = [];
      if( o.advanced.withHeader )
      bodies.push( 'HEADER' );
      if( o.advanced.withBody )
      bodies.push( 'TEXT' );
      if( o.advanced.withTail )
      bodies.push( '' );
      let fetchOptions =
      {
        bodies,
        struct : !!o.advanced.structing,
        markSeen : false,
      };
      return self._connection.search( searchCriteria, fetchOptions ).then( function( messages )
      {
        _.assert( messages.length >= 1, 'Terminal does not exist' );
        _.assert( messages.length <= 1, 'There are several such terminals' );
        result = messages[ 0 ];
        resultHandle( result );
        self._connection.closeBox( parsed.dirPath );
      });
    });
  }

  /* */

  function resultHandle( result )
  {
    if( o.advanced.withHeader )
    {
      result.header = Object.create( null );
      let headers = result.parts.filter( ( e ) => e.which === 'HEADER' );
      headers.forEach( ( header ) =>
      {
        _.mapExtend( result.header, header.body );
      });
    }
  }

  /* */

}

_.routineExtend( fileReadAct, Parent.prototype.fileReadAct );

fileReadAct.advanced =
{
  withHeader : 1,
  withBody : 1,
  withTail : 1,
  structing : 1,
}

//

function dirReadAct( o )
{
  let self = this;
  let path = self.path;
  let ready = self.ready.split();
  let result;

  _.assertRoutineOptions( dirReadAct, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.path.isNormalized( o.filePath ) );

  ready.then( () => self._connection.getBoxes() );
  ready.then( ( map ) =>
  {
    result = filter( map );
    return result;
  });

  ready.then( () => _mailsRead( o.filePath ) );
  ready.then( () => result );

  if( o.sync )
  {
    ready.deasync();
    return ready.sync();
  }

  return ready;

  /* */

  function _mailsRead( filePath )
  {
    if( result === null )
    return result;
    if( filePath === '/' )
    return result;

    filePath = path.unabsolute( filePath );
    return self._connection.openBox( filePath ).then( function( extra ) /* xxx : need to close? */
    {
      let searchCriteria = [ 'ALL' ];
      let fetchOptions =
      {
        bodies : [ 'HEADER' ],
        struct : false,
        markSeen : false,
      };
      return self._connection.search( searchCriteria, fetchOptions ).then( function( messages )
      {
        messages.forEach( function( message, k )
        {
          let mid = message.attributes.uid;
          _.assert( _.numberIs( mid ) );
          _.arrayAppendOnceStrictly( result, '<' + String( mid ) + '>' );
        });
        self._connection.closeBox( filePath );
      });
    });

  }

  /* */

  function filter( map )
  {
    if( o.filePath === path.rootToken )
    return _.mapKeys( map );
    let isAbsolute = path.isAbsolute( o.filePath );
    let filePath = path.unabsolute( o.filePath );
    filePath = filePath.split( '/' ).map( ( e, k ) => `${e}/children` ).join( '/' );
    if( isAbsolute )
    filePath = path.absolute( filePath );
    let result = _.select( map, filePath );
    if( result === null )
    return [];
    if( !result )
    return null;
    return _.mapKeys( result );
  }

  /* */

}

_.routineExtend( dirReadAct, Parent.prototype.dirReadAct );

// --
// read stat
// --

function statReadAct( o )
{
  let self = this;
  let path = self.path;
  let parsed = self.pathParse( o.filePath );
  let stat;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( statReadAct, o );

  /* */

  let result = _statReadAct();

  if( o.sync )
  {
    if( _.consequenceIs( result ) )
    {
      result.deasync();
      return result.sync();
    }
  }
  else
  {
    if( !_.consequenceIs( result ) )
    return new _.Consequence().take( result );
  }

  return result;

  /* */

  function _statReadAct()
  {
    stat = null;
    let throwing = 0;
    let sync = 1;

    if( parsed.isTerminal )
    {
      let files = self.dirRead({ filePath : parsed.dirPath, throwing, sync });
      if( !_.longHas( files, parsed.fullName ) )
      throw _.err( `File ${o.filePath} does not exist` );
      let advanced =
      {
        withHeader : 1,
        withBody : 0,
        withTail : 0,
        structing : 0,
      }
      let o2 = _.mapSupplement( { filePath : o.filePath, advanced, throwing, sync }, self.fileReadAct.defaults );
      let read = self.fileRead( o2 );
      stat = statMake();
      stat.isFile = returnTrue;
    }
    else
    {
      stat = statMake();
      stat.isDirectory = returnTrue;
      stat.isDir = returnTrue;
      let ready = _.Consequence.From( _dirRead() );
      return ready;
      debugger;
    }

    return stat;
  }

  /* */

  function _dirRead()
  {
    return self.ready.split()
    .give( function()
    {
      let con = this;
      let dirPath = path.unabsolute( parsed.originalPath );
      self._connection.openBox( dirPath )
      .then( ( extra ) => /* xxx : need to close? */
      {
        result.extra = extra;
        self._connection.closeBox( dirPath );
        debugger;
        con.take( stat );
      })
      .catch( ( err ) =>
      {
        con.error( _.err( err ) );
      });
    });
    // .then( () =>
    // {
    //   debugger;
    //   return result;
    // });
  }

  /* */

  function statMake()
  {
    let result = new _.FileStat();

    // if( self.extraStats && self.extraStats[ filePath ] )
    // {
    //   let extraStat = self.extraStats[ filePath ];
    //   result.atime = new Date( extraStat.atime );
    //   result.mtime = new Date( extraStat.mtime );
    //   result.ctime = new Date( extraStat.ctime );
    //   result.birthtime = new Date( extraStat.birthtime );
    //   result.ino = extraStat.ino || null;
    //   result.dev = extraStat.dev || null;
    // }

    result.filePath = o.filePath;
    result.isTerminal = returnFalse;
    result.isDir = returnFalse;
    result.isTextLink = returnFalse;
    result.isSoftLink = returnFalse;
    result.isHardLink = returnFalse;
    result.isDirectory = returnFalse;
    result.isFile = returnFalse;
    result.isSymbolicLink = returnFalse;
    result.nlink = 1;

    return result;
  }

  /* */

  function returnFalse()
  {
    return false;
  }

  /* */

  function returnTrue()
  {
    return true;
  }

  /* */

}

_.routineExtend( statReadAct, Parent.prototype.statReadAct );

//

function fileExistsAct( o )
{
  let self = this;

  _.assert( arguments.length === 1 );
  _.assert( self.path.isNormalized( o.filePath ) );
  _.assert( 0, 'not implemented' );

  return !!file;
}

_.routineExtend( fileExistsAct, Parent.prototype.fileExistsAct );

// --
// write
// --

function fileWriteAct( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( fileWriteAct, o );
  _.assert( self.path.isNormalized( o.filePath ) );
  _.assert( self.WriteMode.indexOf( o.writeMode ) !== -1 );

  _.assert( 0, 'not implemented' );

}

_.routineExtend( fileWriteAct, Parent.prototype.fileWriteAct );

//

function fileDeleteAct( o )
{
  let self = this;

  _.assertRoutineOptions( fileDeleteAct, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( self.path.isNormalized( o.filePath ) );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( fileDeleteAct, Parent.prototype.fileDeleteAct );

//

function dirMakeAct( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( dirMakeAct, o );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( dirMakeAct, Parent.prototype.dirMakeAct );

// --
// linking
// --

function fileRenameAct( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( fileRenameAct, arguments );
  _.assert( self.path.isNormalized( o.srcPath ) );
  _.assert( self.path.isNormalized( o.dstPath ) );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( fileRenameAct, Parent.prototype.fileRenameAct );

//

function fileCopyAct( o )
{
  let self = this;
  let srcFile;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( fileCopyAct, arguments );
  _.assert( self.path.isNormalized( o.srcPath ) );
  _.assert( self.path.isNormalized( o.dstPath ) );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( fileCopyAct, Parent.prototype.fileCopyAct );

//

function softLinkAct( o )
{
  let self = this;

  _.assertRoutineOptions( softLinkAct, arguments );
  _.assert( self.path.is( o.srcPath ) );
  _.assert( self.path.isAbsolute( o.dstPath ) );
  _.assert( self.path.isNormalized( o.srcPath ) );
  _.assert( self.path.isNormalized( o.dstPath ) );

  _.assert( 0, 'not implemented' );

}

_.routineExtend( softLinkAct, Parent.prototype.softLinkAct );

//

function hardLinkAct( o )
{
  let self = this;

  _.assertRoutineOptions( hardLinkAct, arguments );
  _.assert( self.path.isNormalized( o.srcPath ) );
  _.assert( self.path.isNormalized( o.dstPath ) );
  _.assert( 0, 'not implemented' );

}

_.routineExtend( hardLinkAct, Parent.prototype.hardLinkAct );

// --
// link
// --

function hardLinkBreakAct( o )
{
  let self = this;
  let descriptor = self._descriptorRead( o.filePath );

  _.assert( 0, 'not implemented' );

}

_.routineExtend( hardLinkBreakAct, Parent.prototype.hardLinkBreakAct );

//

function areHardLinkedAct( o )
{
  let self = this;

  _.assert( 0, 'not implemented' );

  return false;
}

_.routineExtend( areHardLinkedAct, Parent.prototype.areHardLinkedAct );

// --
// relationship
// --

let Composes =
{

  protocols : _.define.own( [ 'imap' ] ),

  login : null,
  password : null,
  hostUri : null,
  authTimeOut : 5000,
  tls : true,
  // tls : false,

}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
  ready : null,
  _connection : null,
  _currentPath : null,
  _formed : 0,
}

let Accessors =
{
}

let Statics =
{
  Path : _.uri.CloneExtending({ fileProvider : Self }),
}

// --
// declare
// --

let Extension =
{

  // inter

  init,
  form,
  unform,

  // path

  pathCurrentAct,
  pathResolveSoftLinkAct,
  pathParse,

  // read

  fileReadAct,
  dirReadAct,
  streamReadAct : null,
  statReadAct,
  fileExistsAct,

  // write

  fileWriteAct,
  timeWriteAct : null,
  fileDeleteAct,
  dirMakeAct,
  streamWriteAct : null,

  // linking

  fileRenameAct,
  fileCopyAct,
  softLinkAct,
  hardLinkAct,

  hardLinkBreakAct,
  areHardLinkedAct,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Accessors,
  Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extension,
});

_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
