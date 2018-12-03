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
    [ routineName ] : function()
    {
      let op2 = _.mapExtend( null, op );
      op2.originalFileProvider = this.original;
      op2.originalBody = body;
      op2.args = _.unrollFrom( arguments );
      op2.result = undefined;
      // op2.methodDescriptor = op;

      debugger;

      if( pre )
      {
        debugger; xxx
        op2.args = pre.call( this.original, resultRoutine, op2.args );
        if( !_.unrollIs( op2.args ) )
        op2.args = _.unrollFrom([ op2.args ]);
      }

      if( this.onCallBegin )
      op2.args = this.onCallBegin( op2 );

      if( !_.unrollIs( op2.args ) )
      op2.args = _.unrollFrom([ op2.args ]);

      _.assert( !_.argumentsArrayIs( op2.args ), 'Does not expect arguments array' );

      op2.result = this.onCall( op2 );

      if( this.onCallEnd )
      op2.result = this.onCallEnd( op2.result, op );

      return op2.result;
    }
  }

  let resultRoutine = self.routines[ routineName ] = r[ routineName ];

  _.routineExtend( resultRoutine, routine );

  return resultRoutine;
}

//

function onCall( op )
{
  _.assert( arguments.length === 1 );
  return op.originalBody.apply( op.originalFileProvider, op.args );
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
  onCall : onCall,
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
