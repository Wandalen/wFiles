( function _CachingContent_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var _global = _global_;
  var _ = _global_.wTools;

  if( !_.FileProvider.Partial )
  require( './aPartial.s' );

}

var _global = _global_;
var _global = _global_;
var _ = _global_.wTools;
_.assert( !_.FileFilter.CachingContent );

// _.FileFilter = _.FileFilter || Object.create( null );
// if( _.FileFilter.CachingFiles )
// return;

//
var _global = _global_;
var _ = _global_.wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCachingContent( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCachingContent without new please' );
}

Self.shortName = 'CachingContent';

// var Self = function wFileFilterCachingContent( o )
// {
//   if( !( this instanceof Self ) )
//   if( o instanceof Self )
//   return o;
//   else
//   return new( _.routineJoin( Self, Self, arguments ) );
//   return Self.prototype.init.apply( this,arguments );
// }

//

function init( o )
{

  var self = _.instanceFilterInit
  ({
    cls : Self,
    parent : Parent,
    extend : Extend,
    args : arguments,
  });

  return self;
  // var self = this;
  // Parent.prototype.init.call( self,o );
}

//

function fileRead( o )
{
  var self = this;
  var result;

  var o = _.files._fileOptionsGet.apply( fileRead,arguments );
  var filePath = self.path.resolve( o.filePath );

  if( self._cache[ filePath ] )
  {
    if( o.onEnd )
    o.onEnd( null,self._cache[ filePath ] );
    if( o.sync )
    return self._cache[ filePath ];
    else
    return new _.Consequence().give( self._cache[ filePath ] );
  }

  if( o.sync )
  {
    result = self.original.fileRead( o );
    self._cache[ filePath ] = result;
  }
  else
  {
    throw _.err( 'not tested' );
    var onEnd = o.onEnd;
    o.onEnd = function( err,data )
    {
      if( !err )
      self._cache[ filePath ] = data;
    }
    self.original.fileRead( o );
  }

  return result;
}

fileRead.defaults = Partial.prototype.fileRead.defaults;

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
// declare
// --

var Extend =
{
  fileRead : fileRead
}

//

var Proto =
{

  init : init,

  // fileRead : fileRead,

  //

  
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.mapExtend( Proto,Extend );

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
