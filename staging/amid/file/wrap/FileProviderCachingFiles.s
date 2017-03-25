( function _FileProviderCachingFiles_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.CachingFiles )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileProviderCachingFiles( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileProviderCachingFiles without new please' );
}

// var Self = function wFileProviderCachingFiles( o )
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
    constructor : Self,
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
  var pathFile = _.pathResolve( o.pathFile );

  if( self._cache[ pathFile ] )
  {
    if( o.onEnd )
    o.onEnd( null,self._cache[ pathFile ] );
    if( o.returnRead )
    return self._cache[ pathFile ];
    else
    return new wConsequence().give( self._cache[ pathFile ] );
  }

  if( o.sync )
  {
    result = Parent.prototype.fileRead( o );
    self._cache[ pathFile ] = result;
  }
  else
  {
    throw _.err( 'not tested' );
    var onEnd = o.onEnd;
    o.onEnd = function( err,data )
    {
      if( !err )
      self._cache[ pathFile ] = data;
    }
    Parent.prototype.fileRead( o );
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
  constructor : Self,
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
