( function _Image_s_() {

'use strict';

// if( typeof module !== 'undefined' )
// {
//
//   let _global = _global_;
//   let _ = _global_.wTools;
//
//   // require( '../UseFilesArchive.s' );
//
// }

//

let _global = _global_;
let _ = _global_.wTools;
let Abstract = _.FileProvider.Abstract;
// let Partial = _.FileProvider.Partial;
// let Default = _.FileProvider.Default;
let Parent = Abstract;
let Self = function wFileFilterImage( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Image';

// --
//
// --

function init( o )
{
  let self = this;

  _.assert( arguments.length <= 1 );
  _.instanceInit( self )
  Object.preventExtensions( self );

  if( o )
  self.copy( o );

  let accessors =
  {
    get : function( self, k, proxy )
    {
      let result;
      if( self[ k ] !== undefined )
      result = self[ k ];
      else
      result = self.original[ k ];
      if( self._routineDrivingAndChanging( result ) )
      return self._routineFunctor( result, k );
      return result;
    },
    set : function( self, k, val, proxy )
    {
      if( self[ k ] !== undefined )
      self[ k ] = val;
      else if( self.original[ k ] !== undefined )
      self.original[ k ] = val;
      else
      self[ k ] = val;
      return true;
    },
  };

  let proxy = new Proxy( self, accessors );

  if( !self.original )
  self.original = _.fileProvider;

  if( !self.fileProvider )
  {
    self.fileProvider = self.original;
    while( self.fileProvider.original )
    self.fileProvider = self.fileProvider.original;
  }

  _.assert( self.original instanceof _.FileProvider.Partial );
  _.assert( self.fileProvider instanceof _.FileProvider.Partial );

  // if( !self.archive )
  // self.archive = new _.FilesImage({ fileProvider : proxy });
  // debugger;
  // let proxy = _.proxyMap( self, self.original );
  //
  // if( !proxy.archive )
  // proxy.archive = new wFilesImage({ fileProvider : proxy });

  return proxy;
}

//

function _routineDrivingAndChanging( routine )
{

  _.assert( arguments.length === 1 );

  if( !_.routineIs( routine ) )
  return false;

  if( !routine.having )
  return false;

  if( !routine.having.reading && !routine.having.writing )
  return false;

  if( !routine.having.driving )
  return false;

  _.assert( _.objectIs( routine.operates ), () => 'Method ' + routine.name + ' does not have map {-operates-}' );

  if( _.mapKeys( routine.operates ).length === 0 )
  return false;

  return true;
}

//

function _routineFunctor( routine, routineName )
{
  let self = this;

  _.assert( arguments.length === 2 );
  _.assert( _.routineIs( routine ) );
  _.assert( !!routine.having );
  _.assert( !!routine.having.reading || !!routine.having.writing );
  _.assert( !!routine.having.driving );
  _.assert( !!routine.operates );
  _.assert( _.mapKeys( routine.operates ).length > 0 );
  _.assert( _.strDefined( routineName ) );
  _.assert( routine.name === routineName );

  if( self.routines[ routineName ] )
  return self.routines[ routineName ];

  let pre = routine.pre;
  let body = routine.body || routine;
  let op = Object.create( null );
  op.routine = routine;
  op.routineName = routineName;
  op.reads = [];
  op.writes = [];

  for( let k in routine.operates )
  {
    let arg = routine.operates[ k ];
    if( arg.pathToRead )
    op.reads.push( k );
    if( arg.pathToWrite )
    op.writes.push( k );
  }

  let r =
  {
    [ routineName ] : function( o )
    {
      let args = _.unrollFrom( arguments );
      let result;

      if( pre )
      {
        debugger; xxx
        args = pre.call( this.original, resultRoutine, args );
        if( !_.unrollIs( args ) )
        args = _.unrollFrom([ args ]);
      }

      if( this.onCallBegin )
      args = this.onCallBegin( args, op );

      if( !_.unrollIs( args ) )
      args = _.unrollFrom([ args ]);

      _.assert( !_.argumentsArrayIs( args ), 'Does not expect arguments array' );

      result = this.onCall( this.original, body, args );
      // result = body.apply( this.original, args );

      if( this.onCallEnd )
      result = this.onCallEnd( result, op );

      return result;
    }
  }

  let resultRoutine = self.routines[ routineName ] = r[ routineName ];

  _.routineExtend( resultRoutine, routine );

  return resultRoutine;
}

//

function onCall( original, body, args )
{
  return body.apply( original, args );
}

// --
// relationship
// --

let Composes =
{
}

let Aggregates =
{
  onCallBegin : null,
  onCall : null,
  onCallEnd : null,
}

let Associates =
{
  // archive : null,
  original : null,
  fileProvider : null,
}

let Restricts =
{
  routines : _.define.own({}),
}

let Events =
{
}

// --
// declare
// --

let Extend =
{

  init,

  _routineDrivingAndChanging,
  _routineFunctor,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,
  Events,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Extend,
});

_.Copyable.mixin( Self );
// _.EventHandler.mixin( Self );

//

_.FileFilter = _.FileFilter || Object.create( null );
_.FileFilter[ Self.shortName ] = Self;

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
