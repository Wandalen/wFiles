( function _FileCommon_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  if( typeof wBase === 'undefined' )
  try
  {
    require( '../../abase/wTools.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  if( typeof wRegexpObject === 'undefined' )
  try
  {
    require( '../../abase/object/RegexpObject.s' );
  }
  catch( err )
  {
    require( 'wRegexpObject' );
  }

  if( typeof wTools === 'undefined' || !wTools.mixin )
  try
  {
    require( '../../abase/component/Proto.s' );
  }
  catch( err )
  {
    require( 'wProto' );
  }

  if( typeof logger === 'undefined' )
  try
  {
    require( '../../abase/object/printer/Logger.s' );
  }
  catch( err )
  {
  }

  if( typeof wConsequence === 'undefined' )
  try
  {
    require( '../../abase/syn/Consequence.s' );
  }
  catch( err )
  {
    require( 'wConsequence' );
  }

/*
  if( typeof wTools === 'undefined' || !wTools.idNumber )
  try
  {
    require( '../../abase/component/NameTools' );
  }
  catch( err )
  {
    //require( 'wNameTools' );
  }
*/

  if( typeof wTools === 'undefined' || !wTools.pathDir )
  try
  {
    require( '../../abase/component/Path.s' );
  }
  catch( err )
  {
    require( 'wPath' );
  }

}

var Self = wTools;
var _ = wTools;

//
//
// var filesRead_gen = function( fileRead )
// {
//
//   _.assert( arguments.length === 1 );
//   _.assert( _.routineIs( fileRead ) );
//
//   var filesRead = function( o )
//   {
//
//     // options
//
//     if( _.arrayIs( o ) )
//     o = { paths : o };
//
//     _.assert( arguments.length === 1 );
//     _.assert( _.objectIs( o ) );
//
//     if( _.objectIs( o.paths ) )
//     {
//       var _paths = [];
//       for( var p in o.paths )
//       _paths.push({ pathFile : o.paths[ p ], name : p });
//       o.paths = _paths;
//     }
//
//     o.paths = _.arrayAs( o.paths );
//
//     var con = new wConsequence();
//     var result = [];
//     var errs = [];
//
//     if( o.sync )
//     throw _.err( 'not implemented' );
//
//   /*
//     _.assert( !o.onBegin,'not implemented' );
//     _.assert( !o.onEnd,'not implemented' );
//   */
//
//     _.assert( !o.onProgress,'not implemented' );
//
//     var onBegin = o.onBegin;
//     var onEnd = o.onEnd;
//     var onProgress = o.onProgress;
//
//     delete o.onBegin;
//     delete o.onEnd;
//     delete o.onProgress;
//
//     // begin
//
//     if( onBegin )
//     wConsequence.give( onBegin,{ options : o } );
//
//     // exec
//
//     for( var p = 0 ; p < o.paths.length ; p++ ) ( function( p )
//     {
//
//       con.got();
//
//       var pathFile = o.paths[ p ];
//       var readOptions = _.mapScreen( fileRead.defaults,o );
//       readOptions.onEnd = o.onEach;
//       if( _.objectIs( pathFile ) )
//       _.mapExtend( readOptions,pathFile );
//       else
//       readOptions.pathFile = pathFile;
//
//       fileRead( readOptions ).got( function filesReadFileEnd( err,read )
//       {
//
//         if( err || read === undefined )
//         {
//           debugger;
//           errs[ p ] = _.err( 'cant read : ' + _.toStr( pathFile ) + '\n',err );
//         }
//         else
//         result[ p ] = read;
//
//         con.give();
//
//       });
//
//     })( p );
//
//     // end
//
//     con.give().then_( function filesReadEnd()
//     {
// /*
//       if( errs.length )
//       return new wConsequence().error( errs[ 0 ] );
// */
//       if( errs.length )
//       throw _.err( errs[ 0 ] );
//
//       if( o.map === 'name' )
//       {
//         var _result = {};
//         for( var p = 0 ; p < o.paths.length ; p++ )
//         _result[ o.paths[ p ].name ] = result[ p ];
//         result = _result;
//       }
//       else if( o.map )
//       throw _.err( 'unknown map : ' + o.map );
//
//       var r = { options : o, data : result };
//
//       if( onEnd )
//       wConsequence.give( onEnd,r );
//
//       return r;
//     });
//
//     //
//
//     return con;
//   }
//
//   filesRead.defaults =
//   {
//
//     paths : null,
//     onEach : null,
//
//     map : '',
//
//   }
//
//   filesRead.defaults.__proto__ = fileRead.default;
//
//   return filesRead;
// }

// --
// var
// --

var FileProvider =
{
}

// --
// prototype
// --

var Proto =
{

  //filesRead_gen : filesRead_gen,

}

_.mapExtend( _,Proto );
Self.FileProvider = _.mapExtend( Self.FileProvider || {},FileProvider );

// export

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}


})();
