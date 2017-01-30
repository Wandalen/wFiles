( function _FileProviderCachingFiles_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

if( wTools.FileProvider.CachingFiles )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Parent = _.FileProvider.Default;
var Self = function wFileProviderCachingFiles( o )
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

var fileRead = function( o )
{
  var self = this;
  var result;

  var o = _._fileOptionsGet.apply( fileRead,arguments );
  var pathFile = _.pathResolve( o.pathFile );

  if( self._cache[ pathFile ] )
  {
    if( o.onEnd )
    o.onEnd( null,self._cache[ pathFile ] );
    if( o.returnRead )
    return self._cache[ pathFile ];
    else
    return new wConsequence().give( self._cache[ pathFile ] );
  }

  if( o.sync )
  {
    result = Parent.prototype.fileRead( o );
    self._cache[ pathFile ] = result;
  }
  else
  {
    throw _.err( 'not tested' );
    var onEnd = o.onEnd;
    o.onEnd = function( err,data )
    {
      if( !err )
      self._cache[ pathFile ] = data;
    }
    Parent.prototype.fileRead( o );
  }

  return result;
}

fileRead.defaults = Abstract.prototype.fileRead.defaults;

fileRead.isOriginalReader = 1;

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
  _cache : [],
}

// --
// prototype
// --

var Proto =
{

  init : init,

  fileRead : fileRead,

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
_.FileProvider.CachingFiles = Self;

// debugger;
// var p = new Self();
// console.log( 'p instanceof _.FileProvider.Abstract',p instanceof _.FileProvider.Abstract );
// debugger;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
