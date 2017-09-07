(function _Glob_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  require( './FileBase.s' );
}

var _ = wTools;
var Self = wTools;

// --
// path
// --

function _regexpForGlob( glob )
{
  _.assert( _.strIs( glob ) );
  _.assert( arguments.length === 1 );

  function squareBrackets( src )
  {
    src = _.strInbetweenOf( src, '[', ']' );
    //escape inner []
    src = src.replace( /[\[\]]/g, ( m ) => '\\' + m );
    //replace ! -> ^ at the beginning
    src = src.replace( /^\\!/g, '^' );
    return '[' + src + ']';
  }

  function curlyBrackets( src )
  {
    src = src.replace( /[\}\{]/g, ( m ) => map[ m ] );
    //replace , with | to separete regexps
    src = src.replace( /,+(?![^[|(]*]|\))/g, '|' );
    return src;
  }

  var map =
  {
    0 : '.*', /* doubleAsterix */
    1 : '[^\\\/]*', /* singleAsterix */
    2 : '.', /* questionMark */
    3 : squareBrackets, /* squareBrackets */
    '{' : '(',
    '}' : ')',
  }

  function globToRegexp(  )
  {
    var args = [].slice.call( arguments );
    var i = args.indexOf( args[ 0 ], 1 ) - 1;

    /* i - index of captured group from regexp is equivalent to key from map  */

    if( _.strIs( map[ i ] ) )
    return map[ i ];
    if( _.routineIs( map[ i ] ) )
    return map[ i ]( args[ 0 ] );
  }

  //espace simple text
  glob = glob.replace( /[^\*\[\]\{\}\?]+/g, ( m ) => _.regexpEscape( m ) );
  //replace globs with regexps from map
  glob = glob.replace( /(\*\*)|(\*)|(\?)|(\[.*\])/g, globToRegexp );
  //replace {} -> () and , -> | to make proper regexp
  glob = glob.replace( /\{.*\}+(?![^[]*\])/g, curlyBrackets );

  if( !_.strBegins( glob, '\\.\/' ) )
  glob = _.strPrependOnce( glob,'\\.\/' );

  glob = _.strPrependOnce( glob,'^' );
  glob = _.strAppendOnce( glob,'$' );

  // console.log( glob )

  return RegExp( glob,'m' );
}

// --
// prototype
// --

var Proto =
{

  _regexpForGlob : _regexpForGlob

}

_.mapExtend( Self,Proto );

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
