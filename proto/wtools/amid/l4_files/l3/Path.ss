(function _Path_ss_()
{

'use strict';

const _global = _global_;
const _ = _global_.wTools;
const Self = _global_.wTools.path;

_.assert( _.objectIs( Self ) );

// --
// path
// --

/**
 * Returns path for main module (module that running directly by node).
 * @returns {String}
 * @function realMainFile
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function realMainFile()
{
  return _.process.realMainFile();
}

//

/**
 * Returns path dir name for main module (module that running directly by node).
 * @returns {String}
 * @function realMainDir
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function realMainDir()
{
  return _.process.realMainDir();
}

//

/**
 * Returns absolute path for file running directly by node
 * @returns {String}
 * @throws {Error} If passed any argument.
 * @function effectiveMainFile
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function effectiveMainFile()
{
  return _.process.effectiveMainFile();
}

//

/**
 * Returns path dirname for file running directly by node
 * @returns {String}
 * @throws {Error} If passed any argument.
 * @function effectiveMainDir
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function effectiveMainDir()
{
  _.assert( arguments.length === 0, 'Expects no arguments' );

  let result = this.dir( this.effectiveMainFile() );

  return result;
}

//

function resolveTextLink( path )
{
  _.assert( !!this.fileProvider );
  return this.fileProvider.pathResolveTextLink.apply( this.fileProvider, arguments );
}

// //
//
// function _resolveTextLink( path )
// {
//   _.assert( !!this.fileProvider );
//   return this.fileProvider._pathResolveTextLink.apply( this.fileProvider, arguments );
// }

//

/**
 * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
 * for windows environment variables.
 * @returns {String}
 * @function userHome
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

function dirUserHome()
{
  const fileProvider = this.fileProvider.preferredProvider;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( _.routineIs( fileProvider.pathDirUserHomeAct ) );
  // if( this.userHomePath )
  // return this.userHomePath;
  return fileProvider.pathDirUserHomeAct();
}

//

function dirTemp()
{
  const fileProvider = this.fileProvider.preferredProvider;
  _.assert( arguments.length === 0, 'Expects no arguments' );
  _.assert( _.routineIs( fileProvider.pathDirTempAct ), () => 'Provider ' + fileProvider.qualifiedName + ' does not support temp files' );
  // if( this.tempPath )
  // return this.tempPath;
  return fileProvider.pathDirTempAct();
}

//

function dirTempAt( o )
{

  _.assert( arguments.length <= 2 );

  if( _.mapIs( o ) )
  {
    o = arguments[ 0 ];
  }
  else
  {
    if( arguments[ 1 ] !== undefined )
    o =
    {
      packagePath : arguments[ 0 ],
      packageName : arguments[ 1 ],
    }
    else
    o =
    {
      packageName : arguments[ 0 ],
    }
  }

  o = _.routine.options_( dirTempAt, o );

  if( !o.packageName )
  o.packageName = _.idWithGuid();
  else
  o.packageName = o.packageName + '-' + _.idWithTime();

  if( !o.packagePath )
  o.packagePath = this.dirTemp();

  _.assert( this.isAbsolute( o.packagePath ) );
  _.assert( !this.isAbsolute( o.packageName ), () => 'Option {- o.packageName -} should be relative path, but is ' + o.packageName );

  o.fullPath = this.join( o.packagePath, 'tmp.tmp', o.packageName );

  return o.fullPath;
}

dirTempAt.defaults =
{
  packageName : null,
  packagePath : null
}

// //
//
// function dirTempAtOpen( packagePath, packageName )
// {
//   _.assert( !!this.fileProvider );
//   packagePath = this.dirTempAt.apply( this, arguments );
//   this.fileProvider.filesDelete({ filePath : packagePath, throwing : 0 });
//   this.fileProvider.dirMake( packagePath );
//   return packagePath;
// }
//
// //
//
// function dirTempAtClose( filePath )
// {
//   _.assert( arguments.length === 1 );
//   _.assert( !!this.fileProvider );
//   _.assert( this.isAbsolute( filePath ) );
//   _.sure( _.strHas( this.normalize( filePath ), '/tmp.tmp/' ), 'Path does not contain temporary directory:', filePath );
//   this.fileProvider.filesDelete({ filePath : filePath, throwing : 0 });
// }

//

/*
filePath : /dir1/dir2/dir3

/dir1/dir2/dir3
/dir1/dir2
/dir1
/

Unix
/dir1 - device1
/dir1/dir2 - device2

*/

// function tempOpen( o )
// {
//   let self = this;

//   if( !_.mapIs( arguments[ 0 ] ) )
//   o = { filePath : arguments[ 0 ] }
//   if( arguments[ 1 ] !== undefined )
//   o.name = arguments[ 1 ];
//   o.filePath = self.resolve( o.filePath );

//   _.routine.options_( tempOpen, o );
//   _.assert( arguments.length === 1 || arguments.length === 2 );
//   _.assert( !!self.fileProvider );
//   _.assert( self.isAbsolute( o.filePath ) );

//   // o.filePath = self.normalize( o.filePath );

//   if( !self.pathDirTempForMap )
//   self.pathDirTempForMap = Object.create( null );

//   /* qqq : hacks */
//   let devicePath = devicePathGet( o.filePath );

//   if( self.pathDirTempForMap[ devicePath ] )
//   return self.pathDirTempForMap[ devicePath ];

//   let result = self.pathDirTempMake( o );

//   self.pathDirTempForMap[ devicePath ] = result;

//   return result;

//   /* */

//   /* qqq : please re */
//   function devicePathGet( path )
//   {
//     return '/';
//     // return path.substring( 0, path.indexOf( '/', 1 ) )
//   }

// }

let PathDirTempForMap = Object.create( null );
let PathDirTempCountMap = Object.create( null );

function tempOpen( o )
{
  let self = this;

  if( !_.mapIs( arguments[ 0 ] ) )
  o = { filePath : arguments[ 0 ] }
  if( arguments[ 1 ] !== undefined )
  o.name = arguments[ 1 ];
  if( o.filePath === undefined )
  o.filePath = self.current();
  else
  o.filePath = self.resolve( o.filePath );

  _.routine.options_( tempOpen, o );
  _.assert( arguments.length <= 2 );
  _.assert( !!self.fileProvider );
  _.assert( self.isAbsolute( o.filePath ) );
  _.assert( self.isNormalized( o.filePath ) );

  let id = self.fileProvider.id;

  /* qqq : use single map */
  if( !PathDirTempForMap[ id ] )
  PathDirTempForMap[ id ] = Object.create( null );
  if( !PathDirTempCountMap[ id ] )
  PathDirTempCountMap[ id ] = Object.create( null );

  /* search in cache */

  let cache = PathDirTempForMap[ id ];
  let count = PathDirTempCountMap[ id ];

  let result = cache[ o.filePath ];

  if( result )
  return end();

  let trace = self.traceToRoot( o.filePath );

  for( let i = trace.length - 1; i >= 0; i-- )
  {
    if( !cache[ trace[ i ] ] )
    continue;

    if( i !== trace.length - 1 )
    if( self.fileProvider.fileExists( trace[ i + 1 ] ) )
    {
      let currentStat = self.fileProvider.statReadAct
      ({
        filePath : trace[ i ],
        throwing : 1,
        sync : 1,
        resolvingSoftLink : 0,
      });
      let nextStat = self.fileProvider.statReadAct
      ({
        filePath : trace[ i + 1 ],
        throwing : 0,
        sync : 1,
        resolvingSoftLink : 0,
      });

      if( nextStat.dev !== currentStat.dev )
      break;
    }

    result = cache[ trace[ i ] ];

    return end();
  }

  /* make */

  result = self.pathDirTempMake({ filePath : o.filePath, name : o.name });
  return end();

  /*  */

  function end()
  {
    if( o.resolving )
    result = self.fileProvider.pathResolveLinkFull
    ({
      filePath : result,
      resolvingSoftLink : 1
    }).absolutePath;

    _.assert( !self.path.isGlobal( result ), 'Expects non-global path' );
    /* xxx : qqq : uncomment and fix */

    if( count[ result ] === undefined )
    count[ result ] = [];

    count[ result ].push( o.filePath );

    cache[ o.filePath ] = result;

    return result;
  }
}

tempOpen.defaults =
{
  filePath : null,
  name : null,
  resolving : 1,
  auto : 1
}

//

/*

filePath : /dir1/dir2/dir3

- dirMake
/Temp
/dir1/Temp
/dir1/dir2/Temp
/dir1/dir2/dir3/Temp

- fileRename
/Temp/x
/dir1/Temp/x
/dir1/dir2/Temp/x
/dir1/dir2/dir3/Temp/x

*/

/*

= /dir1 - device1, /dir1/dir2 - device2

open /dir1
  pathDirTempMake /dir1
  search from root
  cache
  /dir1 : /dir1/temp

open /dir1/dir2
  pathDirTempMake /dir1/dir2
  search and check cache
  search from root
  cache
    /dir1 : /dir1/temp
    /dir1/dir2 : /dir1/dir2/temp

close /dir1/dir2
  ceck cache
  cache
    /dir1 : /dir1/temp
  ceck cache 2nd time
  delete /dir1/dir2/Temp

close /dir1
  ceck cache
  cache
  ceck cache 2nd time
  delete /dir1/temp

*/

/*

= /dir1 - device1, /dir1/dir2 - device1

open /dir1
  pathDirTempMake /dir1
  search from root
  cache
  /dir1 : /dir1/temp

open /dir1/dir2
  pathDirTempMake /dir1/dir2
  search and check cache
  cache
    /dir1 : /dir1/temp
    /dir1/dir2 : /dir1/temp

close /dir1/dir2
  ceck cache
  cache
    /dir1 : /dir1/temp
  ceck cache 2nd time

close /dir1
  ceck cache
  cache
  ceck cache 2nd time
  delete /dir1/temp

*/

// function pathDirTempMake( o )
// {
//   let self = this;

//   _.routine.options_( pathDirTempMake, arguments );
//   _.assert( arguments.length === 1 );
//   _.assert( !!self.fileProvider );
//   _.assert( self.isAbsolute( o.filePath ) );
//   _.assert( self.isNormalized( o.filePath ) );

//   let filePath2;
//   var osTempDir = self.dirTemp();

//   if( !o.name )
//   o.name = 'tmp';
//   o.name = o.name + '-' + _.idWithDateAndTime() + '.tmp';

//   if( devicePathGet( osTempDir ) === devicePathGet( o.filePath ) )
//   {
//     filePath2 = self.join( osTempDir, o.name );
//     self.fileProvider.dirMake({ filePath : filePath2, sync : 1 });
//     return end();
//   }

//   let dirsPath = self.traceToRoot( o.filePath );
//   let err;
//   let tempPath = 'temp/' + o.name;

//   for( let i = 0, l = dirsPath.length - 1 || dirsPath.length ; i < l ; i++ )
//   {
//     filePath2 = dirsPath[ i ] + '/' + tempPath;

//     if( self.fileProvider.fileExists( filePath2 ) )
//     return end();

//     try
//     {
//       self.fileProvider.dirMake( filePath2 );
//       return end();
//     }
//     catch( e )
//     {
//       err = e;
//       // self.fileProvider.logger.log( 'Can`t create temp directory at :', filePath2 );
//     }
//   }

//   if( err )
//   throw _.err( 'Can`t create temp directory for:', o.filePath, '\n', err )

//   return end();

//   /* */

//   // function devicePathGet( filePath )
//   // {
//   //   return filePath.substring( 0, filePath.indexOf( '/', 1 ) )
//   // }

//   /* qqq : please redo properly */
//   function devicePathGet( path )
//   {
//     return '/';
//     // return path.substring( 0, path.indexOf( '/', 1 ) )
//   }

//   /* */

//   function end()
//   {
//     _.appExitHandlerOnce( () =>
//     {
//       debugger;
//       self.tempClose()
//     });
//     logger.log( ' . Open temp directory ' + filePath2 );
//     return filePath2;
//   }

// }

function pathDirTempMake( o )
{
  let self = this;

  _.routine.options_( pathDirTempMake, arguments );
  _.assert( arguments.length === 1 );
  _.assert( !!self.fileProvider );
  _.assert( self.isAbsolute( o.filePath ) );
  _.assert( self.isNormalized( o.filePath ) );

  let filePath = o.filePath;
  let err;

  let trace = self.traceToRoot( o.filePath );

  if( !trace.length )
  {
    _.assert( o.filePath === '/' );
    trace = [ o.filePath ];
  }
  else if( trace.length > 1 )
  trace.shift();

  if( !o.name )
  o.name = 'tmp';
  o.name = o.name + '-' + _.idWithDateAndTime() + '.tmp';

  /* */

  let osTempDir = self.dirTemp();
  let sameDevice = self.fileProvider.filesAreOnSameDevice( o.filePath, osTempDir );

  if( sameDevice )
  {
    filePath = self.join( osTempDir, o.name );
    self.fileProvider.dirMake( filePath );
    return end();
  }

  /* */

  let id = self.fileProvider.id;

  if( !PathDirTempForMap[ id ] )
  PathDirTempForMap[ id ] = Object.create( null );

  let cache = PathDirTempForMap[ id ];

  let fileStat;

  for( let i = 0; i < trace.length; i++ )
  {
    try
    {
      if( i !== trace.length - 1 )
      if( self.fileProvider.fileExists( trace[ i ] ) )
      {
        let currentStat = self.fileProvider.statReadAct
        ({
          filePath : trace[ i ],
          throwing : 1,
          sync : 1,
          resolvingSoftLink : 0,
        });

        if( fileStat === undefined )
        fileStat = self.fileProvider.statReadAct
        ({
          filePath : o.filePath,
          throwing : 0,
          sync : 1,
          resolvingSoftLink : 0,
        });

        if( fileStat )
        if( fileStat.dev != currentStat.dev )
        continue;
      }

      if( cache[ trace[ i ] ] )
      {
        filePath = cache[ trace[ i ] ];
      }
      else
      {
        filePath = self.join( trace[ i ], 'Temp', o.name );
        if( !self.fileProvider.fileExists( filePath ) )
        self.fileProvider.dirMake( filePath );
      }

      return end();
    }
    catch( e )
    {
      err = e;
    }
  }

  if( err )
  {
    filePath = _.path.join( osTempDir, o.name );
    self.fileProvider.dirMake( filePath );
  }

  return end();

  /* */

  function end()
  {

    if( o.auto )
    // _.process._exitHandlerOnce( () =>
    // _.process.on( 'available', () => _.process.on( 'exit', () =>

    // _.process.on( 'available', _.event.Name( 'exit' ), () =>
    _.process.on( _.event.Chain( 'available', 'exit' ), () =>
    {
      self.tempClose()
    });

    // logger.log( ' . Open temp directory ' + filePath );
    return filePath;
  }
}

pathDirTempMake.defaults = Object.create( tempOpen.defaults );

//

// function tempClose( tempDirPath )
// {
//   let self = this;

//   _.assert( arguments.length <= 1 );
//   _.assert( !!self.fileProvider );

//   debugger;

//   if( !self.pathDirTempForMap )
//   return;

//   if( !arguments.length )
//   {
//     for( let d in self.pathDirTempForMap )
//     {
//       close( d );
//     }
//   }
//   else
//   {
//     _.assert( self.isAbsolute( tempDirPath ) );
//     _.assert( self.isNormalized( tempDirPath ) );

//     let devicePath = devicePathGet( tempDirPath );

//     debugger;
//     if( !self.pathDirTempForMap[ devicePath ] )
//     throw _.err( 'Not found temp dir for device ' + devicePath );

//     if( self.pathDirTempForMap[ devicePath ] !== tempDirPath )
//     throw _.err
//     (
//         'Registered temp directory', self.pathDirTempForMap[ devicePath ]
//       , '\nAttempt to unregister temp directory', tempDirPath
//     );

//     close( devicePath );

//     // self.fileProvider.filesDelete({ filePath : tempDirPath, safe : 0, throwing : 1 });
//     // _.assert( !self.fileProvider.fileExists( tempDirPath ) );
//     // delete self.pathDirTempForMap[ devicePath ];

//   }

//   function close( keyPath )
//   {
//     let tempPath = self.pathDirTempForMap[ keyPath ];
//     self.fileProvider.filesDelete
//     ({
//       filePath : tempPath,
//       safe : 0,
//       throwing : 0,
//     });
//     delete self.pathDirTempForMap[ keyPath ];
//     _.assert( !self.fileProvider.fileExists( tempPath ) );
//     logger.log( ' . Close temp directory ' + tempPath );
//     debugger;
//     return tempPath;
//   }

//   /* qqq : please redo properly */
//   function devicePathGet( path )
//   {
//     return '/';
//     // return path.substring( 0, path.indexOf( '/', 1 ) )
//   }

// }

//

function tempClose( filePath )
{
  let self = this;

  _.assert( arguments.length <= 1 );
  _.assert( !!self.fileProvider );

  let id = self.fileProvider.id;

  if( !PathDirTempForMap[ id ] )
  return;

  let cache = PathDirTempForMap[ id ];
  let count = PathDirTempCountMap[ id ];

  if( !arguments.length )
  {
    for( let path in cache )
    {
      delete count[ cache[ path ] ];
      close( path );
    }
  }
  else
  {
    _.assert( self.isAbsolute( filePath ) );
    _.assert( self.isNormalized( filePath ) );

    let currentTempPath = cache[ filePath ];

    /* reverse search for case when filePath is a temp path */
    if( !currentTempPath )
    for( let path in cache )
    if( cache[ path ] === filePath )
    {
      currentTempPath = filePath;
      filePath = path;
      break;
    }

    if( !currentTempPath )
    throw _.err( 'Not found temp dir for path: ' + filePath );

    _.arrayRemoveElementOnce( count[ currentTempPath ], filePath );

    /* if temp path is still in use */
    if( count[ currentTempPath ].length )
    {
      if( !_.longHas( count[ currentTempPath ], filePath ) )
      delete cache[ filePath ];
      return;
    }

    _.assert( !count[ currentTempPath ].length );

    delete count[ currentTempPath ];

    close( filePath );
  }

  /*  */

  function close( filePath )
  {
    let tempPath = cache[ filePath ];
    self.fileProvider.filesDelete
    ({
      filePath : tempPath,
      safe : 0,
      throwing : 0,
    });
    delete cache[ filePath ];
    _.assert( !self.fileProvider.fileExists( tempPath ), 'Temp dir:', _.strQuote( tempPath ), 'was closed, but still exist in file system.' );
    // logger.log( ' . Close temp directory ' + tempPath );
    // debugger;
    return tempPath;
  }
}

/* Next pathDirTemp* */

// let Index = Object.create( null );
// let IndexPath = _.path.join( Os.homedir(), '.wFiles/TempFilesIndex' );
// let IndexLockTimeOut = 30000;

// function _loadIndex( syncLock )
// {
//   let self = this;
//   if( !self.fileProvider.fileExists( self.IndexPath ) )
//   {
//     self.Index.namespace = Object.create( null );
//     self.Index.tempDir = Object.create( null );
//     self.Index.count = Object.create( null );
//     self.fileProvider.fileWrite({ filePath : self.IndexPath, data : self.Index, encoding : 'json' });
//   }

//   let lockReady = self.fileProvider.fileLock
//   ({
//     filePath : self.IndexPath,
//     sync : !!syncLock,
//     throwing : 1,
//     timeOut : self.IndexLockTimeOut,
//     sharing : 'process',
//     waiting : 1
//   })
//   if( !syncLock )
//   {
//     lockReady.deasync();
//     lockReady.sync();
//   }
//   _.assert( self.fileProvider.fileIsLocked( self.IndexPath ) );

//   let loadedIndex = self.fileProvider.fileRead({ filePath : self.IndexPath, encoding : 'json' });
//   self.Index = _.mapSupplementRecursive( self.Index, loadedIndex );
//   self.fileProvider.fileUnlock( self.IndexPath );
//   _.assert( !self.fileProvider.fileIsLocked( self.IndexPath ) );
// }

// //

// function _saveIndex( syncLock )
// {
//   let self = this;

//   _.assert( _.objectIs( self.Index ) )

//   let lockReady = self.fileProvider.fileLock
//   ({
//     filePath : self.IndexPath,
//     sync : !!syncLock,
//     throwing : 1,
//     timeOut : self.IndexLockTimeOut,
//     sharing : 'process',
//     waiting : 1
//   });
//   if( !syncLock )
//   {
//     lockReady.deasync();
//     lockReady.sync();
//   }
//   _.assert( self.fileProvider.fileIsLocked( self.IndexPath ) );
//   let loadedIndex = self.fileProvider.fileRead({ filePath : self.IndexPath, encoding : 'json' });
//   _.props.extend( loadedIndex, self.Index );
//   self.fileProvider.fileWrite({ filePath : self.IndexPath, data : loadedIndex, encoding : 'json' });
//   self.fileProvider.fileUnlock( self.IndexPath );
// }

// function _nextPathDirTempOpen( o )
// {
//   let self = this;

//   if( !_.mapIs( arguments[ 0 ] ) )
//   o = { filePath : arguments[ 0 ] }
//   if( arguments[ 1 ] !== undefined )
//   o.name = arguments[ 1 ];
//   if( o.filePath === undefined )
//   o.filePath = self.current();
//   else
//   o.filePath = self.resolve( o.filePath );

//   _.routine.options_( _nextPathDirTempOpen, o );
//   _.assert( arguments.length <= 2 );
//   _.assert( !!self.fileProvider );
//   _.assert( self.isAbsolute( o.filePath ) );
//   _.assert( self.isNormalized( o.filePath ) );

//   // let id = self.fileProvider.id;

//   /* load cache */

//   self._loadIndex();

//   // let currentIndex = self.Index[ process.pid ];

//   // let cache = currentIndex.cache[ id ];
//   // let count = currentIndex.count[ id ];

//   /* search in cache */

//   let result = null;
//   let namespace = o.name;

//   let nameSpaceMap = self.Index.namespace;
//   let tempDirMap = self.Index.tempDir;

//   if( tempDirMap[ o.filePath ] )
//   if( tempDirMap[ o.filePath ].namespace === namespace )
//   {
//     result = tempDirMap[ o.filePath ].tempPath;
//     return end();
//   }

//   let trace = self.traceToRoot( o.filePath );

//   for( let i = trace.length - 1; i >= 0; i-- )
//   {
//     if( !tempDirMap[ trace[ i ] ] )
//     continue;
//     if( tempDirMap[ trace[ i ] ].namespace !== namespace )
//     continue;

//     if( i !== trace.length - 1 )
//     if( self.fileProvider.fileExists( trace[ i + 1 ] ) )
//     {
//       let currentStat = self.fileProvider.statReadAct
//       ({
//         filePath : trace[ i ],
//         throwing : 1,
//         sync : 1,
//         resolvingSoftLink : 0,
//       });
//       let nextStat = self.fileProvider.statReadAct
//       ({
//         filePath : trace[ i + 1 ],
//         throwing : 0,
//         sync : 1,
//         resolvingSoftLink : 0,
//       });

//       if( nextStat.dev !== currentStat.dev )
//       break;
//     }

//     result = tempDirMap[ trace[ i ] ].tempPath;

//     return end();
//   }

//   /* make */

//   result = self._nextPathDirTempMake({ filePath : o.filePath, name : o.name });
//   return end();

//   /*  */

//   function end()
//   {
//     if( !nameSpaceMap[ namespace ] )
//     {
//       nameSpaceMap[ namespace ] = Object.create( null );
//       nameSpaceMap[ namespace ].tempDir = o.filePath;
//       nameSpaceMap[ namespace ].tempPath = result;
//     }

//     if( !tempDirMap[ o.filePath ] )
//     {
//       tempDirMap[ o.filePath ] = Object.create( null );
//       tempDirMap[ o.filePath ].namespace = namespace;
//       tempDirMap[ o.filePath ].tempPath = result;
//     }

//     let countMap = self.Index.count;
//     if( !countMap[ result ] )
//     countMap[ result ] = [];
//     countMap[ result ].push( o.filePath )

//     self._saveIndex();

//     return result;
//   }
// }

// _nextPathDirTempOpen.defaults =
// {
//   filePath : null,
//   name : null,
//   auto : 1
// }

//

// function _nextPathDirTempMake( o )
// {
//   let self = this;

//   _.routine.options_( _nextPathDirTempMake, arguments );
//   _.assert( arguments.length === 1 );
//   _.assert( !!self.fileProvider );
//   _.assert( self.isAbsolute( o.filePath ) );
//   _.assert( self.isNormalized( o.filePath ) );

//   let filePath = o.filePath;
//   let err;

//   let trace = self.traceToRoot( o.filePath );

//   if( !trace.length )
//   {
//     _.assert( o.filePath === '/' );
//     trace = [ o.filePath ];
//   }

//   if( !o.name )
//   o.name = 'tmp';
//   let namespace = o.name;
//   o.name = o.name + '-' + _.idWithDateAndTime() + '.tmp';

//   let osTempDir = self.dirTemp();

//   let common = self.common( osTempDir, trace[ 0 ] )

//   if( common === trace[ 0 ] )
//   {
//     filePath = self.join( osTempDir, o.name );
//     self.fileProvider.dirMake( filePath );
//     return end();
//   }

//   /* load cache */

//   self._loadIndex();

//   // let id = self.fileProvider.id;
//   // let currentIndex = self.Index[ process.pid ];

//   let tempDirMap = self.Index.tempDir;

//   // let cache = currentIndex.cache[ id ];

//   let fileStat;

//   for( let i = 0; i < trace.length; i++ )
//   {
//     try
//     {
//       if( i !== trace.length - 1 )
//       if( self.fileProvider.fileExists( trace[ i ] ) )
//       {
//         let currentStat = self.fileProvider.statReadAct
//         ({
//           filePath : trace[ i ],
//           throwing : 1,
//           sync : 1,
//           resolvingSoftLink : 0,
//         });

//         if( fileStat === undefined )
//         fileStat = self.fileProvider.statReadAct
//         ({
//           filePath : o.filePath,
//           throwing : 0,
//           sync : 1,
//           resolvingSoftLink : 0,
//         });

//         if( fileStat )
//         if( fileStat.dev != currentStat.dev )
//         continue;
//       }

//       let tempDir = tempDirMap[ trace[ i ] ];
//       if( tempDir && tempDir.namespace === namespace )
//       {
//         filePath = tempDir.tempPath;
//       }
//       else
//       {
//         filePath = self.join( trace[ i ], 'Temp', o.name );
//         if( !self.fileProvider.fileExists( filePath ) )
//         self.fileProvider.dirMake( filePath );
//       }

//       return end();
//     }
//     catch( e )
//     {
//       err = e;
//     }
//   }

//   if( err )
//   {
//     filePath = _.path.join( osTempDir, o.name );
//     self.fileProvider.dirMake( filePath );
//   }

//   return end();

//   /* */

//   function end()
//   {
//     if( o.auto )
//     _.process._exitHandlerOnce( () =>
//     {
//       debugger;
//       self._nextPathDirTempClose({ syncLock : 1 })
//     });

//     // logger.log( ' . Open temp directory ' + filePath );

//     return filePath;
//   }
// }

// _nextPathDirTempMake.defaults = Object.create( _nextPathDirTempOpen.defaults );

//

// function _nextPathDirTempClose( o )
// {
//   let self = this;

//   if( arguments.length === 0 )
//   o = Object.create( null );

//   if( _.strIs( o ) )
//   o = { filePath : o }

//   _.assert( arguments.length <= 1 );
//   _.assert( !!self.fileProvider );
//   _.routine.options_( _nextPathDirTempClose, o );

//   self._loadIndex( o.syncLock );

//   // if( !self.PathDirTempForMap[ id ] )
//   // return;

//   // let currentIndex = self.Index[ process.pid ];
//   // let id = self.fileProvider.id;

//   // let cache = currentIndex.cache[ id ];
//   // let count = currentIndex.count[ id ];

//   let namespaceMap = self.Index.namespace;
//   let tempDirMap = self.Index.tempDir;
//   let countMap = self.Index.count;
//   let filePath = o.filePath;

//   if( filePath === null )
//   {
//     for( let path in tempDirMap )
//     {
//       let tempDir = tempDirMap[ path ];
//       delete namespaceMap[ tempDir.namespace ];
//       delete countMap[ tempDir.tempPath ];
//       close( path );
//     }
//   }
//   else
//   {
//     _.assert( self.isAbsolute( filePath ) );
//     _.assert( self.isNormalized( filePath ) );

//     let currentTempPath = null;

//     if( tempDirMap[ filePath ] )
//     currentTempPath = tempDirMap[ filePath ].tempPath;

//     /* reverse search for case when filePath is a temp path */
//     if( !currentTempPath )
//     for( let path in tempDirMap )
//     if( tempDirMap[ path ].tempPath === filePath )
//     {
//       currentTempPath = filePath;
//       filePath = path;
//       break;
//     }

//     if( !currentTempPath )
//     throw _.err( 'Not found temp dir for path: ' + filePath );

//     let namespace = tempDirMap[ filePath ].namespace;

//     _.arrayRemoveElementOnce( countMap[ currentTempPath ], filePath );

//     /* if temp path is still in use */
//     if( countMap[ currentTempPath ].length )
//     {
//       if( !_.longHas( countMap[ currentTempPath ], filePath ) )
//       {
//         delete namespaceMap[ namespace ];
//         delete tempDirMap[ filePath ];
//       }
//     }
//     else
//     {
//       _.assert( !countMap[ currentTempPath ].length );

//       delete countMap[ currentTempPath ];

//       close( filePath );
//     }
//   }

//   self._saveIndex( o.syncLock );

//   /*  */

//   function close( filePath )
//   {
//     let tempPath = tempDirMap[ filePath ].tempPath;
//     self.fileProvider.filesDelete
//     ({
//       filePath : tempPath,
//       safe : 0,
//       throwing : 0,
//     });
//     delete tempDirMap[ filePath ];
//     _.assert( !self.fileProvider.fileExists( tempPath ), 'Temp dir:', _.strQuote( tempPath ), 'was closed, but still exist in file system.' );
//     // logger.log( ' . Close temp directory ' + tempPath );
//     // debugger;
//     return tempPath;
//   }
// }

// _nextPathDirTempClose.defaults =
// {
//   filePath : null,
//   syncLock : 0
// }

//

function forCopy_head( routine, args )
{

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { filePath : o };

  _.routine.options_( routine, o );
  _.assert( _.strIs( o.filePath ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function forCopy_body( o )
{
  let path = this;
  const fileProvider = this.fileProvider;

  _.assert( arguments.length === 1, 'Expects single argument' );

  let postfix = _.strPrependOnce( o.postfix, o.postfix ? '-' : '' );
  let file = fileProvider.recordFactory().record( o.filePath );
  let name = file.name;

  let parts = _.strSplitFast({ src : name, delimeter : '-', preservingEmpty : 0, preservingDelimeters : 0 });
  if( parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0, parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous

  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  name = parts.slice( 0, parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  name = parts.slice( 0, parts.length-2 ).join( '-' );

  /*file.absolute =  file.dir + '/' + file.name + file.extWithDot;*/

  let filePath = path.join( file.dir, name + postfix + file.extWithDot );
  if( !fileProvider.statResolvedRead({ filePath, sync : 1 }) )
  return filePath;

  let attempts = 1 << 13;
  let index = 1;

  while( attempts > 0 )
  {

    let filePath = path.join( file.dir, name + postfix + '-' + index + file.extWithDot );

    if( !fileProvider.statResolvedRead({ filePath, sync : 1 }) )
    return filePath;

    attempts -= 1;
    index += 1;

  }

  throw _.err( 'Cant make copy path for : ' + file.absolute );
}

forCopy_body.defaults =
{
  delimeter : '-',
  postfix : 'copy',
  filePath : null,
}

var having = forCopy_body.having = Object.create( null );
having.driving = 0;
having.aspect = 'body';

//

/**
 * Generate path string for copy of existing file passed into `o.path`. If file with generated path is exists now,
 * method try to generate new path by adding numeric index into tail of path, before extension.
 * @example
 * let str = 'foo/bar/baz.txt',
   let path = wTools.pathforCopy( {path : str } ); // 'foo/bar/baz-copy.txt'
 * @param {Object} o options argument
 * @param {string} o.path Path to file for create name for copy.
 * @param {string} [o.postfix='copy'] postfix for mark file copy.
 * @returns {string} path for copy.
 * @throws {Error} If missed argument, or passed more then one.
 * @throws {Error} If passed object has unexpected property.
 * @throws {Error} If file for `o.path` is not exists.
 * @function forCopy
 * @namespace wTools.path
 * @module Tools/mid/Files
 */

let forCopy = _.routine.uniteCloning_replaceByUnite( forCopy_head, forCopy_body );

forCopy.having.aspect = 'entry';

function _firstAvailable_head( routine, args )
{

  _.assert( args.length === 1 );

  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { paths : o }

  _.routine.options_( routine, o );
  _.assert( _.arrayIs( o.paths ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  return o;
}

//

function _firstAvailable_body( o )
{
  let path = this;
  const fileProvider = path.fileProvider;

  _.assert( arguments.length === 1, 'Expects single argument' );

  for( let p = 0 ; p < o.paths.length ; p++ )
  {
    let path = o.paths[ p ];
    if( fileProvider.fileExists( o.onPath ? o.onPath.call( o, path, p ) : path ) )
    return path;
  }

  return undefined;
}

_firstAvailable_body.defaults =
{
  paths : null,
  onPath : null,
}

var having = _firstAvailable_body.having = Object.create( null );
having.driving = 0;
having.aspect = 'body';

let firstAvailable = _.routine.uniteCloning_replaceByUnite( _firstAvailable_head, _firstAvailable_body );
firstAvailable.having.aspect = 'entry';

// --
// declare
// --

// let Fields =
// {
//   PathDirTempForMap,
//   PathDirTempCountMap,
//
//   // Index,
//   // IndexPath,
//   // IndexLockTimeOut,
// }

let Extension =
{

  realMainFile,
  realMainDir,

  effectiveMainFile,
  effectiveMainDir,

  resolveTextLink,
  // _resolveTextLink,

  dirUserHome,
  dirTemp,

  /* qqq merge dirTempAtOpen + tempOpen and dirTempAtClose + tempClose */

  dirTempAt,
  // dirTempAtOpen,
  // dirTempAtClose,

  tempOpen,
  pathDirTempMake,
  tempClose,

  forCopy,
  firstAvailable,

  // fields

  PathDirTempForMap,
  PathDirTempCountMap,

}

_.props.extend( Self, Extension );

// --
// export
// --

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;

})();
