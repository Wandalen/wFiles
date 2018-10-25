( function _Git_ss_( ) {

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
let Git;

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
  if( self.claimMap )
  self.claimEnd();
  Parent.prototype.finit.call( self );
}

//

function init( o )
{
  let self = this;
  if( !Git )
  Git = require( 'simple-git/promise' );
  Parent.prototype.init.call( self,o );

  // if( !self.claimProvider )
  // self.claimProvider = new _.FileProvider.Default();

}

// //
//
// function claimEndAct( o )
// {
//   let self = this;
//
//   if( _.strIs( o ) )
//   o = { filePath : o }
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.filePath ) );
//   _.assert( !!self.claimMap[ o.filePath ] );
//
//   let claim = self.claimMap[ o.filePath ];
//   if( claim.tempOpened )
//   self.claimProvider.path.dirTempClose( claim.tempPath )
//   delete self.claimMap[ o.filePath ];
//
// }
//
// //
//
// function claimBeginAct( o )
// {
//   let self = this;
//   let path = self.path;
//
//   if( _.strIs( o ) )
//   o = { filePath : o }
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.filePath ) );
//   _.sure( ( !o.login && !o.password ) || ( _.strIs( o.login ) && _.strIs( o.password ) ) );
//   _.assert( !self.claimMap[ o.filePath ] );
//
//   if( !o.tempPath )
//   {
//     let dir = self.claimProvider.path.resolve( 'module' );
//     o.tempPath = self.claimProvider.path.dirTempOpen( dir, 'git-' + _.idWithGuid( o.filePath ) );
//     o.tempOpened = 1;
//     _.assert( self.claimProvider.directoryIsEmpty( o.tempPath ) );
//   }
//
// /*
//   git+https:///github.com/user/name.git/staging
// */
//
//   let prefix = '';
//   if( o.login && o.password )
//   prefix = o.login + ':' + o.password + '@';
//
//   let filePath = path.join( prefix, o.filePath );
//   filePath = filePath.replace( /^git\+/, '' )
//
//   try
//   {
//
//     self.claimProvider.directoryMake( o.tempPath );
//     debugger;
//     let promise = Git( self.claimProvider.path.nativize( o.tempPath ) ).silent( true ).clone( filePath );
//     _.assert( _.promiseLike( promise ) );
//     o.con = _.Consequence.From( promise );
//     o.ready = 0;
//     o.times = 1;
//
//     self.claimMap[ o.filePath ] = o;
//
//     // o.con.sleep();
//
//     return o.con.doThen( ( err, arg ) =>
//     {
//       debugger;
//       o.ready = 1;
//       if( err )
//       errorHandle( err );
//     });
//
//   }
//   catch( err )
//   {
//     errorHandle( err );
//   }
//
//   function errorHandle( err )
//   {
//     delete self.claimMap[ o.filePath ];
//     throw _.err( err );
//   }
//
// }
//
// claimBeginAct.defaults =
// {
//   filePath : null,
//   tempPath : null,
//   login : null,
//   password : null,
//   repository : null,
// }

// --
// path
// --

function localFromGlobal( uri )
{
  let self = this;
  let path = self.path;
  return path.str( uri );
}

// --
// link
// --

function pathResolveSoftLinkAct( o )
{
  let self = this;
  let claim = self.claimBegin({ filePath : o.filePath, sync : 1 });

  debugger; xxx

  _.sure( _.strIs( claim.tempPath ), 'Cant claim', o.filePath );

  self.claimProvider.pathResolveSoftLinkAct( claim.tempPath );

  return resolved;
}

_.routineExtend( pathResolveSoftLinkAct, Parent.prototype.pathResolveSoftLinkAct )

// --
// read
// --

function fileReadAct( o )
{
  let self = this;
  let con = new _.Consequence();

  _.assertRoutineOptions( fileReadAct, arguments );
  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ),'fileReadAct :','expects {-o.filePath-}' );
  _.assert( _.strIs( o.encoding ),'fileReadAct :','expects {-o.encoding-}' );
  _.assert( !o.sync,'sync version is not implemented' );

  o.encoding = o.encoding.toLowerCase();
  let encoder = fileReadAct.encoders[ o.encoding ];

  debugger; xxx

  logger.log( 'fileReadAct',o );

  /* */

  let result = null;;
  let totalSize = null;
  let dstOffset = 0;

  if( encoder && encoder.onBegin )
  _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder }) === undefined );

  self.streamReadAct({ filePath :  o.filePath })
  .got( function( err, response )
  {
    debugger;

    if( err )
    return handleError( err );

    _.assert( _.strIs( o.encoding ) || o.encoding === null );

    if( o.encoding === null )
    {
      totalSize = response.headers[ 'content-length' ];
      result = new ArrayBuffer( totalSize );
    }
    else
    {
      response.setEncoding( o.encoding );
      result = '';
    }

    response.on( 'data', onData );
    response.on( 'end', onEnd );
    response.on( 'error', handleError );
    debugger;

  });

  return con;

  /* */

  function onEnd()
  {
    if( o.encoding === null )
    _.assert( _.bufferRawIs( result ) );
    else
    _.assert( _.strIs( result ) );

    let context = { data : result, operation : o, encoder : encoder };
    if( encoder && encoder.onEnd )
    _.sure( encoder.onEnd.call( self,context ) === undefined );
    result = context.data

    con.give( result );
  }

  /* on encoding : arraybuffer or encoding : buffer should return buffer( in consequence ) */

  function handleError( err )
  {

    if( encoder && encoder.onError )
    try
    {
      err = _._err
      ({
        args : [ stack,'\nfileReadAct( ',o.filePath,' )\n',err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self,{ error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.sync )
    {
      throw err;
    }
    else
    {
      con.error( err );
    }
  }

  /* */

  function onData( data )
  {

    if( o.encoding === null )
    {
      _.bufferMove
      ({
        dst : result,
        src : data,
        dstOffset : dstOffset
      });

      dstOffset += data.length;
    }
    else
    {
      result += data;
    }

  }

}

_.routineExtend( fileReadAct, Parent.prototype.fileReadAct );

fileReadAct.advanced =
{
  user : null,
  password : null,
}

//

function _filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assertRoutineOptions( _filesReflectSingle_body, o );
  _.assert( o.mandatory === undefined )
  _.assert( arguments.length === 1, 'expects single argument' );

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

  srcPath = srcPath.replace( /^git\+/, '' )

  _.sure( _.strIs( srcPath ) );
  _.sure( _.strIs( dstPath ) );
  _.sure( dstFileProvider instanceof _.FileProvider.HardDrive, 'Support only downloading on hard drive' );
  _.sure( !o.srcFilter || o.srcFilter.isEmpty(), 'Does not support filtering, but {o.srcFilter} is not empty' );
  _.sure( !o.dstFilter || o.dstFilter.isEmpty(), 'Does not support filtering, but {o.dstFilter} is not empty' );
  _.sure( !o.filter || o.filter.isEmpty(), 'Does not support filtering, but {o.filter} is not empty' );

  // logger.log( 'srcPath', srcPath );
  // logger.log( 'dstPath', dstPath );

  dstFileProvider.filesDelete( dstPath );
  dstFileProvider.directoryMake( dstPath );

  debugger;
  let promise = Git( dstFileProvider.path.nativize( dstPath ) ).silent( true ).clone( srcPath );
  debugger;
  _.assert( _.promiseLike( promise ) );
  let result = _.Consequence.From( promise );

  // let o2 = _.mapOnly( o, self.filesReflectEvaluate.body.defaults );
  // o2.outputFormat = 'record';
  // _.assert( _.arrayIs( o2.result ) );
  // _.assert( o2.result === o.result );

  return result;
}

_.routineExtend( _filesReflectSingle_body, _.FileProvider.Find.prototype.filesReflectSingle );

var defaults = _filesReflectSingle_body.defaults;

let filesReflectSingle = _.routineForPreAndBody( _.FileProvider.Find.prototype.filesReflectSingle.pre, _filesReflectSingle_body );

// --
// encoders
// --

let WriteEncoders = {};

WriteEncoders[ 'utf8' ] =
{

  onBegin : function( e )
  {
    e.operation.encoding = 'utf8';
  },

}

//

WriteEncoders[ 'buffer.bytes' ] =
{

  responseType : 'arraybuffer',

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    let result = _.bufferBytesFrom( e.data );
    return result;
  },

}

fileReadAct.encoders = WriteEncoders;

// --
// relationship
// --

let Composes =
{

  safe : 0,
  protocols : _.define.own([ 'git', 'git+http', 'git+https' ]),

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
  claimMap : 'claimMap',
  claimProvider : 'claimProvider'
}

// --
// declare
// --

let Proto =
{

  finit : finit,
  init : init,

  // claimEndAct : claimEndAct,
  // claimBeginAct : claimBeginAct,

  // path

  localFromGlobal : localFromGlobal,

  // link

  pathResolveSoftLinkAct : pathResolveSoftLinkAct,

  // read

  fileReadAct : fileReadAct,

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
