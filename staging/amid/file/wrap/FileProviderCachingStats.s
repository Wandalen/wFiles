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

function _f( gen )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( _f,gen );

  var nameOfMethod = gen.nameOfMethod;

  function f( o )
  {
    var self = this;
    var o = _._fileOptionsGet.apply( self[ nameOfMethod ],arguments );
    var statOptions = _._fileOptionsGet.call( fileStat,{ pathFile : o.pathFile, sync : o.sync });

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
      var stat = this.originalProvider.fileStat( statOptions );
      var result = this.originalProvider[ nameOfMethod ].apply( this.originalProvider, arguments );

      if( o.sync )
      {
        self._cache[ pathFile ] = stat;
        return result;
      }
      else
      {
        return stat.doThen( function( err, data )
        {
          if( err )
          throw err;
          self._cache[ pathFile ] = data;
        })
        .doThen( function ()
        {
          return result;
        })
      }
    }
  }

  return f;
}

_f.defaults =
{
  nameOfMethod : null
}


var fileRead = _f({ nameOfMethod : 'fileRead' });

fileRead.defaults = Parent.prototype.fileRead.defaults;

//

var fileStat = _f({ nameOfMethod : 'fileStat' });

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

  _f : _f,

  //

  fileRead : fileRead,
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
