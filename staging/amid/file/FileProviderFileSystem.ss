(function _FileProviderFileSystem_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileProviderAbstract.s' );

  var Path = require( 'path' );
  var File = require( 'fs-extra' );

}

//

var _ = wTools;
var FileRecord = _.FileRecord;
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderFileSystem( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

var init = function( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
}

// --
// file provider
// --
//
// var fileProviderFileSystem = (function( o )
// {
//
//   var provider =
//   {
//
//     name : 'fileProviderFileSystem',
//
//     fileRead : fileRead,
//     fileWrite : fileWrite,
//
//     filesRead : _.filesRead_gen( fileRead ),
//
//   };
//
//   return fileProviderFileSystem = function( o )
//   {
//     var o = o || {};
//
//     _.assert( arguments.length === 0 || arguments.length === 1 );
//     _.assertMapOnly( o,fileProviderFileSystem.defaults );
//
//     return provider;
//   }
//
// })();
//
// fileProviderFileSystem.defaults = {};

// --
// relationship
// --

var Composes =
{
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  fileRead : _.fileRead,
  fileWrite : _.fileWrite,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.FileSystem = Self;
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
