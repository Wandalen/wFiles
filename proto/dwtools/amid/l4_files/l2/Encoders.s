(function _Encoders_s_() {

'use strict';

let _global = _global_;
let _ = _global_.wTools;
let Self = _global_.wTools;

// --
// encoders
// --

let readJsSmart =
{

  name : 'js.smart',
  exts : [ 'js','s','ss','jstruct','jslike' ],
  criterion : { reader : true, config : true },
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

  name : 'js.node',
  exts : [ 'js','s','ss','jstruct' ],
  criterion : { reader : true },
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

  name : 'buffer.bytes',
  criterion : { reader : true },

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
// declare
// --

// let ReadEncoders =
// {
//
//   // 'js.smart' : readJsSmart,
//   // 'js.node' : readJsNode,
//   // 'buffer.bytes' : readBufferBytes,
//
// }
//
// let WriteEncoders =
// {
// }

_.files.ReadEncoders = _.files.ReadEncoders || Object.create( null );
_.files.WriteEncoders = _.files.WriteEncoders || Object.create( null );

// Object.assign( _.files.ReadEncoders, ReadEncoders );
// Object.assign( _.files.WriteEncoders, WriteEncoders );

_.files.encoderRegister( readJsSmart );
_.files.encoderRegister( readJsNode );
_.files.encoderRegister( readBufferBytes );
_.files.encodersFromGdfs(); /* xxx2 : review and probably remove! */

// --
// export
// --

/* xxx : clean */

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
