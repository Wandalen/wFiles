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
var Parent = _.FileProvider.Default;
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

  var self = this;
  Parent.prototype.init.call( self,o );

  if( !self.originalProvider )
  self.originalProvider = _.FileProvider.Default();

  return self;
}

//

function fileStat( o )
{
  var self = this;
  var original = self.originalProvider.fileStat;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var pathFile = o;

  // debugger;

  if( self._cache[ o ] )
  {
    // if( o.sync )
    return  self._cache[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cache[ o ] )
      return  self._cache[ o ];
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( o )
      o = _.pathResolve( o );
      if( self._cache[ o.pathFile ] )
      return  self._cache[ o.pathFile ];
    }

    var stat = self.originalProvider.fileStat( o );

    self._cache[ o ] = stat;
    return stat;

    // if( o.sync )
    // {
    //   self._cache[ pathFile ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ pathFile ] = got;
    //     return got;
    //   })
    // }
  }
}

fileStat.defaults = {};
fileStat.defaults.__proto__ = Parent.prototype.fileStat.defaults;

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
  _cache : {},
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
