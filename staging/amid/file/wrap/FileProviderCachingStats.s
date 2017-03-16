( function _FileProviderCachingStats_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

if( wTools.FileProvider.CachingStats )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Parent = null;
var Self = function wFileProviderCachingStats( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

function init( o )
{
  var self = this;

  _.instanceInit( self );

  if( !self.originalProvider )
  self.originalProvider = _.FileProvider.Default();

  // Object.preventExtensions( self );

  if( o )
  self.copy( o );

  return self;
}

//

function fileStat( o )
{
  var self = this;
  var original = self.originalProvider.fileStat;

  var o = _._fileOptionsGet.apply( original,arguments );
  var pathFile = _.pathResolve( o.pathFile );

  debugger;
  var stat = original.call( self.originalProvider, o );

  if( o.sync )
  {
    self._cache[ pathFile ] = stat;
    return stat;
  }
  else
  {
    return stat.doThen( function( err, got )
    {
      if( err )
      throw err;
      self._cache[ pathFile ] = got;
      return got;
    })
  }
}

fileStat.defaults = {};
fileStat.defaults.__proto__ = Abstract.prototype.fileStat.defaults;

// --
// relationship
// --

var Composes =
{
  originalProvider : null,
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

  fileStat : fileStat,

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
_.FileProvider.CachingStats = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
