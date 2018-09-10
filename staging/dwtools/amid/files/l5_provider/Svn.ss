( function _Svn_ss_() {

'use strict';

if( typeof module !== 'undefined' )
{
  var _global = _global_;
  var _ = _global_.wTools;

  if( !_.FileProvider )
  require( '../UseMid.s' );

  var Svn;

}
var _global = _global_;
var _ = _global_.wTools;
var FileRecord = _.FileRecord;

//

var Parent = _.FileProvider.Partial;
var Self = function wFileProviderSvn( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Svn';

// --
// inter
// --

function init( o )
{
  var self = this;
  Parent.prototype.init.call( self,o );
  self.form();
}

//

function finit( o )
{
  var self = this;
  self.unform();
  Parent.prototype.finit.call( self,o );
}

//

function form( o )
{
  var self = this;

  if( !Svn )
  Svn = require( 'node-svn-ultimate' );

  self.tempPath = self.path.dirTempOpen();

  if( !self.hardDrive )
  self.hardDrive = new _.FileProvider.HardDrive();

  _.assert( self.hardDrive instanceof _.FileProvider.HardDrive )

}

//

function unform( o )
{
  var self = this;

  if( self.tempPath )
  {
    _.fileProvider.filesDelete( self.tempPath );
    self.tempPath = null;
  }

}

// --
// adapter
// --

function localFromUri( url )
{
  var self = this;

  if( _.strIs( url ) )
  return url;

  _.assert( _.mapIs( url ) ) ;
  _.assert( arguments.length === 1, 'expects single argument' );

  return _.uri.str( url );
}

// --
// read
// --

function _fileDownload( filePath )
{
  var self = this;
  var con = new _.Consequence();

  var remoteUrl = _.uri.join( remoteUrl, filePath );
  var tempPath = self.path.join( self.tempPath, filePath );

  Svn.commands.checkout( remoteUrl, tempPath, function( err )
  {
    if( err )
    con.error( _.err( err ) );
  });

  con.ifNoErrorThen( function()
  {
    return tempPath;
  });

  return con;
}

//

function fileReadAct( o )
{
  var self = this;
  var stack = '';
  var result = null;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.routineOptions( fileReadAct,o );
  _.assert( !o.sync,'not implemented' );

  if( 0 )
  if( Config.debug )
  stack = _._err({ usingSourceCode : 0, args : [] });

  var encoder = fileReadAct.encoders[ o.encoding ];

  /* begin */

  function handleBegin()
  {

    if( encoder && encoder.onBegin )
    _.sure( encoder.onBegin.call( self,{ operation : o, encoder : encoder }) === undefined ); // xxx

  }

  /* end */

  function handleEnd( data )
  {

    if( encoder && encoder.onEnd )
    data = encoder.onEnd.call( self,{ data : data, operation : o, encoder : encoder })

    if( o.sync )
    return data;
    else
    return con.give( data );

  }

  /* error */

  function handleError( err )
  {

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
    throw err;
    else
    return con.error( err );

  }

  /* exec */

  handleBegin();

  if( o.sync )
  {

    result = File.readFileSync( o.filePath,o.encoding === 'buffer' ? undefined : o.encoding );

    return handleEnd( result );
  }
  else
  {
    var con = self._fileDownload( o.filePath );

    con.ifNoErrorThen( function( filePath )
    {
      var options = _.mapExtend( null,o );
      o.filePath = filePath;
      return self.hardDrive.fileRead( o );
    });

    return con;
  }

}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Parent.prototype.fileReadAct.defaults;
fileReadAct.isOriginalReader = 1;

//

function fileStatAct( o )
{
  var self = this;

  _.assert( arguments.length === 1, 'expects single argument' );
  _.assert( _.strIs( o.filePath ) );
  _.assert( !o.sync,'not implemented' );

  var o = _.routineOptions( fileStatAct,o );
  var result = null;

  /* */

  debugger;

  var stat = Object.create( null );
  stat.ino = 0;
  stat.dev = 0;
  stat.nlink = 1;

  var result = self._fileDownload.ifNoErrorThen( function( filePath )
  {
    var localStat = self.hardDrive.fileStat({ filePath : filePath });
    stat.size = localStat.size;
    return stat;
  });

  // dev: 2114,
  // ino: 48064969,
  // mode: 33188,
  // nlink: 1,
  // uid: 85,
  // gid: 100,
  // rdev: 0,
  // size: 527,
  // blksize: 4096,
  // blocks: 8,
  // atimeMs: 1318289051000.1,
  // mtimeMs: 1318289051000.1,
  // ctimeMs: 1318289051000.1,
  // birthtimeMs: 1318289051000.1,
  // atime: Mon, 10 Oct 2011 23:24:11 GMT,
  // mtime: Mon, 10 Oct 2011 23:24:11 GMT,
  // ctime: Mon, 10 Oct 2011 23:24:11 GMT,
  // birthtime: Mon, 10 Oct 2011 23:24:11 GMT

  debugger;

  return stat;
}

fileStatAct.defaults = {};
fileStatAct.defaults.__proto__ = Parent.prototype.fileStatAct.defaults;

//

function directoryReadAct( o )
{
  var self = this;
  var o = _.routineOptions( directoryReadAct,o );

  _.assert( o.sync );

  debugger; xxx

  var result = Svn.commands.list();

  return result;
}

directoryReadAct.defaults = {};
directoryReadAct.defaults.__proto__ = Parent.prototype.directoryReadAct.defaults;

// --
// encoder
// --

var encoders = {};
fileReadAct.encoders = encoders;

// --
// relationship
// --

var Composes =
{
  protocols : [ 'svn' ],
  // define classcols : [ 'svn' ],
  // originPath : null,
  remoteUrl : null,
  tempPath : null
}

var Aggregates =
{
}

var Associates =
{
  hardDrive : null,
}

var Restricts =
{
}

var Statics =
{
}

// --
// declare
// --

var Proto =
{

  // inter

  init : init,
  finit : finit,

  form : form,
  unform : unform,


  // adapter

  localFromUri : localFromUri,


  // read

  _fileDownload : _fileDownload,

  fileReadAct : fileReadAct,
  fileReadStreamAct : null,
  fileStatAct : fileStatAct,

  directoryReadAct : directoryReadAct,


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
// if( _.FileProvider.Path )
// _.FileProvider.Path.mixin( Self );

//

_.FileProvider[ Self.shortName ] = Self;

// --
// export
// --

if( typeof module !== 'undefined' )
if( _global_.WTOOLS_PRIVATE )
delete require.cache[ module.id ];

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
