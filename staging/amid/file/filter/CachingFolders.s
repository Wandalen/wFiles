( function _CachingFolders_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../aprovider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.CachingFolders )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCachingFolders( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCachingFolders without new please' );
}

Self.nameShort = 'CachingFolders';

//

function init( o )
{

  var self = _.instanceFilterInit
  ({
    constructor : Self,
    parent : Parent,
    extend : Extend,
    args : arguments,
  });

  // x
  //
  // var self = Object.create( null );
  //
  // _.instanceInit( self,Self.prototype );
  //
  // if( o )
  // Self.prototype.copyCustom.call( self,
  // {
  //   proto : Self.prototype,
  //   src : o,
  //   technique : 'object',
  // });
  //
  // if( !self.original )
  // self.original = _.FileFilter.Caching();
  //
  // _.mapExtend( self,Extend );
  //
  // Object.setPrototypeOf( self,self.original );
  // Object.preventExtensions( self );

  return self;
}

//

function cache( path )
{
  var self = this;

  console.log( "Caching folders tree using path:", path );
  self._tree = Object.create( null );

  var files = self.original.filesFind({ filePath : path, recursive : 1 } );

  for( var i = 0; i < files.length; ++i )
  {
    var query = _.pathDir( files[ i ].real );
    var dir = _.entitySelect({ container : self._tree, query : query });
    dir = _.arrayAs( dir );
    dir.push( files[ i ].nameWithExt );
    _.entitySelect({ container : self._tree, query : query, set : dir, usingSet : 1 });
  }
}

//

function _select( path )
{
  var self = this;
  console.log(path);
  return _.entitySelect({ container : self._tree, query : path });
}

//

function directoryRead( o )
{
  var self = this;

  // if( !self.cachingDirs )
  // return self.original.directoryRead( o );

  var result = self._select( o );
  if( result !== undefined )
  {
    console.log("Finded in first attempt");
    return result;
  }
  else
  {
    if( _.strIs( o ) )
    {
      o = _.pathResolve( o );
      var result = self._select( o );
      if( result !== undefined )
      {
        console.log("Finded in second attempt");
        return result;
      }
    }
    else if( _.objectIs( o ) )
    {
      o = _.routineOptions( directoryRead,o )
      o.filePath = _.pathResolve( o.filePath );

      var result = self._select( o.filePath );

      if( result )
      {
        console.log("Finded in third attempt");

        if( o.sync )
        return result
        else
        return wConsequence().give( result );
      }
    }

    return result;

    // // console.log( 'directoryRead' );
    // var files = self.original.directoryRead( o );
    //
    // // console.log( o );
    //
    // if( _.strIs( o ) )
    // self._cacheDir[ o ] = files;
    // else
    // {
    //   if( o.sync )
    //   self._cacheDir[ o.filePath ] = files;
    //   else
    //   files.doThen( function( err, got )
    //   {
    //     self._cacheDir[ o.filePath ] = got;
    //     if( err )
    //     throw err;
    //     return got;
    //   });
    // }
    //
    // // console.log( 'self._cache',self._cache );
    //
    // return files;

    // if( o.sync )
    // {
    //   self._cache[ filePath ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ filePath ] = got;
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
  _tree : null,
}

// --
// prototype
// --

var Extend =
{
  _select : _select,
  directoryRead : directoryRead,
  cache : cache,
}

//

var Proto =
{

  init : init,

  //


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.mapExtend( Proto,Extend );

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

_.FileFilter.CachingFolders = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
