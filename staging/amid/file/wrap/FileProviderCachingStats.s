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
  Parent.prototype.init.call( self,o );

  if( !self.originalProvider )
  self.originalProvider = _.FileProvider.Default();
}

//

function fileStat( o )
{
  var self = this;
  var o = _._fileOptionsGet.apply( fileStat,arguments );

  var pathFile = _.pathResolve( o.pathFile );

  if( self._cache[ pathFile ] )
  {
    if( o.sync )
    return self._cache[ pathFile ];
    else
    return new wConsequence().give( self._cache[ pathFile ] );
  }
  else
  {
    var stat = this.originalProvider.fileStat( o );

    if( o.sync )
    {
      self._cache[ pathFile ] = stat;
      return stat;
    }
    else
    {
      return stat.doThen( function( err, data )
      {
        if( err )
        throw err;
        self._cache[ pathFile ] = data;
        return data;
      });
    }

  }

}

fileStat.defaults = Parent.prototype.fileStat.defaults;

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

  //

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
