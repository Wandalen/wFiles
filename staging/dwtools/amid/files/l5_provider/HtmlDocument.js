( function _HtmlDocument_s_() {

'use strict';

var isBrowser = true;

if( typeof module !== 'undefined' )
{
  isBrowser = false;

  var _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

var _global = _global_;
var _ = _global_.wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var FileRecord = _.FileRecord;
var Find = _.FileProvider.Find;

_.assert( _.routineIs( _.FileRecord ) );
_.assert( _.routineIs( Abstract ) );
_.assert( _.routineIs( Partial ) );
_.assert( !!Find );
_.assert( !_.FileProvider.HtmlDocument );

//

var Parent = Partial;
var Self = function wFileProviderHtmlDocument( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'HtmlDocument';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );

  if( self.filesTree === null )
  self.filesTree = Object.create( null );

}

// --
// path
// --

function pathCurrentAct()
{
  var self = this;
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  {
    var path = arguments[ 0 ];
    _.assert( self.path.is( path ) );
    self._currentPath = path;
  }

  var result = self._currentPath;

  return result;
}

// --
// read
// --

function fileReadAct( o )
{
  var self = this;
  var con = new _.Consequence();
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileReadAct,o );
  _.assert( _.strIs( o.encoding ) );

  var encoder = fileReadAct.encoders[ o.encoding ];

  if( o.encoding )
  if( !encoder )
  return handleError( _.err( 'Encoding: ' + o.encoding + ' is not supported!' ) )

  /* exec */

  handleBegin();

  debugger; _.assert( 0, 'not implemented' );

  return handleEnd( result );

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    _.sure( encoder.onBegin.call( self, { operation : o, encoder : encoder }) === undefined );

  }

  /* end */

  function handleEnd( data )
  {

    let context = { data : data, operation : o, encoder : encoder };
    if( encoder && encoder.onEnd )
    _.sure( encoder.onEnd.call( self,context ) === undefined );

    if( o.sync )
    {
      return context.data;
    }
    else
    {
      return con.give( context.data );
    }

  }

  /* error */

  function handleError( err )
  {

    debugger;

    if( encoder && encoder.onError )
    try
    {
      err = _._err
      ({
        args : [ stack,'\nfileReadAct( ',o.filePath,' )\n',err ],
        usingSourceCode : 0,
        level : 0,
      });
      err = encoder.onError.call( self,{ error : err, operation : o, encoder : encoder })
    }
    catch( err2 )
    {
      console.error( err2 );
      console.error( err.toString() + '\n' + err.stack );
    }

    if( o.sync )
    {
      throw err;
    }
    else
    {
      return con.error( err );
    }

  }

}

_.routineExtend( fileStatAct, Parent.prototype.fileReadAct );

//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileStatAct,o );

  /* */

  if( o.sync )
  {
    return _fileStatAct( o.filePath );
  }
  else
  {
    return _.timeOut( 0, function()
    {
      return _fileStatAct( o.filePath );
    })
  }

  function _fileStatAct( filePath )
  {
    var result = null;

    debugger; _.assert( 0, 'not implemented' );

    return result;
  }

}

_.routineExtend( fileStatAct, Parent.prototype.fileStatAct );

// --
// encoders
// --

var encoders = Object.create( null );

fileReadAct.encoders = encoders;

//

encoders[ 'utf8' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'utf8' );
  },

  onEnd : function( e )
  {
    var result = e.data;

    if( !_.strIs( result ) )
    result = _.bufferToStr( result );

    _.assert( _.strIs( result ) );
    return result;
  },

}

//

encoders[ 'ascii' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'ascii' );
  },

  onEnd : function( e )
  {
    var result = e.data;
    _.assert( _.strIs( result ) );
    return result;
  },

}

//

encoders[ 'latin1' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'latin1' );
  },

  onEnd : function( e )
  {
    var result = e.data;

    if( !_.strIs( result ) )
    result = _.bufferToStr( result );

    _.assert( _.strIs( result ) );
    return result;
  },

}

//

encoders[ 'buffer.raw' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.raw' );
  },

  onEnd : function( e )
  {
    // _.assert( _.strIs( data ) );
    // qqq : use _.?someRoutine? please
    // var nodeBuffer = Buffer.from( data )
    // var result = _.bufferRawFrom( nodeBuffer );

    var result = _.bufferRawFrom( e.data );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    // debugger;
    // var str = _.bufferToStr( result )
    // _.assert( str === data );
    // debugger;

    return result;
  },

}

//

encoders[ 'buffer.bytes' ] =
{

  onBegin : function( e )
  {
    _.assert( e.operation.encoding === 'buffer.bytes' );
  },

  onEnd : function( e )
  {
    var result = _.bufferBytesFrom( e.data );
    return result;
  },

}

// --
// relationship
// --

var Composes =
{
  protocols : _.define.own([]),
  _currentPath : '/',
  safe : 0,
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

var Statics =
{

  Path : _.uri.CloneExtending({ fileProvider : Self }),

}

// --
// declare
// --

var Proto =
{

  init : init,

  //path

  pathCurrentAct : pathCurrentAct,
  // pathResolveSoftLinkAct : pathResolveSoftLinkAct,
  // pathResolveHardLinkAct : pathResolveHardLinkAct,
  // linkSoftReadAct : linkSoftReadAct,

  // read

  fileReadAct : fileReadAct,
  // fileReadStreamAct : null,
  // directoryReadAct : directoryReadAct,

  // read stat

  fileStatAct : fileStatAct,
  // fileExistsAct : fileExistsAct,

  // fileIsTerminalAct : fileIsTerminalAct,

  // fileIsHardLink : fileIsHardLink,
  // fileIsSoftLink : fileIsSoftLink,
  // filesAreHardLinkedAct : filesAreHardLinkedAct,

  // write

  // fileWriteAct : fileWriteAct,
  // fileWriteStreamAct : null,
  // fileTimeSetAct : fileTimeSetAct,
  // fileDeleteAct : fileDeleteAct,
  // directoryMakeAct : directoryMakeAct,

  //link act

  // fileRenameAct : fileRenameAct,
  // fileCopyAct : fileCopyAct,
  // linkSoftAct : linkSoftAct,
  // linkHardAct : linkHardAct,
  // hardLinkBreakAct : hardLinkBreakAct,

  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.classDeclare
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

_.FileProvider.Find.mixin( Self );
_.FileProvider.Secondary.mixin( Self );

// --
// export
// --

_.FileProvider[ Self.shortName ] = Self;

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
