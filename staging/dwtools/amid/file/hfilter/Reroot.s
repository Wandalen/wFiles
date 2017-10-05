// ( function _Reroot_s_() {
//
// 'use strict';
//
// if( typeof module !== 'undefined' )
// {
//
//   require( '../FileMid.s' );
//   require( '../base/FileReroot.s' );
//
// }
//
// //
//
// var _ = wTools;
// var Abstract = _.FileProvider.Abstract;
// var Partial = _.FileProvider.Partial;
// var Default = _.FileProvider.Default;
// var Parent = Abstract;
// var Self = function wFileFilterReroot( o )
// {
//   if( !( this instanceof Self ) )
//   if( o instanceof Self )
//   return o;
//   else
//   return new( _.routineJoin( Self, Self, arguments ) );
//   return Self.prototype.init.apply( this,arguments );
// }
//
// Self.nameShort = 'Reroot';
//
// //
//
// function init( o )
// {
//   var self = this;
//
//   _.assert( arguments.length <= 1 );
//   _.instanceInit( self )
//   Object.preventExtensions( self );
//
//   if( o )
//   self.copy( o );
//
//   if( !self.original )
//   self.original = _.fileProvider;
//
//   var original = self.original;
//   var handler =
//   {
//     get : function( obj, k )
//     {
//       debugger; xxx
//       if( obj[ k ] !== undefined )
//       return obj[ k ];
//       return obj.original[ k ];
//     },
//     set : function( obj, k, val, target )
//     {
//       debugger; xxx
//       if( obj[ k ] !== undefined )
//       obj[ k ] = val;
//       else
//       obj.original[ k ] = val;
//       return true;
//     },
//   }
//
//   var self = new Proxy( self, handler );
//
//   return self;
// }
//
// //
//
// function _pathReroot( path )
// {
//   var self = this;
//
//   debugger; xxx
//   var result = _.pathReroot( self.rootDirPath,path );
//
//   return result;
// }
//
// // --
// // relationship
// // --
//
// var Composes =
// {
// }
//
// var Aggregates =
// {
// }
//
// var Associates =
// {
//   original : null,
//   rootDirPath : null,
// }
//
// var Restricts =
// {
// }
//
// // --
// // prototype
// // --
//
// var Extend =
// {
//
//   init : init,
//
//   // fileCopyAct : fileCopyAct,
//
//
//   //
//
//   constructor : Self,
//   Composes : Composes,
//   Aggregates : Aggregates,
//   Associates : Associates,
//   Restricts : Restricts,
//
// }
//
// //
//
// _.classMake
// ({
//   cls : Self,
//   parent : Parent,
//   extend : Extend,
// });
//
// wCopyable.mixin( Self );
//
// //
//
// _.FileFilter = _.FileFilter || Object.create( null );
// _.FileFilter[ Self.nameShort ] = Self;
//
// if( typeof module !== 'undefined' )
// module[ 'exports' ] = Self;
//
// })();

( function _Reroot_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( !wTools.FileProvider.Partial )
  require( './aPartial.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.Reroot )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterReroot( o )
{
  if( !( this instanceof Self ) )
  if( o instanceof Self )
  return o;
  else
  return new( _.routineJoin( Self, Self, arguments ) );
  return Self.prototype.init.apply( this,arguments );
}

Self.nameShort = 'Reroot';

//

// function init( o )
// {
//   var self = this;
//   Parent.prototype.init.call( self,o );
//
//   _.assert( _.strIs( self.rootDirPath ),'wFileFilterReroot : expects string "rootDirPath"' );
//
//   if( !self.original )
//   self.original = _.FileProvider.Default();
//
//   throw _.err( 'not tested' );
//
//   self._init();
//
// }

function init( o )
{

  var self = _.instanceFilterInit
  ({
    cls : Self,
    parent : Parent,
    extend : Extend,
    args : arguments,
    strict : 0,
  });

  self._initReroot();

  Object.preventExtensions( self );

  return self;
}

//

function _initReroot()
{
  var self = this;

  //debugger;

  for( var f in self.original )
  {

    if( !_.routineIs( self.original[ f ] ) )
    continue;

    if( !self.original[ f ].isOriginalReader )
    continue;

    ( function( f )
    {

      var original = self.original[ f ];
      self[ f ] = function fileFilterRerootWrap( o )
      {

        var o = _._fileOptionsGet.apply( original,arguments );

        logger.log( 'reroot to ' + f + ' : ' + o.filePath + ' -> ' + _.pathReroot( self.rootDirPath, o.filePath ) );

        _.assert( _.strIs( o.filePath ) );
        o.filePath = _.pathReroot( self.rootDirPath, o.filePath );

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
  return this.original.fileRead( o );
}

//

function fileWrite( o )
{
  return this.original.fileWrite( o );
}

// --
// relationship
// --

var Composes =
{
  rootDirPath : null,
  original : null,
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
  _initReroot : _initReroot,
}

//

var Proto =
{

  init : init,
  _initReroot : _initReroot,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.mapExtend( Proto,Extend );

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter[ Self.nameShort ] = Self;

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
