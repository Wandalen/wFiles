( function _FileBase_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof _global_ === 'undefined' || !_global_.wBase )
  {
    let toolsPath = '../../../dwtools/Base.s';
    let toolsExternal = 0;
    try
    {
      require.resolve( toolsPath );
    }
    catch( err )
    {
      toolsExternal = 1;
      require( 'wTools' );
    }
    if( !toolsExternal )
    require( toolsPath );
  }


  var _ = _global_.wTools;

  _.include( 'wProto' );
  _.include( 'wRegexpObject' );
  _.include( 'wFieldsStack' );

  _.include( 'wLogger' );
  _.include( 'wPath' );
  _.include( 'wConsequence' );

}

var Self = _global_.wTools;
var _ = _global_.wTools;

_.assert( _global_.wFieldsStack );
// console.log( '_FileBase_s_',_global_.wFieldsStack );

// --
// routine
// --

function statsCouldHaveSameContent( stat1,stat2 )
{
  _.assert( arguments.length === 2 );

  if( stat1.ino > 0 )
  if( stat1.ino === stat2.ino )
  return true;

  if( stat1.size !== stat2.size )
  return false;

  return true;
}

//

function statsAreLinked( stat1,stat2 )
{
  _.assert( arguments.length === 2 );

  /* ino comparison reliable test if ino present */

  if( stat1.ino !== stat2.ino )
  return false;

  _.assert( !( stat1.ino < -1 ) );

  if( stat1.ino > 0 )
  return stat1.ino === stat2.ino;

  debugger;

  /* try to make a good guess otherwise */

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

function statsHash2Get( stat )
{
  _.assert( arguments.length === 1 );

  if( stat.ino > 0 )
  return stat.ino;

  debugger;

  var mtime = stat.mtime.getTime();
  var ctime = stat.ctime.getTime();

  _.assert( _.numberIs( mtime ) );
  _.assert( _.numberIs( ctime ) );
  _.assert( _.numberIs( stat.nlink ) );
  _.assert( _.numberIs( stat.mode ) );
  _.assert( _.numberIs( stat.size ) );

  var result = ( stat.size << 10 ) ^ ( mtime ) ^ ( ctime << 3 ) ^ ( stat.nlink << 6 ) ^ ( stat.mode << 9 );

  _.assert( _.numberIsInt( result ) );

  return result;
}

// --
// var
// --

var FileProvider =
{
}

// --
// prototype
// --

var Proto =
{
  statsCouldHaveSameContent : statsCouldHaveSameContent,
  statsAreLinked : statsAreLinked,
  statsHash2Get : statsHash2Get,
}

_.mapExtend( _,Proto );
Self.FileProvider = _.mapExtend( Self.FileProvider || {},FileProvider );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
