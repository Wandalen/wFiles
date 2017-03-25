( function _FileProviderReroot_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../provider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.Reroot )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileProviderReroot( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

//

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

  _.assert( _.strIs( self.rootDirPath ),'wFileProviderReroot : expects string "rootDirPath"' );

  if( !self.originalProvider )
  self.originalProvider = _.FileProvider.Default();

  throw _.err( 'not tested' );

  // self._init();

}

//

function _init()
{
  var self = this;

  //debugger;

  for( var f in self.originalProvider )
  {

    if( !_.routineIs( self.originalProvider[ f ] ) )
    continue;

    if( !self.originalProvider[ f ].isOriginalReader )
    continue;

    ( function( f )
    {

      var original = self.originalProvider[ f ];
      self[ f ] = function fileFilterRerootWrap( o )
      {

        var o = _._fileOptionsGet.apply( original,arguments );

        logger.log( 'reroot to ' + f + ' : ' + o.pathFile + ' -> ' + _.pathReroot( self.rootDirPath, o.pathFile ) );

        _.assert( _.strIs( o.pathFile ) );
        o.pathFile = _.pathReroot( self.rootDirPath, o.pathFile );

        return original( o );
      }

      self[ f ].defaults = original.defaults;
      self[ f ].advanced = original.advanced;
      self[ f ].isOriginalReader = original.isOriginalReader;

    })( f );

  }

}

//

function fileRead( o )
{
  return this.originalProvider.fileRead( o );
}

//

function fileWrite( o )
{
  return this.originalProvider.fileWrite( o );
}

// --
// relationship
// --

var Composes =
{
  rootDirPath : null,
  originalProvider : null,
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

// --
// prototype
// --

var Extend =
{
}

//

var Proto =
{

  init : init,
  _init : _init,

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
_.FileFilter.Reroot = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
