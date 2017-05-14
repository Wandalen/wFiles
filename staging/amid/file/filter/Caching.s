( function _Caching_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../aprovider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.Caching )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCaching( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCaching without new please' );
}

Self.nameShort = 'Caching';

//

function init( o )
{

  var self = _.instanceFilterInit
  ({
    cls : Self,
    parent : Parent,
    extend : Extend,
    args : arguments,
  });

  if( self.watchPath )
  self._createFileWatcher();

  // x
  //
  // var self = Object.create( null );
  //
  // _.instanceInit( self,Self.prototype );
  //
  // if( o )
  // Self.prototype.copyCustom.call( self,
  // {
  //   proto : Self.prototype,
  //   src : o,
  //   technique : 'object',
  // });
  //
  // if( !self.original )
  // self.original = _.FileProvider.Default();
  //
  // _.mapExtend( self,Extend );
  //
  // Object.setPrototypeOf( self,self.original );
  // Object.preventExtensions( self );

  return self;
}

//

function fileStatAct( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  if( !self.cachingStats )
  {
    // o.filePath = self.pathNativize( o.filePath );
    return self.original.fileStatAct( o );
  }

  // var original = self.original.fileStatAct;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var filePath = o;

  // debugger;

  function handleEnd( stat )
  {
    if( o.sync || o.sync === undefined )
    return stat;
    else
    return new wConsequence().give( stat );
  }

  if( self._cacheStats[ o.filePath ] !== undefined )
  {
    return handleEnd( self._cacheStats[ o.filePath ] );
  }
  else
  {
    var filePath = _.pathResolve( o.filePath );
    if( self._cacheStats[ filePath ] !== undefined )
    {
      return handleEnd( self._cacheStats[ filePath ] );
    }

    // if( _.strIs( o ) )
    // {
    //   o = _.pathResolve( o );
    //   if( self._cacheStats[ o ] !== undefined )
    //   return  self._cacheStats[ o ];
    // }
    // else
    // if( _.objectIs( o ) )
    // {
    //   o = _.routineOptions( fileStatAct,o )
    //   o = _.pathResolve( o );
    //   if( o.sync === undefined )
    //   o.sync = 1;
    //
    //   o.filePath = _.pathResolve( o.filePath );
    //   if( self._cacheStats[ filePath ] )
    //   {
    //     if( o.sync )
    //     return self._cacheStats[ filePath ];
    //     else
    //     return wConsequence().give( self._cacheStats[ filePath ] );
    //   }
    // }

    // console.log( 'fileStatAct' );

    // o.filePath = self.pathNativize( o.filePath );
    var stat = self.original.fileStatAct( o );
    // o.filePath = _.pathResolve( o.filePath );


    // console.log( o );

    if( o.sync )
    self._cacheStats[ filePath ] = stat;
    else
    stat.got( function( err, got )
    {
      self._cacheStats[ filePath ] = got;
      stat.give( err, got );
    });

    // if( _.strIs( o ) )
    // self._cacheStats[ o ] = stat;
    // else
    // {
    //   if( o.sync )
    //   self._cacheStats[ filePath ] = stat;
    //   else
    //   stat.got( function( err, got )
    //   {
    //     self._cacheStats[ filePath ] = got;
    //     stat.give( err, got );
    //   });
    // }

    // console.log( 'self._cache',self._cache );

    return stat;

    // if( o.sync )
    // {
    //   self._cache[ filePath ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ filePath ] = got;
    //     return got;
    //   })
    // }
  }
}

fileStatAct.defaults = {};
fileStatAct.defaults.__proto__ = Abstract.prototype.fileStatAct.defaults;

//

function directoryReadAct( o )
{
  var self = this;


  if( _.strIs( o ) )
  o = { filePath : o };

  if( !self.cachingDirs )
  {
    // o.filePath = self.pathNativize( o.filePath );
    return self.original.directoryReadAct( o );
  }

  // var original = self.original.directoryReadAct;

  // var o = _._fileOptionsGet.apply( original,arguments );
  // var filePath = o;

  // debugger;

  function handleEnd( files )
  {
    if( o.sync || o.sync === undefined )
    return files;
    else
    return new wConsequence().give( files );
  }

  if( self._cacheDir[ o.filePath ] !== undefined )
  {
    return handleEnd( self._cacheDir[ o.filePath ] );
  }
  else
  {
    var filePath = _.pathResolve( o.filePath );
    if( self._cacheDir[ filePath ] !== undefined )
    return handleEnd( self._cacheDir[ filePath ] );


    // if( _.strIs( o ) )
    // {
    //   o = _.pathResolve( o );
    //   if( self._cacheDir[ o ] !== undefined )
    //   return  self._cacheDir[ o ];
    // }
    // else if( _.objectIs( o ) )
    // {
    //   o = _.routineOptions( directoryReadAct,o )
    //   // o = _.pathResolve( o );
    //   o.filePath = _.pathResolve( o.filePath );
    //   if( self._cacheDir[ o.filePath ] )
    //   {
    //     if( o.sync )
    //     return self._cacheDir[ o.filePath ];
    //     else
    //     return wConsequence().give( self._cacheDir[ o.filePath ] );
    //   }
    // }

    // console.log( 'directoryReadAct' );
    // o.filePath = self.pathNativize( o.filePath );
    var files = self.original.directoryReadAct.call( self, o );
    // o.filePath = _.pathResolve( o.filePath );

    // console.log( o );

    if( o.sync )
    self._cacheDir[ filePath ] = files;
    else
    files.doThen( function( err, got )
    {
      self._cacheDir[ filePath ] = got;
      if( err )
      throw err;
      return got;
    });

    // if( _.strIs( o ) )
    // self._cacheDir[ o ] = files;
    // else
    // {
    //   if( o.sync )
    //   self._cacheDir[ o.filePath ] = files;
    //   else
    //   files.doThen( function( err, got )
    //   {
    //     self._cacheDir[ o.filePath ] = got;
    //     if( err )
    //     throw err;
    //     return got;
    //   });
    // }

    // console.log( 'self._cache',self._cache );

    return files;

    // if( o.sync )
    // {
    //   self._cache[ filePath ] = stat;
    //   return stat;
    // }
    // else
    // {
    //   return stat.doThen( function( err, got )
    //   {
    //     if( err )
    //     throw err;
    //     self._cache[ filePath ] = got;
    //     return got;
    //   })
    // }
  }
}

directoryReadAct.defaults = {};
directoryReadAct.defaults.__proto__ = Abstract.prototype.directoryReadAct.defaults;

//

function fileRecord( filePath, o )
{
  var self = this;

  if( !self.cachingRecord )
  return _.FileRecord( filePath, o );

  var record = _.FileRecord._fileRecordAdjust( filePath, o );

  if( self._cacheRecord[ record.absolute ] !== undefined )
  {
    var index = self._cacheRecord[ record.absolute ].indexOf( o );
    if( index >= 0 )
    return self._cacheRecord[ record.absolute ][ index + 1 ];
  }

  var record = _.FileRecord( filePath, o );
  if( !self._cacheRecord[ record.absolute ] )
  self._cacheRecord[ record.absolute ] = [];
  self._cacheRecord[ record.absolute ].push( o, record );

  return record;
}

fileRecord.defaults = {};
fileRecord.defaults.__proto__ = Abstract.prototype.fileRecord.defaults;

//

function _dirUpdate( filePath )
{
  var self = this;

  if( !self.cachingDirs )
  return;

  filePath = _.pathResolve( filePath );

  if( self._cacheDir[ filePath ] !== undefined )
  self._cacheDir[ filePath ] = self.original.directoryRead( filePath );

  var dirPath = _.pathDir( filePath );
  var fileName = _.pathName({ path : filePath, withExtension : 1 });

  var dir = self._cacheDir[ dirPath ];

  if( dir === null )
  self._cacheDir[ dirPath ] = self.original.directoryRead( dirPath );

  if( dir )
  {
    if( dir.indexOf( fileName ) === -1 )
    dir.push( fileName );
  }
}

//

function _recordUpdate( path )
{
  var self = this;

  var filePath = _.pathResolve( path );

  if( self.cachingRecord )
  if( self._cacheRecord[ filePath ] !== undefined )
  {
    for( var i = 1; i <= self._cacheRecord[ filePath ].length; i += 2 )
    {
      var o = self._cacheRecord[ filePath ][ i - 1 ];
      self._cacheRecord[ filePath ][ i ] = _.FileRecord( filePath, o );
    }
  }
}

//

function _statUpdate( path,stat )
{
  var self = this;

  var filePath = _.pathResolve( path );
  if( self.cachingStats )
  {
    if( self._cacheStats[ filePath ] !== undefined )
    {
      if( stat === undefined )
      stat = self.original.fileStat( path );
      self._cacheStats[ filePath ] = stat;
    }
  }
}

//

function _removeFromCache( path )
{
  var self = this;

  var filePath = _.pathResolve( path );

  function _removeChilds( cache )
  {
    var files = Object.keys( cache );
    for( var i = 0; i < files.length; i++  )
    if( _.pathDir( files[ i ] ) === filePath )
    cache[ files[ i ] ] = null;
    // delete cache[ files[ i ] ];
  }

  if( self.cachingStats )
  {
    if( self._cacheStats[ filePath ] !== undefined )
    {
      var stat = self._cacheStats[ filePath ];
      if( _.objectIs( stat ) && stat.isDirectory() || stat === null )
      {
        var files = Object.keys( self._cacheStats );
        for( var i = 0; i < files.length; i++  )
        if( _.strBegins( files[ i ], filePath ) )
        self._cacheStats[ files[ i ] ] = null;
      }
      else
      self._cacheStats[ filePath ] = null;
    }
  }

  if( self.cachingRecord )
  {
    var files = Object.keys( self._cacheRecord );
    for( var i = 0; i < files.length; i++  )
    {
      if( _.strBegins( files[ i ], filePath ) )
      for( var j = 1; j <= self._cacheRecord[ files[ i ] ].length; j += 2 )
      self._cacheRecord[ files[ i ] ][ j ] = null;
    }

  }

  if( self.cachingDirs )
  {
    _removeChilds( self._cacheDir );

    if( self._cacheDir[ filePath ] )
    {
      self._cacheDir[ filePath ] = null;
      // delete self._cacheDir[ filePath ];
    }

    var pathDir = _.pathDir( filePath );
    var fileName = _.pathName({ path : filePath, withExtension : 1 });
    var dir = self._cacheDir[ pathDir ];
    if( dir )
    {
      var index = dir.indexOf( fileName );
      if( index >= 0  )
      dir.splice( index, 1 );
    }
  }

}

//

function _createFileWatcher()
{
  var self = this;

  if( !self.fileWatcher )
  {
    var chokidar = require('chokidar');

    self.watchOptions.ignoreInitial = true;
    // self.watchOptions.usePolling = true;
    // self.watchOptions.awaitWriteFinish =
    // {
    //   stabilityThreshold: 2000,
    //   pollInterval: 100
    // };

    self.fileWatcher = chokidar.watch( self.watchPath,self.watchOptions );

    self.fileWatcher.onReady = new wConsequence();
    self.fileWatcher.onUpdate = new wConsequence();


    self.fileWatcher.on( 'ready', function( path )
    {
      self.fileWatcher.onReady.give( 'ready' );
    });

    // self.fileWatcher.on( 'raw', function( event, path, details )
    // {
    //   console.log(event, path, details);
    // })

    self.fileWatcher.on( 'all', function( event, path, details )
    {
      // console.log( event, path );

      if( event === 'add' || event === 'addDir' )
      {
          self._statUpdate( path );
          self._dirUpdate( path );
          self._recordUpdate( path );
          self.fileWatcher.onUpdate.give( event );
      }

      if( event === 'change' )
      {
        self._statUpdate( path );
        self._recordUpdate( path );
        self.fileWatcher.onUpdate.give( event );
      }

      if( event === 'unlink' || event === 'unlinkDir' )
      {
        self._removeFromCache( path );
        self.fileWatcher.onUpdate.give( event );
      }
    });
  }
}

//

function fileReadAct( o )
{
  var self = this;
  var result;

  if( o.sync )
  {
    try
    {
      result = self.original.fileReadAct( o );
    }
    catch( err )
    {
      throw err;
    }
    finally
    {
      if( self.updateOnRead )
      {
        self._statUpdate( o.filePath );
        self._recordUpdate( o.filePath );
      }

    }
  }

  if( !o.sync )
  {
    var result = self.original.fileReadAct( o );
    if( !self.updateOnRead )
    return result;

    result.doThen( function( err, got )
    {
      self._statUpdate( o.filePath );
      self._recordUpdate( o.filePath );
      if( err )
      return err;
      return got;
    });
  }

  return result;
}

fileReadAct.defaults = {};
fileReadAct.defaults.__proto__ = Abstract.prototype.fileReadAct.defaults;

//

function fileHashAct( o )
{
  var self = this;

  var result = self.original.fileHashAct( o );

  if( !self.updateOnRead )
  return result;

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( !_.isNaN( got ) )
      if( self.updateOnRead )
      {
        self._statUpdate( o.filePath );
        self._recordUpdate( o.filePath );
      }

      return got;
    });
  }
  else
  {
    if( !_.isNaN( result ) )
    if( self.updateOnRead )
    {
      self._statUpdate( o.filePath );
      self._recordUpdate( o.filePath );
    }
  }


  return result;
}

fileHashAct.defaults = {};
fileHashAct.defaults.__proto__ = Abstract.prototype.fileHashAct.defaults;

//

function fileWriteAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }

  var result = self.original.fileWriteAct( o );

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      self._recordUpdate( o.filePath );
      self._statUpdate( o.filePath );
      self._dirUpdate( o.filePath );
    });
  }
  else
  {
    self._recordUpdate( o.filePath );
    self._statUpdate( o.filePath );
    self._dirUpdate( o.filePath );
  }

  return result;
}

fileWriteAct.defaults = {};
fileWriteAct.defaults.__proto__ = Abstract.prototype.fileWriteAct.defaults;

//

function fileTimeSetAct( o )
{
  var self = this;

  if( arguments.length === 3 )
  o =
  {
    filePath : arguments[ 0 ],
    atime : arguments[ 1 ],
    mtime : arguments[ 2 ],
  }

  var result = self.original.fileTimeSetAct( o );

  var filePath = _.pathResolve( o.filePath );

  if( self.cachingStats )
  {
    if( self._cacheStats[ filePath ] )
    {
      self._cacheStats[ filePath ].atime = o.atime;
      self._cacheStats[ filePath ].mtime = o.mtime;
    }
  }

  if( self.cachingRecord )
  {
    var record = self._cacheRecord[ filePath ];
    if( record )
    {
      for( var i = 1; i <= record.length; i += 2 )
      if( record[ i ].stat )
      {
        record[ i ].stat.atime = o.atime;
        record[ i ].stat.mtime = o.mtime;
      }

    }
  }

  return result;
}

fileTimeSetAct.defaults = {};
fileTimeSetAct.defaults.__proto__ = Abstract.prototype.fileTimeSetAct.defaults;

//

function fileDelete( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.fileDelete( o );

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      self._removeFromCache( o.filePath );
    });
  }
  else
  {
    self._removeFromCache( o.filePath );
  }
  return result;
}

fileDelete.defaults = {};
fileDelete.defaults.__proto__ = Abstract.prototype.fileDelete.defaults;

//

function directoryMake( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.directoryMake.call( self, o );

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      self._statUpdate( o.filePath );
      self._dirUpdate( o.filePath );
      self._recordUpdate( o.filePath );
    });
  }
  else
  {
    self._statUpdate( o.filePath );
    self._dirUpdate( o.filePath );
    self._recordUpdate( o.filePath );
  }

  return result;
}

directoryMake.defaults = {};
directoryMake.defaults.__proto__ = Abstract.prototype.directoryMake.defaults;

//

function fileRenameAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.fileRenameAct( o );

  //

  function _rename( o )
  {
    if( o.pathDst === o.pathSrc )
    return;

    var pathSrc = _.pathResolve( o.pathSrc );
    var pathDst = _.pathResolve( o.pathDst );

    if( self.cachingStats )
    if( self._cacheStats[ pathSrc ] )
    {
      if( self._cacheStats[ pathSrc ].isDirectory() )
      {
        var files = Object.keys( self._cacheStats );
        for( var i = 0; i < files.length; i++  )
        if( _.strBegins( files[ i ], pathSrc ) )
        {
          delete self._cacheStats[ files[ i ] ];
        }
      }
      else
      {
        self._cacheStats[ pathSrc ] = null;
      }
      self._cacheStats[ pathDst ] = self.original.fileStat( pathDst );
    }

    if( self.cachingDirs )
    {
      var pathSrc = _.pathResolve( o.pathSrc );
      self._removeFromCache( o.pathSrc );
      if( self._cacheDir[ _.pathResolve( o.pathSrc ) ] !== undefined )
      self._cacheDir[ _.pathResolve( o.pathDst ) ] = null;
      self._dirUpdate( o.pathDst );
      // var oldName = _.pathName({ path : pathSrc, withExtension : 1 });
      // if( self._cacheDir[ pathSrc ] )
      // if( self._cacheDir[ pathSrc ][ 0 ]  === oldName )
      // {
      //   var newName = _.pathName({ path : pathDst, withExtension : 1 });
      //   self._cacheDir[ pathSrc ][ 0 ] = newName;
      // }
      //
      // var pathDir = _.pathDir( pathSrc );
      // var dir = self._cacheDir[ pathDir ];
      // if( dir )
      // {
      //   var index = dir.indexOf( oldName );
      //   if( index >= 0  )
      //   dir.splice( index, 1 );
      //   var fileName = _.pathName({ path : pathDst, withExtension : 1 });
      //   dir.push( fileName );
      // }
      //
      // var files = Object.keys( self._cacheDir );
      // for( var i = 0; i < files.length; i++ )
      // {
      //   if( _.strBegins( files[ i ], pathSrc ) )
      //   {
      //     var newPath = _.strReplaceAll( files[ i ], pathSrc, pathDst );
      //     self._cacheDir[ newPath ] = self._cacheDir[ files[ i ] ];
      //     delete self._cacheDir[ files[ i ] ];
      //   }
      // }

    }
    if( self.cachingRecord )
    {
      var files = Object.keys( self._cacheRecord );
      for( var i = 0; i < files.length; i++  )
      {
        if( _.strBegins( files[ i ], pathSrc ) || _.strBegins( files[ i ], pathDst ) )
        for( var j = 1; j <= self._cacheRecord[ files[ i ] ].length; j += 2 )
        self._cacheRecord[ files[ i ] ][ j ] = null;
      }
      // if( self._cacheRecord[ pathSrc ] )
      // {
        // var files = Object.keys( self._cacheRecord );
        // for( var i = 0; i < files.length; i++  )
        // if( _.strBegins( files[ i ], pathSrc ) )
        // delete self._cacheRecord[ files[ i ] ];
      // }
      // if( self._cacheRecord[ pathDst ] )
      // {
        // var files = Object.keys( self._cacheRecord );
        // for( var i = 0; i < files.length; i++  )
        // if( _.strBegins( files[ i ], pathDst ) )
        // delete self._cacheRecord[ files[ i ] ];
      // }
      //
      // if( self._cacheRecord[ pathDst ] )
      // for( var i = 0; i < self._cacheRecord[ pathDst ].length; i += 2 )
      // {
      //   var o = self._cacheRecord[ pathDst ][ i ];
      //   self._cacheRecord[ pathDst ][ i + 1 ] = _.FileRecord( pathDst, o );
      // }
    }
  }

  //

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _rename( o );
    });
  }
  else
  {
    _rename( o );
  }

  return result;
}

fileRenameAct.defaults = {};
fileRenameAct.defaults.__proto__ = Abstract.prototype.fileRenameAct.defaults;

//

function fileCopyAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.fileCopyAct( o );

  function _copy()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.updateOnRead )
    self._statUpdate( o.pathSrc );

    self._statUpdate( o.pathDst );

    if( self.cachingDirs )
    self._dirUpdate( o.pathDst );

    if( self.cachingRecord )
    {
      if( self.updateOnRead )
      {
        self._recordUpdate( o.pathSrc );
      }

      var pathDst = _.pathResolve( o.pathDst );
      if( self._cacheRecord[ pathDst ] )
      delete self._cacheRecord[ pathDst ];

    }
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _copy();
    });
  }
  else
  _copy();

  return result;
}

fileCopyAct.defaults = {};
fileCopyAct.defaults.__proto__ = Abstract.prototype.fileCopyAct.defaults;

//

function linkSoftAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.linkSoftAct( o );

  function _link()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.updateOnRead )
    self._statUpdate( o.pathSrc );

    self._statUpdate( o.pathDst );

    if( self.cachingDirs )
    self._dirUpdate( o.pathDst );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _link();
    });
  }
  else
  _link();

  return result;
}

linkSoftAct.defaults = {};
linkSoftAct.defaults.__proto__ = Abstract.prototype.linkSoftAct.defaults;

//

function linkHardAct( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  var result = self.original.linkHardAct( o );

  function _link()
  {
    if( o.pathDst === o.pathSrc )
    return;

    if( self.updateOnRead )
    self._statUpdate( o.pathSrc );

    self._statUpdate( o.pathDst );

    if( self.cachingDirs )
    self._dirUpdate( o.pathDst );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      _link();
    });
  }
  else
  _link();

  return result;
}

linkHardAct.defaults = {};
linkHardAct.defaults.__proto__ = Abstract.prototype.linkHardAct.defaults;

//

function fileExchange( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    pathDst : arguments[ 0 ],
    pathSrc : arguments[ 1 ],
  }

  if( !self.cachingStats && !self.cachingRecord && !self.cachingDirs )
  return self.original.fileExchange( o );

  var pathSrc = o.pathSrc;
  var pathDst = o.pathDst;

  var src = self.original.fileStat( o.pathSrc );
  var dst = self.original.fileStat( o.pathDst );

  var result = self.original.fileExchange.call( self, o );

  function _exchange()
  {
    if( !src && dst )
    {
      self._statUpdate( pathSrc );
      self._recordUpdate( pathSrc );
    }
    if( !dst && src )
    {
      self._statUpdate( pathDst );
      self._recordUpdate( pathDst );
    }

    if( src && dst )
    {
      self._statUpdate( pathSrc );
      self._recordUpdate( pathSrc );
      self._statUpdate( pathDst );
      self._recordUpdate( pathDst );
    }
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      {
        _exchange();
      }
      return got;
    });
  }
  else if( result )
  {
    _exchange();
  }

  return result;
}

fileExchange.defaults = {};
fileExchange.defaults.__proto__ = Abstract.prototype.fileExchange.defaults;


// --
// relationship
// --

var Composes =
{
  original : null,
  cachingDirs : 1,
  cachingStats : 1,
  cachingRecord : 1,
  updateOnRead : 0,
  watchPath : null,
  watchOptions : Object.create( null )
}

var Aggregates =
{
}

var Associates =
{
}

var Restricts =
{
  _cacheStats : Object.create( null ),
  _cacheDir : Object.create( null ),
  _cacheRecord : Object.create( null ),
  fileWatcher : null,
}

// --
// prototype
// --

var Extend =
{
  fileStatAct : fileStatAct,
  directoryReadAct : directoryReadAct,
  fileRecord : fileRecord,

  fileReadAct : fileReadAct,

  fileHashAct : fileHashAct,

  fileWriteAct : fileWriteAct,

  fileTimeSetAct : fileTimeSetAct,

  fileDelete : fileDelete,

  directoryMake : directoryMake,

  fileRenameAct : fileRenameAct,
  fileCopyAct : fileCopyAct,
  linkSoftAct : linkSoftAct,
  linkHardAct : linkHardAct,

  fileExchange : fileExchange,

  _statUpdate : _statUpdate,
  _dirUpdate : _dirUpdate,
  _recordUpdate : _recordUpdate,
  _removeFromCache : _removeFromCache,

  _createFileWatcher : _createFileWatcher

}

//

var Proto =
{

  init : init,

  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

_.mapExtend( Proto,Extend );

_.protoMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

_.FileFilter.Caching = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
