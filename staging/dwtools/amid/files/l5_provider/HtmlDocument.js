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

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    encoder.onBegin.call( self,o );

  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,o,data );

    if( o.sync )
    {
      return data;
    }
    else
    {
      return con.give( data );
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
      err = encoder.onError.call( self,{ error : err, transaction : o, encoder : encoder })
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

  /* exec */

  handleBegin();

  // if( _.strHas( o.filePath, 'icons.woff2' ) )
  // debugger;

  o.filePath = self.pathResolveLink
  ({
    filePath : o.filePath,
    resolvingSoftLink : o.resolvingSoftLink,
    resolvingTextLink : o.resolvingTextLink,
  });

  if( self.hub && _.uri.isGlobal( o.filePath ) )
  {
    _.assert( self.hub !== self );
    return self.hub.fileReadAct( o );
  }

  var result = self._descriptorRead( o.filePath );

  // if( self._descriptorIsLink( result ) )
  // {
  //   result = self._descriptorResolve({ descriptor : result });
  //   if( result === undefined )
  //   return handleError( _.err( 'Cant pathResolve :', result ) );
  // }

  if( self._descriptorIsHardLink( result ) )
  {
    var resolved = self._descriptorResolve({ descriptor : result });
    if( resolved === undefined )
    return handleError( _.err( 'Cant pathResolve :', result ) );
    result = resolved;
  }

  if( result === undefined || result === null )
  {
    debugger;
    result = self._descriptorRead( o.filePath );
    return handleError( _.err( 'File at :', o.filePath, 'doesn`t exist!' ) );
  }

  if( self._descriptorIsDir( result ) )
  return handleError( _.err( 'Can`t read from dir : ' + _.strQuote( o.filePath ) + ' method expects file' ) );
  if( self._descriptorIsLink( result ) )
  return handleError( _.err( 'Can`t read from link : ' + _.strQuote( o.filePath ) + ', without link resolving enabled' ) );
  if( !_.strIs( result ) )
  return handleError( _.err( 'Can`t read file : ' + _.strQuote( o.filePath ) ) );

  if( self.usingTime )
  self._fileTimeSet({ filePath : o.filePath, atime : _.timeNow() });

  return handleEnd( result );
}

var defaults = fileReadAct.defaults = Object.create( Parent.prototype.fileReadAct.defaults );
var having = fileReadAct.having = Object.create( Parent.prototype.fileReadAct.having );

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assertRoutineOptions( fileStatAct,o );

  /* */

  function _fileStatAct( filePath )
  {
    var result = null;

    filePath = self.pathResolveLink({ filePath : filePath, resolvingSoftLink : o.resolvingSoftLink });

    var file = self._descriptorRead( filePath );

    if( !_.definedIs( file ) )
    {
      // _.assert( !file );
      if( o.throwing )
      throw _.err( 'Path :', filePath, 'doesn`t exist!' );
      return result;
    }

    result = new _.FileStat();

    if( self.timeStats && self.timeStats[ filePath ] )
    {
      var timeStats = self.timeStats[ filePath ];
      for( var k in timeStats )
      result[ k ] = new Date( timeStats[ k ] );
    }

    result.isFile = function() { return false; };
    result.isDirectory = function() { return false; };
    result.isSymbolicLink = function() { return false; };

    if( self._descriptorIsDir( file ) )
    {
      result.isDirectory = function() { return true; };
    }
    else if( self._descriptorIsTerminal( file ) )
    {
      result.isFile = function() { return true; };
      result.size = file.length;
    }
    // else if( self._descriptorIsHardLink( file ) )
    // {
    //   file = file[ 0 ];

    //   // if( o.resolvingHardLink )
    //   {
    //     var r = _fileStatAct( file.hardLink );
    //     if( r ) /* qqq : really return? */
    //     return r;
    //   }

    // }
    else if( self._descriptorIsSoftLink( file ) )
    {
      // file = file[ 0 ];

      // if( o.resolvingSoftLink )
      // {
      //   var r = _fileStatAct( file.softLink );
      //   if( r )
      //   return r;
      // }

      result.isSymbolicLink = function() { return true; };

    }
    else if( self._descriptorIsScript( file ) )
    {
    }

    return result;
  }

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

}

_.routineExtend( fileStatAct, Parent.prototype.fileStatAct );

// --
// encoders
// --

var encoders = Object.create( null );

fileReadAct.encoders = encoders;

encoders[ 'utf8' ] =
{

  onBegin : function( o )
  {
    debugger; throw _.err( 'not tested' );
    _.assert( o.encoding === 'utf8' );
  },

  onEnd : function( o,data )
  {
    var result = data;
    _.assert( _.strIs( result ) );
    return result;
  },

}

encoders[ 'ascii' ] =
{

  onBegin : function( o )
  {
    debugger; throw _.err( 'not tested' );
    _.assert( o.encoding === 'ascii' );
  },

  onEnd : function( o,data )
  {
    var result = data;
    _.assert( _.strIs( result ) );
    return result;
  },

}

encoders[ 'latin1' ] =
{

  onBegin : function( o )
  {
    debugger; throw _.err( 'not tested' );
    _.assert( o.encoding === 'latin1' );
  },

  onEnd : function( o,data )
  {
    var result = data;
    _.assert( _.strIs( result ) );
    return result;
  },

}

if( !isBrowser )
encoders[ 'buffer-raw' ] =
{

  onBegin : function( e )
  {
    _.assert( e.encoding === 'buffer-raw' );
  },

  onEnd : function( e, data )
  {
    debugger; throw _.err( 'not tested' );
    _.assert( _.strIs( data ) );

    var nodeBuffer = Buffer.from( data )
    var result = _.bufferRawFrom( nodeBuffer );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
  },

}

if( !isBrowser )
encoders[ 'buffer-node' ] =
{

  onBegin : function( e )
  {
    debugger; throw _.err( 'not tested' );
    _.assert( e.encoding === 'buffer-node' );
  },

  onEnd : function( e, data )
  {
    _.assert( _.strIs( data ) );

    var result = Buffer.from( data );

    _.assert( _.bufferNodeIs( result ) );
    _.assert( !_.bufferRawIs( result ) );

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

  Path : _.uri,

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
