( function _Archive_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../FileMid.s' );

  require( '../base/FilesArchive.s' );

}

//

var _ = _global_.wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Default = _.FileProvider.Default;
var Parent = Abstract;
var Self = function wFileFilterArchive( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Archive';

// --
//
// --

function init( o )
{
  var self = this;

  _.assert( arguments.length <= 1 );
  _.instanceInit( self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( !self.original )
  self.original = _.fileProvider;

  var self = _.protoProxy( self, self.original );

  if( !self.archive )
  self.archive = new wFilesArchive({ fileProvider : self });

  return self;
}

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
  archive : null,
  original : null,
}

var Restricts =
{
}

// --
// prototype
// --

var Extend =
{

  init : init,

  // fileCopyAct : fileCopyAct,


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter[ Self.nameShort ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_._UsingWtoolsPrivately_ )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
