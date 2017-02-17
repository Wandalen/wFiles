( function _FileBase_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  wTools.include( 'wProto' );
  wTools.include( 'wRegexpObject' );
  wTools.include( 'wLogger' );
  wTools.include( 'wPath' );
  wTools.include( 'wConsequence' );

}

var Self = wTools;
var _ = wTools;

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

}

_.mapExtend( _,Proto );
Self.FileProvider = _.mapExtend( Self.FileProvider || {},FileProvider );

// export

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}


})();
