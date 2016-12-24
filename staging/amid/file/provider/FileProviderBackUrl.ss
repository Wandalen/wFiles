( function _FileProviderBackUrl_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './Abstract.s' );

}

if( wTools.FileProvider.BackUrl )
return;

//

var _ = wTools;
var http = require( 'http' );
var Parent = _.FileProvider.Abstract;
var Self = function wFileProviderBackUrl( o )
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

//

var createReadStreamAct = function( o )
{
  var self = this;

  if( _.strIs( o ) )
  {
    o = { pathFile : o };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'fileReadAct :','expects ( o.pathFile )' );

  var con = new wConsequence();

  http.get( o.pathFile, function( res )
  {
    con.give( res );
  });
  return con;
}
createReadStreamAct.defaults =
{
  pathFile : null,

}

//

var fileReadAct = function( o )
{
  var self = this;
  var con = new wConsequence();

  if( _.strIs( o ) )
  {
    var pathFile = _.pathJoin( __dirname, _.pathName( o, { withoutExtension : false } ) );
    o = { url : o, pathFile : pathFile };
  }

  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ),'fileReadAct :','expects ( o.pathFile )' );
  _.assert( !o.sync,'fileReadAct :','synchronous version is not implemented' );

  /* begin */

 var HardDrive = _.FileProvider.HardDrive();
 var writeStream = HardDrive.createWriteStreamAct({ pathFile : o.pathFile, sync : o.sync });

 writeStream.on('finish', function()
 {
   con.give( o.pathFile );
 });

 self.createReadStreamAct( o.url )
 .got( function (res)
 {
   console.log(res);
 })
 //
 // res.pipe( writeStream );
 // res.on( 'error', function( err )
 // {
 //   HardDrive.unlinkSync( o.pathFile );
 //   con.error( err );
 // });



 writeStream.on('error', function( err )
 {
   HardDrive.unlinkSync( o.pathFile );
   con.error( err );
 });

 return con;
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;

fileReadAct.advanced =
{
  send : null,
  method : 'GET',
  user : null,
  password : null,

}

fileReadAct.isOriginalReader = 1;

// --
// encoders
// --

var encoders = {};

encoders[ 'utf8' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'text';
  },

}

encoders[ 'arraybuffer' ] =
{

  onBegin : function( e )
  {
    e.transaction.encoding = 'arraybuffer';
  },

}

encoders[ 'blob' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'blob';
  },

}

encoders[ 'document' ] =
{

  onBegin : function( e )
  {
    debugger;
    throw _.err( 'not tested' );
    e.transaction.encoding = 'document';
  },

}

fileReadAct.encoders = encoders;

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

  fileReadAct : fileReadAct,
  createReadStreamAct : createReadStreamAct,

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
_.FileProvider.BackUrl = Self;

if( typeof module === 'undefined' )
if( !_.FileProvider.def )
_.FileProvider.def = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
