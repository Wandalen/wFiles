( function _FileProviderReroot_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileProviderAbstract.s' );

}

//

var _ = wTools;
var Parent = _.FileProvider.Abstract;
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

var init = function( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

  _.assert( _.strIs( self.pathRoot ),'wFileProviderReroot : expects string "pathRoot"' );

  self._init();

}

//

var _init = function()
{
  var self = this;

  debugger;

  for( var f in self )
  {

    if( !_.routineIs( self[ f ] ) )
    continue;

    if( !self[ f ].isOriginalReader )
    continue;

    ( function( f ) {

      var original = self[ f ];
      self[ f ] = function fileFilterRerootWrap( o )
      {
        var o = _._fileOptionsGet.apply( original,arguments );

        logger.log( 'reroot : ' + o.pathFile + ' -> ' + _.pathReroot( self.pathRoot, o.pathFile ) );

        if( !_.atomicIs( o ) || !_.strIs( o.pathFile ) )
        return;

        _.assert( _.strIs( o.pathFile ) );
        o.pathFile = _.pathReroot( self.pathRoot, o.pathFile );

        return original( o );
      }

      self[ f ].defaults = original.defaults;
      self[ f ].advanced = original.advanced;
      self[ f ].isOriginalReader = original.isOriginalReader;

    })( f );

  }

}

// --
// relationship
// --

var Composes =
{
  pathRoot : null,
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

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileProvider = _.FileProvider || {};
_.FileProvider.Reroot = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
