( function _FileStat_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );

}

//

var _ = wTools;
var Parent = null;
var Self = function wFileStat( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  {
    _.assert( arguments.length === 1 );
    return o;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'FileStat';

// --
//
// --

function init( filePath, o )
{
  var self = this;

  _.instanceInit( self );

  if( o )
  self.copy( o );

  Object.preventExtensions( self );

}

// --
//
// --

var Composes =
{
  dev : null,
  mode : null,
  nlink : null,
  uid : null,
  gid : null,
  rdev : null,
  blksize : null,
  ino : null,
  size : null,
  blocks : null,
  atime : null,
  mtime : null,
  ctime : null,
  birthtime : null,
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{

  _checkModeProperty : null,
  isDirectory : null,
  isFile : null,
  isBlockDevice : null,
  isCharacterDevice : null,
  isSymbolicLink : null,
  isFIFO : null,
  isSocket : null,

}

var Statics =
{
}

// --
// prototype
// --

var Proto =
{

  init : init,

  _checkModeProperty : null,
  isDirectory : null,
  isFile : null,
  isBlockDevice : null,
  isCharacterDevice : null,
  isSymbolicLink : null,
  isFIFO : null,
  isSocket : null,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

if( _global_.wCopyable )
wCopyable.mixin( Self );

//

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
wTools[ Self.nameShort ] = Self;

})();
