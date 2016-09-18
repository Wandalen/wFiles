( function _FileProviderCachingFiles_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileProviderAbstract.s' );

}

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
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
  var o = _._fileOptionsGet.apply( _.fileRead,arguments );
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
    result = _.fileRead( o );
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
    _.fileRead( o );
  }

  return result;
}

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

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
