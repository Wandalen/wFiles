( function _CachingContent_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../aprovider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.CachingFiles )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCachingContent( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCachingContent without new please' );
}

Self.nameShort = 'CachingContent';

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

  var o = _._fileOptionsGet.apply( fileRead,arguments );
  var filePath = _.pathResolve( o.filePath );

  if( self._cache[ filePath ] )
  {
    if( o.onEnd )
    o.onEnd( null,self._cache[ filePath ] );
    if( o.returnRead )
    return self._cache[ filePath ];
    else
    return new wConsequence().give( self._cache[ filePath ] );
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

fileRead.defaults = Abstract.prototype.fileRead.defaults;

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
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter.CachingFiles = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
