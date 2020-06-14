(function _Encoders_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools;

// _.include( 'wGdf' );

// --
// encoders
// --

// let ReadEncoders = fileRead.encoders;
// let WriteEncoders = fileWrite.encoders;

// let readJson =
// {

//   exts : [ 'json' ],
//   forConfig : 1,

//   onBegin : function( e )
//   {
//     _.assert( e.operation.encoding === 'json' );
//     e.operation.encoding = 'utf8';
//   },

//   onEnd : function( e )
//   {
//     if( !_.strIs( e.data ) )
//     throw _.err( '( fileRead.encoders.json.onEnd ) expects string' );
//     e.data = _.jsonParse( e.data );
//   },

// }

// //

// let readJsStructure =
// {

//   exts : [ 'js','s','ss','jstruct' ],
//   forConfig : 0,

//   onBegin : function( e )
//   {
//     e.operation.encoding = 'utf8';
//   },

//   onEnd : function( e )
//   {
//     if( !_.strIs( e.data ) )
//     throw _.err( '( fileRead.encoders.js.structure.onEnd ) expects string' );
//     e.data = _.exec({ code : e.data, filePath : e.operation.filePath, prependingReturn : 1 });
//   },

// }

//

let readJsSmart =
{

  exts : [ 'js','s','ss','jstruct','jslike' ],
  forConfig : 1,

  onBegin : function( e )
  {
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    _.sure( _.strIs( e.data ), 'Expects string' );

    if( typeof process !== 'undefined' && typeof require !== 'undefined' )
    if( _.FileProvider.HardDrive && e.provider instanceof _.FileProvider.HardDrive )
    {
      try
      {
        e.data = require( _.fileProvider.path.nativize( e.operation.filePath ) );
        return;
      }
      catch( err )
      {
      }
    }

    e.data = _.exec
    ({
      code : e.data,
      filePath : e.operation.filePath,
      prependingReturn : 1,
    });
  },

}

//

let readJsNode =
{

  exts : [ 'js','s','ss','jstruct' ],
  forConfig : 0,

  onBegin : function( e )
  {
    e.operation.encoding = 'utf8';
  },

  onEnd : function( e )
  {
    if( !_.strIs( e.data ) )
    throw _.err( 'Expects string' );
    e.data = require( _.fileProvider.path.nativize( e.operation.filePath ) );
  },

}

//

let readBufferBytes =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    if( e.stream )
    return;
    e.data = e.data;
    _.assert( _.bufferBytesIs( e.data ) );
  },

}

// --
//
// --

// let writeJsonMin =
// {
//   onBegin : function( e )
//   {
//     e.operation.data = JSON.stringify( e.operation.data );
//     e.operation.encoding = 'utf8';
//   }
// }

// let writeJsonFine =
// {
//   onBegin : function( e )
//   {
//     e.operation.data = _.cloneData({ src : e.operation.data });
//     e.operation.data = _.toJson( e.operation.data, { cloning : 0 } );
//     e.operation.encoding = 'utf8';
//   }
// }

// let writeJsStrcuture =
// {
//   onBegin : function( e )
//   {
//     e.operation.data = _.toJs( e.data );
//     e.operation.encoding = 'utf8';
//   }
// }

// --
// declare
// --

let FileReadEncoders =
{

  // 'json' : readJson,
  // 'js.structure' : readJsStructure,
  'js.smart' : readJsSmart,
  'js.node' : readJsNode,
  'buffer.bytes' : readBufferBytes,

}

let FileWriteEncoders =
{

  // 'json' : writeJsonMin,
  // 'json.min' : writeJsonMin,
  // 'json.fine' : writeJsonFine,
  // 'js.structure' : writeJsStrcuture,

}

_.FileReadEncoders = _.FileReadEncoders || Object.create( null );
_.FileWriteEncoders = _.FileWriteEncoders || Object.create( null );

Object.assign( _.FileReadEncoders, FileReadEncoders );
Object.assign( _.FileWriteEncoders, FileWriteEncoders );

// if( _.FileProvider && _.FileProvider.Partial && _.FileProvider.Partial.prototype.fileRead.encoders )
// _.assert( _.isPrototypeOf( _.FileReadEncoders, _.FileProvider.Partial.prototype.fileRead.encoders ) );
// if( _.FileProvider && _.FileProvider.Partial && _.FileProvider.Partial.prototype.fileWrite.encoders )
// _.assert( _.isPrototypeOf( _.FileWriteEncoders, _.FileProvider.Partial.prototype.fileWrite.encoders ) );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

/* xxx : clean */

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
