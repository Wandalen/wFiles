( function _RemoteServlet_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      toolsPath = require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }
  var _global = _global_;
  var _ = _global_.wTools;

  _.include( 'wFiles' );
  _.include( 'wServlet' );
  _.include( 'wCommunicator' );

  var Https = require( 'https' );
  var Http = require( 'http' );
  var Express = require( 'express' );

  Express.Logger = require( 'morgan' );
  /* Express.Directory = require( 'serve-index' ); */

}
var _global = _global_;
var _ = _global_.wTools;

//

var Parent = null;
var Self = function wRemoteServerForFileProvider( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'RemoteServerForFileProvider';

// --
// inter
// --

function init( o )
{
  var self = this;

  _.instanceInit( self );

  if( self.Self === Self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

}

//

function form()
{
  var self = this;

  _.assert( arguments.length === 0 );

  if( !self.fileProvider )
  self.fileProvider = _.fileProvider;

  self.communicator = wCommunicator
  ({
    verbosity : 5,
    isMaster : 1,
    url : self.url,
  })

  self.communicator.form();

  return self;
}

// function form()
// {
//   var self = this;
//
//   _.assert( arguments.length === 0 );
//
//   if( !self.fileProvider )
//   self.fileProvider = _.fileProvider;
//
//   /* */
//
//   if( !self.express )
//   self.express = Express();
//   var express = self.express;
//
//   _.servlet.controlLoggingPre.call( self );
//
//   /* */
//
//   if( self.defaultMime )
//   Express.static.mime.default_type = self.defaultMime;
//
//   /* */
//
//   _.servlet.controlPathesNormalize.call( self );
//
//   self.path = self.path.join( self.path.pathCurrent(),self.path );
//
//   /* */
//
//   if( self.port )
//   express.use( _.routineJoin( self,self.requestPreHandler ) );
//
//   if( self.port )
//   {
//     if( Config.debug && self.verbosity )
//     express.use( Express.Logger( 'dev' ) );
//   }
//
//   // express.use( self.url,Express.static( self.path ) );
//   // express.use( self.url,Express.Directory( self.path,self.directoryOptions ) );
//
//   express.use( _.routineJoin( self,self.requestHandler ) );
//
//   if( self.port )
//   express.use( _.routineJoin( self,self.requestPostHandler ) );
//
//   /* */
//
//   _.servlet.controlLoggingPost.call( self );
//   _.servlet.controlExpressStart.call( self );
//
//   /* */
//
//   return self;
// }

//

function exec()
{
  _.assert( !_.instanceIs( this ) );

  var self = new _.constructorGet( this )();
  var args = _.appArgs();

  if( args.subject )
  self.path = self.path.join( self.path.current(), args.subject );

  return self.form();
}

// --
//
// --

function requestPreHandler( request, response, next )
{
  var self = this;

  _.servlet.controlRequestPreHandle.call( self, request, response, next );

  next();
}

//

function requestHandler( request, response, next )
{
  var self = this;

  debugger;

}

//

function requestPostHandler( request, response, next )
{
  var self = this;

  _.servlet.controlRequestPostHandle.call( self, request, response, next );

}

// --
// relationship
// --

var Composes =
{
  name : Self.name,
  verbosity : 1,
  path : '.',
  url : 'tcp://127.0.0.1:61726',
  // port : 0xF11E,
  // usingHttps : 0,
  // allowCrossDomain : 1,
}

var Aggregates =
{
}

var Associates =
{
  fileProvider : null,
  communicator : null,
  // express : null,
  // server : null,
}

var Restricts =
{
}

var Statics =
{
  exec : exec,
}

// --
// prototype
// --

var Proto =
{

  // inter

  init : init,
  form : form,
  exec : exec,

  requestPreHandler : requestPreHandler,
  requestHandler : requestHandler,
  requestPostHandler : requestPostHandler,

  //


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.Copyable.mixin( Self );

//

_global_[ Self.name ] = _[ Self.shortName ] = Self;

if( typeof module !== 'undefined' && !module.parent )
_global_.server = Self.exec();

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
