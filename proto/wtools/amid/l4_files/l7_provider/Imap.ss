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

  return _.Consequence.Try( () => Imap.connect( config ) )
  .then( function( connection )
  {
    self._connection = connection;
    self.ready.take( connection );
    return connection;
  })
  // return _.Consequence.Try( () => Imap.connect( config ) )
  // .then( function( connection )
  // {
  //
  //   self._connection = connection;
  //
  //   // return connection.openBox( 'INBOX' ).then( function()
  //   // {
  //   //   let searchCriteria = [ 'UNSEEN' ];
  //   //
  //   //   let fetchOptions =
  //   //   {
  //   //     bodies : [ 'HEADER', 'TEXT' ],
  //   //     markSeen : false
  //   //   };
  //   //
  //   //   return connection.search( searchCriteria, fetchOptions ).then( function( results )
  //   //   {
  //   //     let subjects = results.map( function( res )
  //   //     {
  //   //       return res.parts.filter( function( part )
  //   //       {
  //   //         return part.which === 'HEADER';
  //   //       })[ 0 ].body.subject[ 0 ];
  //   //     });
  //   //     console.log( subjects );
  //   //     self.ready.take( subjects );
  //   //   });
  //   //
  //   // });
  //
  //   self.ready.take( connection );
  //
  //   return connection;
  // })
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

  let filePath = path.unabsolute( o.filePath );
  let dirPath = path.dir( filePath );
  let name = path.name( o.filePath );

  _.assert( _.strBegins( name, '@' ) );
  name = _.strRemoveBegin( name, '@' );

  ready.then( () => _read( o.filePath ) );
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
    return self._connection.openBox( dirPath ).then( function ()
    {
      let searchCriteria = [ `${name}` ];
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
      };
      return self._connection.search( searchCriteria, fetchOptions ).then( function( messages )
      {
        _.assert( messages.length === 1 );
        result = messages[ 0 ];
        resultHandle( result );
      });
    });
  }

  /* */

  function resultHandle( result )
  {
    debugger;
    if( o.advanced.withHeader )
    {
      result.header = Object.create( null );
      let headers = result.parts.filter( ( e ) => e.which === 'HEADER' );
      headers.forEach( ( header ) =>
      {
        _.mapExtend( result.header, header );
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

  function _mailsRead( filePath )
  {
    if( result === null )
    return result;
    if( filePath === '/' )
    return result;

    filePath = path.unabsolute( filePath );
    return self._connection.openBox( filePath ).then( function ()
    {
      let searchCriteria = [ 'ALL' ];
      let fetchOptions =
      {
        bodies : [ 'HEADER' ],
        struct : false,
        // bodies : [ 'HEADER', 'TEXT', '' ],
        // struct : true,
      };
      return self._connection.search( searchCriteria, fetchOptions ).then( function( messages )
      {
        messages.forEach( function( message, k )
        {
          debugger;
          // let mid = message.parts[ 0 ].body[ 'message-id' ][ 0 ];
          let mid = message.attributes.uid;
          _.assert( _.numberIs( mid ) );
          debugger;
          _.arrayAppendOnceStrictly( result, '@' + String( mid ) );
          debugger;
        });
      });
    });

  }

  function filter( map )
  {
    // console.log( 0 ? self._connection : 0 );
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

}

_.routineExtend( dirReadAct, Parent.prototype.dirReadAct );

// --
// read stat
// --

function statReadAct( o )
{
  let self = this;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( statReadAct, o );
  _.assert( 0, 'not implemented' );

  /* */

  if( o.sync )
  {
    return _statReadAct( o.filePath );
  }
  else
  {
    return _.time.out( 0, function()
    {
      return _statReadAct( o.filePath );
    })
  }

  /* */

  function _statReadAct( filePath )
  {
    let result = null;

    if( o.resolvingSoftLink )
    {

      let o2 =
      {
        filePath,
        resolvingSoftLink : o.resolvingSoftLink,
        resolvingTextLink : 0,
      };

      filePath = self.pathResolveLinkFull( o2 ).absolutePath;
      _.assert( o2.stat !== undefined );

      if( !o2.stat && o.throwing )
      throw _.err( 'File', _.strQuote( filePath ), 'doesn`t exist!' );

      return o2.stat;
    }
    else
    {
      filePath = self._pathResolveIntermediateDirs( filePath );
    }

    let d = self._descriptorRead( filePath );

    if( !_.definedIs( d ) )
    {
      if( o.throwing )
      throw _.err( 'File', _.strQuote( filePath ), 'doesn`t exist!' );
      return result;
    }

    result = new _.FileStat();

    if( self.extraStats && self.extraStats[ filePath ] )
    {
      let extraStat = self.extraStats[ filePath ];
      result.atime = new Date( extraStat.atime );
      result.mtime = new Date( extraStat.mtime );
      result.ctime = new Date( extraStat.ctime );
      result.birthtime = new Date( extraStat.birthtime );
      result.ino = extraStat.ino || null;
      result.dev = extraStat.dev || null;
    }

    result.filePath = filePath;
    result.isTerminal = returnFalse;
    result.isDir = returnFalse;
    result.isTextLink = returnFalse; /* qqq : implement and add coverage, please */
    result.isSoftLink = returnFalse;
    result.isHardLink = returnFalse; /* qqq : implement and add coverage, please */
    result.isFile = returnFalse;
    result.isDirectory = returnFalse;
    result.isSymbolicLink = returnFalse;
    result.nlink = 1;

    if( self._DescriptorIsDir( d ) )
    {
      result.isDirectory = returnTrue;
      result.isDir = returnTrue;
    }
    else if( self._DescriptorIsTerminal( d ) || self._DescriptorIsHardLink( d ) )
    {
      if( self._DescriptorIsHardLink( d ) )
      {
        if( _.arrayIs( d[ 0 ].hardLinks ) )
        result.nlink = d[ 0 ].hardLinks.length;

        d = d[ 0 ].data;
        result.isHardLink = returnTrue;
      }

      result.isTerminal = returnTrue;
      result.isFile = returnTrue;

      if( _.numberIs( d ) )
      result.size = String( d ).length;
      else if( _.strIs( d ) )
        result.size = d.length;
      else
        result.size = d.byteLength;

      _.assert( result.size >= 0 );

      result.isTextLink = function isTextLink()
      {
        if( !self.usingTextLink )
        return false;
        return self._DescriptorIsTextLink( d );
      }
    }
    else if( self._DescriptorIsSoftLink( d ) )
    {
      result.isSymbolicLink = returnTrue;
      result.isSoftLink = returnTrue;
    }
    else if( self._DescriptorIsHardLink( d ) )
    {
      _.assert( 0 );
    }
    else if( self._DescriptorIsScript( d ) )
    {
      result.isTerminal = returnTrue;
      result.isFile = returnTrue;
    }

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
