( function _FileProviderCaching_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

// if( wTools.FileProvider.Caching )
// return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
/*var Parent = _.FileProvider.Default;*/
var Parent = null;
var Self = function wFileProviderCaching( o )
{

  if( !( this instanceof Self ) )
  // if( o instanceof Self )
  // return o;
  // else
  return Self.prototype.init.apply( this,arguments );
  // return new( _.routineJoin( Self, Self, arguments ) );

  throw _.err( 'Call wFileProviderCaching without new please' );
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
    src : o,
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

function fileStat( o )
{
  var self = this;

  if( !self.cachingStats )
  return self.original.fileStat( o );

  // var original = self.original.fileStat;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var pathFile = o;

  // debugger;

  if( self._cacheStats[ o ] !== undefined )
  {
    // if( o.sync )
    return self._cacheStats[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cacheStats[ o ] !== undefined )
      return  self._cacheStats[ o ];
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( fileStat,o )
      // o = _.pathResolve( o );
      o.pathFile = _.pathResolve( o.pathFile );
      if( self._cacheStats[ o.pathFile ] )
      {
        if( o.sync )
        return self._cacheStats[ o.pathFile ];
        else
        return wConsequence().give( self._cacheStats[ o.pathFile ] );
      }
    }

    // console.log( 'fileStat' );
    var stat = self.original.fileStat( o );

    // console.log( o );

    if( _.strIs( o ) )
    self._cacheStats[ o ] = stat;
    else
    {
      if( o.sync )
      self._cacheStats[ o.pathFile ] = stat;
      else
      stat.got( function( err, got )
      {
        self._cacheStats[ o.pathFile ] = got;
        stat.give( err, got );
      });
    }

    // console.log( 'self._cache',self._cache );

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
fileStat.defaults.__proto__ = Abstract.prototype.fileStat.defaults;

//

function directoryRead( o )
{
  var self = this;

  if( !self.cachingDirs )
  return self.original.directoryRead( o );

  // var original = self.original.directoryRead;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var pathFile = o;

  // debugger;

  if( self._cacheDir[ o ] !== undefined )
  {
    // if( o.sync )
    return self._cacheDir[ o ];
    // else
    // return new wConsequence().give( result );
  }
  else
  {

    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      if( self._cacheDir[ o ] !== undefined )
      return  self._cacheDir[ o ];
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( directoryRead,o )
      // o = _.pathResolve( o );
      o.pathFile = _.pathResolve( o.pathFile );
      if( self._cacheDir[ o.pathFile ] )
      {
        if( o.sync )
        return self._cacheDir[ o.pathFile ];
        else
        return wConsequence().give( self._cacheDir[ o.pathFile ] );
      }
    }

    // console.log( 'directoryRead' );
    var files = self.original.directoryRead( o );

    // console.log( o );

    if( _.strIs( o ) )
    self._cacheDir[ o ] = files;
    else
    {
      if( o.sync )
      self._cacheDir[ o.pathFile ] = files;
      else
      files.doThen( function( err, got )
      {
        self._cacheDir[ o.pathFile ] = got;
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
  cachingDirs : 1,
  cachingStats : 1
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
  _cacheStats : Object.create( null ),
  _cacheDir : Object.create( null ),
}

// --
// prototype
// --

var Extend =
{
  fileStat : fileStat,
  directoryRead : directoryRead
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
_.FileProvider.Caching = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
