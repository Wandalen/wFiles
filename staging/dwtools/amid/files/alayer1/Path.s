(function _Path_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../UseBase.s' );

  var _global = _global_;
  var _ = _global_.wTools;

  _.include( 'wPathFundamentals' );

}

var _global = _global_;
var _ = _global_.wTools;
var Self = _global_.wTools.path;

_.assert( _.objectIs( Self ) );

// --
// routines
// --

/**
 * Returns absolute path to file. Accepts file record object. If as argument passed string, method returns it.
 * @example
 * var str = 'foo/bar/baz',
    fileRecord = FileRecord( str );
   var path = wTools.path.from( fileRecord ); // '/home/user/foo/bar/baz';
 * @param {string|wFileRecord} src file record or path string
 * @returns {string}
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If type of argument is not string or wFileRecord.
 * @method from
 * @memberof wTools.path
 */

function from( src )
{

  _.assert( arguments.length === 1, 'expects single argument' );

  if( _.strIs( src ) )
  return src;
  else if( src instanceof _.FileRecord )
  return src.absolute;
  else _.assert( 0, 'unexpected type of argument', _.strTypeOf( src ) );

}

//

var pathsFrom = _.routineVectorize_functor( from );

// --
// declare
// --

var Proto =
{

  from : from,
  pathsFrom : pathsFrom,

}

_.mapExtend( Self, Proto );

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
