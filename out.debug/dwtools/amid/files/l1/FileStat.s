( function _FileStat_s_() {

'use strict';

let File;

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  try
  {
    File = require( 'fs' );
  }
  catch( err )
  {
  }

}

//

let _global = _global_;
let _ = _global_.wTools;
let Parent = null;
let Self = function wFileStat( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'FileStat';

// --
//
// --

function init( o )
{
  let self = this;

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

// function statResolvedReadsCouldHaveSameContent( stat1,stat2 )
function statsHaveDifferentContent( stat1, stat2 )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

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

function statsAreHardLinked( stat1, stat2 )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( _.fileStatIs( stat1 ) );
  _.assert( _.fileStatIs( stat2 ) );

  if( !stat1.mtime )
  return null;

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

  return null;
}

//

function statsCouldBeLinked( stat1, stat2 )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
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

function statHash2Get( stat )
{

  _.assert( arguments.length === 1, 'Expects single argument' );

  if( _.bigIntIs( stat.ino ) )
  return stat.ino;

  let ino = stat.ino || 0;
  let mtime = stat.mtime.getTime();
  let ctime = stat.ctime.getTime();

  _.assert( _.numberIs( mtime ) );
  _.assert( _.numberIs( ctime ) );
  _.assert( _.numberIs( stat.nlink ) );

  let result = ino + '' + mtime + '' + ctime + '' + stat.size;

  _.assert( _.strIs( result ) );

  return result;
}

//

function isLink()
{
  let stat = this;
  let result = false;

  _.assert( arguments.length === 0 );

  if( !result )
  result = stat.isSoftLink();

  if( !result )
  result = stat.isTextLink();

  return result;
}

//

function returnFalse()
{
  return false;
}

// --
//
// --

let Composes =
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

let Aggregates =
{
}

let Associates =
{
  associated : null,
  filePath : null,
}

let Restricts =
{

  isDir : null,
  isTerminal : null,
  isTextLink : null,
  isSoftLink : null,
  isHardLink : null,

  isDirectory : null, /* alias */
  isFile : null, /* alias */
  isSymbolicLink : null, /* alias */

  isBlockDevice : returnFalse,
  isCharacterDevice : returnFalse,
  isFIFO : returnFalse,
  isSocket : returnFalse,

  // _checkModeProperty : null,

}

let Statics =
{
}

let Globals =
{
  fileStatIs,
  statsHaveDifferentContent,
  statsAreHardLinked,
  statsCouldBeLinked,
  statHash2Get,
}

let Forbids =
{
}

// --
// declare
// --

let Extend =
{

  init,

  isDir : null,
  isTerminal : null,
  isTextLink : null,
  isSoftLink : null,
  isHardLink : null,
  isLink,

  isDirectory : null, /* alias */
  isFile : null, /* alias */
  isSymbolicLink : null, /* alias */

  isBlockDevice : returnFalse,
  isCharacterDevice : returnFalse,
  isFIFO : returnFalse,
  isSocket : returnFalse,

  // _checkModeProperty : null,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Statics,
  Forbids,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

if( _global_.wCopyable )
_.Copyable.mixin( Self );

_[ Self.shortName ] = Self;

_.mapExtend( _, Globals );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
