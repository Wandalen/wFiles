( function _FileStat_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  try
  {
    var File = require( 'fs' );
  }
  catch( err )
  {
  }

}

//

var _global = _global_;
var _ = _global_.wTools;
var Parent = null;
var Self = function wFileStat( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  {
    _.assert( arguments.length === 1, 'expects single argument' );
    return o;
  }
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.shortName = 'FileStat';

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

function fileStatIs( src )
{
  if( File )
  if( src instanceof File.Stats )
  return true;
  if( src instanceof _.FileStat )
  return true;
  return false;
}

//

// function fileStatsCouldHaveSameContent( stat1,stat2 )
function fileStatsHaveDifferentContent( stat1,stat2 )
{
  _.assert( arguments.length === 2, 'expects exactly two arguments' );

  if( _.bigIntIs( stat1.ino ) )
  if( stat1.ino === stat2.ino )
  return false;

  if( stat1.size !== stat2.size )
  return true;

  if( stat1.size === 0 || stat2.size === 0 )
  return null;

  return null;
}

//

function fileStatsCouldBeLinked( stat1,stat2 )
{
  _.assert( arguments.length === 2, 'expects exactly two arguments' );
  _.assert( _.fileStatIs( stat1 ) );
  _.assert( _.fileStatIs( stat2 ) );
  _.assert( !!stat1.mtime );

  /*
  ino comparison is not reliable test on nodejs below 10.5
  it's reliable only if ino is BigNumber
  */

  if( stat1.ino !== stat2.ino )
  return false;

  if( _.bigIntIs( stat1.ino ) )
  debugger;

  if( _.bigIntIs( stat1.ino ) )
  return stat1.ino === stat2.ino;

  /*
  try to make a good guess if ino comprison is not possible
  */

  if( stat1.nlink !== stat2.nlink )
  return false;

  if( stat1.mode !== stat2.mode )
  return false;

  if( stat1.size !== stat2.size )
  return false;

  if( stat1.mtime.getTime() !== stat2.mtime.getTime() )
  return false;

  if( stat1.ctime.getTime() !== stat2.ctime.getTime() )
  return false;

  if( stat1.birthtime.getTime() !== stat2.birthtime.getTime() )
  return false;

  return true;
}

//

function fileStatHashGet( stat )
{

  _.assert( arguments.length === 1, 'expects single argument' );

  if( stat.ino > 0 )
  return stat.ino;

  debugger;

  var ino = stat.ino || 0;
  var mtime = stat.mtime.getTime();
  var ctime = stat.ctime.getTime();

  _.assert( _.numberIs( mtime ) );
  _.assert( _.numberIs( ctime ) );
  _.assert( _.numberIs( stat.nlink ) );
  _.assert( _.numberIs( stat.size ) );

  var result = ( stat.size << 10 ) ^ ( mtime ) ^ ( ctime << 3 ) ^ ( stat.nlink << 6 );

  _.assert( _.numberIsInt( result ) );

  return result;
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

var Globals =
{
  fileStatIs : fileStatIs,
  fileStatsHaveDifferentContent : fileStatsHaveDifferentContent,
  fileStatsCouldBeLinked : fileStatsCouldBeLinked,
  fileStatHashGet : fileStatHashGet,
}

// --
// declare
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


  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

if( _global_.wCopyable )
_.Copyable.mixin( Self );

_[ Self.shortName ] = Self;

_.mapExtend( _, Globals );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
