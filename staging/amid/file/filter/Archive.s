( function _Archive_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../aprovider/aAbstract.s' );

}

//

var _ = wTools;
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

Self.nameShort = 'ArchiveFilter';

//

function init( o )
{
  var self = this;

  _.assert( arguments.length <= 1 );
  _.instanceInit( self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  if( !self.fileArchive )
  self.fileArchive = new wFileArcive();

  if( !self.original )
  self.original = _.fileProvider;

  var proxy =
  {
    get : function( obj, k )
    {
      if( obj[ k ] !== undefined )
      debugger;
      if( obj[ k ] !== undefined )
      return obj[ k ];
      return obj.original[ k ];
    }
  }

  var self = new Proxy( self, proxy );

  return self;
}

//

function fileCopyAct( o )
{
  var self = this;

  debugger;

  xxx

  self.original.fileCopyAct( o );
}

fileCopyAct.defaults = Partial.prototype.fileCopyAct.defaults;

//

// function _initArchive()
// {
//   var self = this;
//
//   //debugger;
//
//   for( var f in self.original )
//   {
//
//     if( !_.routineIs( self.original[ f ] ) )
//     continue;
//
//     if( !self.original[ f ].isOriginalReader )
//     continue;
//
//     ( function( f )
//     {
//
//       var original = self.original[ f ];
//       self[ f ] = function fileFilterArchiveWrap( o )
//       {
//
//         var o = _._fileOptionsGet.apply( original,arguments );
//
//         logger.log( 'reroot to ' + f + ' : ' + o.filePath + ' -> ' + _.pathArchive( self.rootDirPath, o.filePath ) );
//
//         _.assert( _.strIs( o.filePath ) );
//         o.filePath = _.pathArchive( self.rootDirPath, o.filePath );
//
//         return original( o );
//       }
//
//       self[ f ].defaults = original.defaults;
//       self[ f ].advanced = original.advanced;
//       self[ f ].isOriginalReader = original.isOriginalReader;
//
//     })( f );
//
//   }
//
// }

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
  fileArchive : null,
  original : null,
}

var Restricts =
{
}

// --
// prototype
// --

//

var Extend =
{

  init : init,

  fileCopyAct : fileCopyAct,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.prototypeMake
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

wCopyable.mixin( Self );

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter.Archive = Self;

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
