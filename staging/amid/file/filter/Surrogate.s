( function _Surrogate_s_() {

'use strict';

var isBrowser = true;
if( typeof module !== 'undefined' )
{
  isBrowser = false;

  try
  {
    require( '../../../Base.s' );
  }
  catch( err )
  {
    require( 'wTools' );
  }

  var _ = wTools;

  if( !wTools.FileProvider.Partial )
  require( '../aprovider/aPartial.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.Surrogate )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Partial = _.FileProvider.Partial;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterSurrogate( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterSurrogate without new please' );
}

Self.nameShort = 'Surrogate';

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
  // self.original = _.FileFilter.Caching();
  //
  // _.mapExtend( self,Extend );
  //
  // Object.setPrototypeOf( self,self.original );
  // Object.preventExtensions( self );

  return self;
}

//

function _filesTreeMake( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( filesTreeMake,o );

  _.assert( _.strIs( o.filePath ), "Routine expects o.filePath as string." );
  _.assert( o.fileProvider instanceof _.FileProvider.Abstract );

  if( o.verbosity )
  console.log( "Caching files tree using path:", o.filePath );

  var files = o.fileProvider.filesFind
  ({
    filePath : o.filePath,
    recursive : 1,
    includeDirectories: 1
  });

  var structure = Object.create( null );
  var set;

  for( var i = 0; i < files.length; ++i )
  {
    set = '';
    if( files[ i ].isDirectory )
    {
      if( _.entitySelect( structure, files[ i ].relative ) )
      continue;
      set = {};
    }

    // var set = files[ i ].isDirectory ? {} : '';

    _.entitySelect
    ({
      container : structure,
      query : files[ i ].relative,
      set : set,
      usingSet : 1,
      delimeter : [ './', '/' ]
    });
  }

  // if( o.writeToFile )
  // {
  //   var fileName = _.pathChangeExt( _.pathName( o.filePath ), 'js' );
  //   var filePath = _.pathJoin( o.filePath, fileName );
  //   this.original.fileWrite
  //   (
  //     filePath,
  //     _.toStr( structure, { jsonLike : 1 , multiline : 1 } )
  //   );
  //
  //   if( o.verbosity )
  //   console.log( "File tree written to: ", filePath );
  //
  //   return filePath;
  // }

  return structure;
}

filesTreeMake.defaults =
{
  filePath : null,
  fileProvider : null,
}

//

function filesTreeMake( filePath )
{
   var o = Object.create( null );
   o.filePath = filePath;
   if( !isBrowser )
   o.fileProvider = _.FileProvider.HardDrive();
   else
   o.fileProvider = _.FileProvider.SimpleStructure({ filesTree : {} });

   return _filesTreeMake( o )
}

//

function _select( path, mode, value )
{
  var self = this;

  // if( _.objectIs( path ) )
  // path = path.filePath;

  var usingSet = mode === 'set' ? 1 : 0;
  var usingDelete = mode === 'delete' ? 1 : 0;
  var usingGet = mode === 'get' ? 1 : 0;

  path = _.pathRelative( self.rootPath, path );

  if( usingDelete )
  {
    var pathDir = _.pathResolve( _.pathDir( path ) );
    pathDir = _.pathRelative( self.rootPath, pathDir );
    if( pathDir === '.' )
    pathDir = '';
    var fileName = _.pathName({ path : path, withExtension : 1 });
  }

  if( path === '.' )
  path = '';

  var result = _.entitySelect
  ({
    container : self.tree,
    query : usingDelete ? pathDir : path,
    usingSet : usingSet,
    set : value,
    delimeter : [ './', '/' ]
  });

  if( usingGet )
  return result;

  if( usingDelete )
  return delete result[ fileName ];

  if( _.objectIs( result ) )
  return Object.keys( result );

  if( _.strIs( result ) )
  {
    var nameWithExt = _.pathName({ path : path, withExtension : 1 });
    return [ nameWithExt ];
  }
}

//

function directoryRead( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o }

  _.routineOptions( directoryRead, o );

  if( !_.strIsNotEmpty( o.filePath ) )
  handleError();

  var result = null;

  function handleEnd()
  {
    if( o.sync )
    return result;
    else
    return wConsequence().give( result );
  }

  function handleError()
  {
    var err = _.err( "No such file or directory: ", '"' + o.filePath + '"' )
    if( o.sync )
    throw err;
    else
    return wConsequence().error( err );
  }

  result = self._select( o.filePath );

  if( result !== undefined )
  return handleEnd();
  else
  {
    result = self._select( _.pathResolve( o.filePath ) );

    if( result !== undefined )
    return handleEnd();
  }

  if( o.throwing )
  handleError();

  result = null;

  return handleEnd();

  // if( _.strIs( o ) )
  // {
  //   o = _.pathResolve( o );
  //   var result = self._select( o );
  //   if( result !== undefined )
  //   return result;
  // }

  // if( _.objectIs( o ) )
  // {
    // o.filePath = _.pathResolve( o.filePath );
    //
    // var result = self._select( o.filePath );
    //
    // if( result !== undefined )
    // {
    //   if( o.sync )
    //   return result;
    //   else
    //   return wConsequence().give( result );
    // }
  // }



}

directoryRead.defaults = {};
directoryRead.defaults.__proto__ = Partial.prototype.directoryRead.defaults;


//

function fileWrite( o )
{
  var self = this;

  if( arguments.length === 2 )
  {
    o = { filePath : arguments[ 0 ], data : arguments[ 1 ] };
  }

  var result = self.original.fileWrite( o );

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      self._select( o.filePath, 'set', '' );
    });
  }
  else
  self._select( o.filePath, 'set', '' );

  return result;
}

fileWrite.defaults = {};
fileWrite.defaults.__proto__ = Partial.prototype.fileWrite.defaults;

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
      self._select( o.filePath, 'delete' );
    });
  }
  else
  {
    self._select( o.filePath, 'delete' );
  }

  return result;
}

fileDelete.defaults = {};
fileDelete.defaults.__proto__ = Partial.prototype.fileDelete.defaults;

//

function directoryMake( o )
{
  var self = this;

  if( _.strIs( o ) )
  o = { filePath : o };

  var result = self.original.directoryMake( o );

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function()
    {
      self._select( o.filePath, 'set', {} );
    });
  }
  else
  {
    self._select( o.filePath, 'set', {} );
  }

  return result;
}

directoryMake.defaults = {};
directoryMake.defaults.__proto__ = Partial.prototype.directoryMake.defaults;

//

function fileRename( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }

  var result = self.original.fileRename( o );

  function _rename()
  {
    if( o.dstPath === o.srcPath )
    return;

    var src = self._select( o.srcPath, 'get' );
    self._select( o.dstPath, 'set', src );
    self._select( o.srcPath, 'delete' );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _rename();
      return got;
    });
  }
  else if( result )
  _rename();

  return result;
}

fileRename.defaults = {};
fileRename.defaults.__proto__ = Partial.prototype.fileRename.defaults;

//

function fileCopy( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }

  var result = self.original.fileCopy( o );

  function _copy()
  {
    if( o.dstPath === o.srcPath )
    return;

    var src = self._select( o.srcPath, 'get' );
    self._select( o.dstPath, 'set', src );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _copy();
      return got;
    });
  }
  else if( result )
  _copy();

  return result;
}

fileCopy.defaults = {};
fileCopy.defaults.__proto__ = Partial.prototype.fileCopy.defaults;

//

function linkSoft( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }

  var result = self.original.linkSoft( o );

  function _link()
  {
    if( o.dstPath === o.srcPath )
    return;

    var src = self._select( o.srcPath, 'get' );
    self._select( o.dstPath, 'set', src );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _link();
      return got;
    });
  }
  else if( result )
  _link();

  return result;
}

linkSoft.defaults = {};
linkSoft.defaults.__proto__ = Partial.prototype.linkSoft.defaults;

//

function linkHard( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }

  var result = self.original.linkHard( o );

  function _link()
  {
    if( o.dstPath === o.srcPath )
    return;

    var src = self._select( o.srcPath, 'get' );
    self._select( o.dstPath, 'set', src );
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _link();
      return got;
    });
  }
  else if( result )
  _link();

  return result;
}

linkHard.defaults = {};
linkHard.defaults.__proto__ = Partial.prototype.linkHard.defaults;

//

function fileExchange( o )
{
  var self = this;

  if( arguments.length === 2 )
  o =
  {
    dstPath : arguments[ 0 ],
    srcPath : arguments[ 1 ],
  }

  var srcPath = o.srcPath;
  var dstPath = o.dstPath;

  var result = self.original.fileExchange( o );

  function _exchange()
  {
    o.srcPath = srcPath;
    o.dstPath = dstPath;

    if( o.dstPath === o.srcPath )
    return;

    var src = self._select( o.srcPath );
    var dst = self._select( o.dstPath );

    if( !src && !dst )
    return;

    if( !src && dst )
    {
      self._select( o.srcPath, 'set', dst );
      self._select( o.dstPath, 'delete' );
    }
    else if( src && !dst )
    {
      self._select( o.dstPath, 'set', src );
      self._select( o.srcPath, 'delete' );
    }
    else
    {
      self._select( o.srcPath, 'set', dst );
      self._select( o.dstPath, 'set', src );
    }
  }

  if( !o.sync )
  {
    return result
    .ifNoErrorThen( function( got )
    {
      if( got )
      _exchange();
      return got;
    });
  }
  else if( result )
  _exchange();

  return result;
}

fileExchange.defaults = {};
fileExchange.defaults.__proto__ = Partial.prototype.fileExchange.defaults;

// --
// relationship
// --

var Composes =
{
  tree : null,
  rootPath : null,
  original : null
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
  _filesTreeMake : _filesTreeMake,
  filesTreeMake : filesTreeMake,
}

// --
// prototype
// --

var Extend =
{

  _select : _select,

  directoryRead : directoryRead,

  fileWrite : fileWrite,

  fileDelete : fileDelete,

  directoryMake : directoryMake,

  fileRename : fileRename,
  fileCopy : fileCopy,
  linkSoft : linkSoft,
  linkHard : linkHard,

  fileExchange : fileExchange,

}

//

var Proto =
{

  init : init,

  //


  //

  constructor : Self,
  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,
  Statics : Statics,

}

//

_.mapExtend( Proto,Extend );

_.classMake
({
  cls : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

_.FileFilter.Surrogate = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
