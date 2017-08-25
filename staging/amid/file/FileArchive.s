( function _FileArchive_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );

}

//

var _ = wTools;
var Parent = null;
var Self = function wFileArchive( o )
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

Self.nameShort = 'FileArchive';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length === 0 || arguments.length === 1 );

  _.instanceInit( self );
  Object.preventExtensions( self )

  if( o )
  self.copy( o );

}

//

function contentUpdate( head,data )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = self._dependencyFor( head );

  dependency.info.hash = self._hashFor( data );

  return dependency;
}

//

function statUpdate( head,stat )
{
  var self = this;

  _.assert( arguments.length === 2 );

  var head = _.FileRecord.from( head );
  var dependency = self._dependencyFor( head );

  dependency.info.mtime = stat.mtime;
  dependency.info.ctime = stat.ctime;
  dependency.info.size = stat.size;

  return dependency;
}

//

function dependencyAdd( head,tails )
{
  var self = this;

  _.assert( arguments.length === 2 );

  head = _.FileRecord.from( head );
  tails = _.FileRecord.manyFrom( tails );

  var dependency = self._dependencyFor( head );

  _.arrayAppendArray( dependency.tails , _.entitySelect( tails,'*.relative' ) );

  return dependency;
}

//

function _dependencyFor( head )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( head instanceof _.FileRecord );

  var dependency = self.dependencyMap[ head.relative ];
  if( !dependency )
  {
    dependency = self.dependencyMap[ head.relative ] = Object.create( null );
    dependency.head = head.relative;
    dependency.tails = [];
    dependency.info = Object.create( null );
    dependency.info.hash = null;
    dependency.info.size = null;
    dependency.info.mtime = null;
    dependency.info.ctime = null;
    Object.preventExtensions( dependency );
  }

  return dependency;
}

//

function _hashFor( src )
{

  var result;
  var crypto = require( 'crypto' );
  var md5sum = crypto.createHash( 'md5' );

  try
  {
    md5sum.update( src );
    result = md5sum.digest( 'hex' );
  }
  catch( err )
  {
    throw _.err( err );
  }

  return result;
}

// --
//
// --

var Composes =
{
  dependencyMap : Object.create( null ),
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
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

  contentUpdate : contentUpdate,
  statUpdate : statUpdate,

  dependencyAdd : dependencyAdd,
  _dependencyFor : _dependencyFor,

  _hashFor : _hashFor,


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

wCopyable.mixin( Self );

//

_.accessorForbid( Self.prototype,
{
});

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
_global_[ Self.name ] = wTools[ Self.nameShort ] = Self;

})();
