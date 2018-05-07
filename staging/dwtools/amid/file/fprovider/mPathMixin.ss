// (function _PathMixin_ss_() {
//
// 'use strict';
//
// var toBuffer = null;
//
// if( typeof module !== 'undefined' )
// {
//
//   var _ = _global_.wTools;
//
//   if( !_.FileProvider )
//   require( '../FileMid.s' );
//
//   _.include( 'wPath' );
//
//   var File = require( 'fs-extra' );
//
// }
//
// var _ = _global_.wTools;
//
// // --
// //
// // --
//
// function _mixin( cls )
// {
//
//   var dstProto = cls.prototype;
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.routineIs( cls ) );
//
//   _.mixinApply
//   ({
//     dstProto : dstProto,
//     descriptor : Self,
//   });
//
// }
//
// // --
// // prototype
// // --
//
// var Supplement =
// {
//
//   pathCurrentAct : null,
//
//   pathCurrent : pathCurrent,
//   pathResolve : pathResolve,
//   pathForCopy : pathForCopy,
//
//   pathFirstAvailable : pathFirstAvailable,
//
//   pathResolveTextLink : pathResolveTextLink,
//   _pathResolveTextLink : _pathResolveTextLink,
//   _pathResolveTextLinkAct : _pathResolveTextLinkAct,
//
//   pathResolveSoftLink : pathResolveSoftLink,
//   pathResolveSoftLinkAct : pathResolveSoftLinkAct,
//
// }
//
// //
//
// var Self =
// {
//
//   supplement : Supplement,
//
//   name : 'wFilePorviderPathMixin',
//   nameShort : 'Path',
//   _mixin : _mixin,
//
// }
//
// //
//
// _.FileProvider = _.FileProvider || Object.create( null );
// _.FileProvider[ Self.nameShort ] = _.mixinMake( Self );
//
// // --
// // export
// // --
//
// if( typeof module !== 'undefined' )
// if( _global_._UsingWtoolsPrivately_ )
// delete require.cache[ module.id ];
//
// if( typeof module !== 'undefined' && module !== null )
// module[ 'exports' ] = Self;
//
// })();
