( function _FileProviderCachingStats_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

// if( wTools.FileProvider.CachingStats )
// return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
/*var Parent = _.FileProvider.Default;*/
var Parent = null;
var Self = function wFileProviderCachingStats( o )
{

  if( !( this instanceof Self ) )
  // if( o instanceof Self )
  // return o;
  // else
  return Self.prototype.init.apply( this,arguments );
  // return new( _.routineJoin( Self, Self, arguments ) );

  throw _.err( 'Call wFileProviderCachingStats without new please' );
  // return Self.prototype.init.apply( this,arguments );
}

//

function init( o )
{
  var self = Object.create( null );

  _.instanceInit( self,Self.prototype );

  if( o )
  Self.prototype.copyCustom.call( self,
  {
    proto : Self.prototype,
    src : self,
    technique : 'object',
  });

  if( !self.original )
  self.original = _.FileProvider.Default();

  _.mapExtend( self,Extend );

  Object.setPrototypeOf( self,self.original );

  Object.preventExtensions( self );

  return self;
}

//

function _getCache( o )
{
  var self = this;

  if( o.sync === undefined || o.sync )
  return  self._cache[ o.pathFile ];
  else
  return new wConsequence().give( self._cache[ o.pathFile ] );
}

//

function fileStat( o )
{
  var self = this;

  var useNativePath = o.useNativePath;
  delete o.useNativePath;

  if( _.strIs( o ) )
  {
    o = { pathFile : o }
  }

  if( !useNativePath )
  o.pathFile = _.pathResolve( o.pathFile );

  if( self._cache[ o.pathFile ] )
  return self._getCache( o );
  else
  {
    o = _.routineOptions( fileStat, o );
    o.pathFile = _.pathResolve( o.pathFile );

    if( self._cache[ o.pathFile ] )
    return self._getCache( o );

    var p = o.pathFile;

    var stat = self.original.fileStat( o );

    if( !useNativePath )
    o.pathFile = p;

    if( o.sync )
    self._cache[ o.pathFile ] = stat;
    else
    {
      stat.doThen( function( err, got )
      {
        self._cache[ o.pathFile ] = got;
        return stat.give( err, got );
      });
    }
    return stat;
  }
}

fileStat.defaults = {};
fileStat.defaults.__proto__ = Abstract.prototype.fileStat.defaults;

// --
// relationship
// --

var Composes =
{
  original : null,
  useNativePath : true
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

var Extend =
{

  fileStat : fileStat,

  //etc

  _getCache : _getCache,

}

var Proto =
{

  init : init,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

_.mapExtend( Proto,Extend );

//

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

wCopyable.mixin( Self );

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.CachingStats = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
