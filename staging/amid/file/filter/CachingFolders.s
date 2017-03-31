( function _CachingFolders_s_() {

'use strict';

var isBrowser = true;
if( typeof module !== 'undefined' )
{
  isBrowser = false;

  require( '../aprovider/Abstract.s' );

}

wTools.FileFilter = wTools.FileFilter || Object.create( null );
if( wTools.FileFilter.CachingFolders )
return;

//

var _ = wTools;
var Abstract = _.FileProvider.Abstract;
var Default = _.FileProvider.Default;
var Parent = null;
var Self = function wFileFilterCachingFolders( o )
{
  if( !( this instanceof Self ) )
  return Self.prototype.init.apply( this,arguments );
  throw _.err( 'Call wFileFilterCachingFolders without new please' );
}

Self.nameShort = 'CachingFolders';

//

function init( o )
{

  var self = _.instanceFilterInit
  ({
    constructor : Self,
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

function _filesTree( o )
{
  _.assert( arguments.length === 1 );
  _.routineOptions( filesTree,o );

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
  //     _.toStr( structure, { json : 1 , multiline : 1 } )
  //   );
  //
  //   if( o.verbosity )
  //   console.log( "File tree written to: ", filePath );
  //
  //   return filePath;
  // }

  return structure;
}

filesTree.defaults =
{
  filePath : null,
  fileProvider : null,
}

//

function filesTree( filePath )
{
   var o = Object.create( null );
   o.filePath = filePath;
   if( !isBrowser )
   o.fileProvider = _.FileProvider.HardDrive();
   else
   o.fileProvider = _.FileProvider.SimpleStructure({ filesTree : {} });

   return _filesTree( o )
}

//

function _select( path )
{
  var self = this;

  // if( _.objectIs( path ) )
  // path = path.filePath;

  path = _.pathRelative( self.rootPath, path );

  if( path === '.' )
  path = '';

  var result = _.entitySelect
  ({
    container : self.tree,
    query : path,
    delimeter : [ './', '/' ]
  });

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
directoryRead.defaults.__proto__ = Abstract.prototype.directoryRead.defaults;

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
  _filesTree : _filesTree,
  filesTree : filesTree,
}

// --
// prototype
// --

var Extend =
{
  _select : _select,
  directoryRead : directoryRead,
  // cache : cache,
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

_.protoMake
({
  constructor : Self,
  parent : Parent,
  extend : Proto,
});

// wCopyable.mixin( Self );

//

_.FileFilter.CachingFolders = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
