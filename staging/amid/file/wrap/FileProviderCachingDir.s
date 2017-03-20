( function _FileProviderCachingDir_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

// if( wTools.FileProvider.CachingDir )
// return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
/*var Parent = _.FileProvider.Default;*/
var Parent = null;
var Self = function wFileProviderCachingDir( o )
{

  if( !( this instanceof Self ) )
  // if( o instanceof Self )
  // return o;
  // else
  return Self.prototype.init.apply( this,arguments );
  // return new( _.routineJoin( Self, Self, arguments ) );

  throw _.err( 'Call wFileProviderCachingDir without new please' );
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

function directoryRead( o )
{
  var self = this;
  // var original = self.original.directoryRead;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var pathFile = o;

  // debugger;

  if( self._cache[ o ] !== undefined )
  {
    // if( o.sync )
    return self._cache[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cache[ o ] !== undefined )
      return  self._cache[ o ];
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( directoryRead,o )
      // o = _.pathResolve( o );
      o.pathFile = _.pathResolve( o.pathFile );
      if( self._cache[ o.pathFile ] )
      {
        if( o.sync )
        return self._cache[ o.pathFile ];
        else
        return wConsequence().give( self._cache[ o.pathFile ] );
      }
    }

    // console.log( 'directoryRead' );
    var files = self.original.directoryRead( o );

    // console.log( o );

    if( _.strIs( o ) )
    self._cache[ o ] = files;
    else
    {
      if( o.sync )
      self._cache[ o.pathFile ] = files;
      else
      files.doThen( function( err, got )
      {
        self._cache[ o.pathFile ] = got;
        if( err )
        throw err;
        return got;
      });
    }

    // console.log( 'self._cache',self._cache );

    return files;

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

directoryRead.defaults = {};
directoryRead.defaults.__proto__ = Abstract.prototype.directoryRead.defaults;

// --
// relationship
// --

var Composes =
{
  original : null,
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
  _cache : Object.create( null ),
}

// --
// prototype
// --

var Extend =
{

  directoryRead : directoryRead,

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
_.FileProvider.CachingDir = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
