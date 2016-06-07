(function(){

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  try
  {
    require( 'wPath.s' );
    require( 'wId.s' );
  }
  catch( err )
  {
    require( '../../abase/component/Path.s' );
    require( '../../abase/component/Id.s' );
  }

  try
  {
    require( 'wFileCommon.s' );
  }
  catch( err )
  {
    require( '../../amid/file/FileCommon.s' );
  }

}

var Path = require( 'path' );
var File = require( 'fs-extra' );

var Self = wTools;
var _ = wTools;

//

/*

problems :

  !!! naming problem : fileStore / fileDirectory / fileAny

*/

//

var fileRecord = function( file,options )
{

  if( _.objectIs( file ) )
  {
    if( options )
    throw _.err( 'Not tested' );
    return file;
  }

  var options = options || {};
  var record = {};

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapOnly( options,_fileRecord.defaults );

  if( !_.strIs( file ) )
  throw _.err( 'fileRecord:','file argument must be a string' );

  file = _.pathNormalize( file );

  if( options.dir === undefined ) options.dir = Path.dirname( file );
  else if( _.objectIs( options.dir ) ) options.dir = _.pathNormalize( options.dir.absolute );
  else options.dir = _.pathNormalize( options.dir );

  if( options.relative === undefined ) options.relative = options.dir;
  else if( _.objectIs( options.relative ) ) options.relative = _.pathNormalize( options.relative.absolute );
  else options.relative = _.pathNormalize( options.relative );

  file = _.pathRelative( options.dir,file );

  return _._fileRecord( file,options );
}

//

var _fileRecord = function( file,options )
{
  var record = {};
  var pathFile;

  if( !_.strIs( file ) )
  throw _.err( '_fileRecord:','file must be string' );

  if( !_.strIs( options.relative ) && !_.strIs( options.dir ) )
  throw _.err( '_fileRecord:','expects options.relative or options.dir' );

  _.assertMapOnly( options,_fileRecord.defaults );
  _.assert( arguments.length === 2 );

  record.constructor = null;
  record.file = file;

  if( options.dir )
  pathFile = _.pathJoin( options.dir,record.file );
  else
  pathFile = _.pathJoin( options.relative,record.file );

  pathFile = _.pathNormalize( pathFile );

  record.relative = _.pathRelative( options.relative,pathFile );

  if( record.relative[ 0 ] !== '.' )
  record.relative = './' + record.relative;

  record.absolute = Path.resolve( options.relative,record.relative );
  record.absolute = _.pathNormalize( record.absolute );

  record.ext = _.pathExt( record.absolute );
  record.name = _.pathName( record.absolute );
  record.file = _.pathName( record.absolute,{ withoutExtension : false } );
  record.dir = _.pathDir( record.absolute );

  //

  _.accessorForbid( record,{ path:'path' },'fileRecord:', 'record.path is deprecated' );

  //

  try
  {
    record.stat = File.statSync( pathFile );
  }
  catch( err )
  {
    try
    {
      record.stat = File.lstatSync( pathFile );
    }
    catch( err )
    {
      record.inclusion = false;
      if( File.existsSync( pathFile ) )
      {
        debugger;
        throw _.err( 'cant read :',pathFile );
      }
    }
  }

  if( record.stat )
  record.isDirectory = record.stat.isDirectory(); /* isFile */

  //
/*
  if( record.relative.indexOf( 'common.external/Underscore.js' ) !== -1 )
  {
    console.log( 'record.relative :',record.relative );
    debugger;
  }
*/
  //

  if( record.inclusion === undefined )
  {

    record.inclusion = true;

    _.assert( options.exclude === undefined, 'options.exclude is deprecated, please use mask.excludeAny' );
    _.assert( options.excludeFiles === undefined, 'options.excludeFiles is deprecated, please use mask.maskFiles.excludeAny' );
    _.assert( options.excludeDirs === undefined, 'options.excludeDirs is deprecated, please use mask.maskDirs.excludeAny' );

    var pathFile = record.relative;
    if( record.relative === '.' )
    pathFile = record.file;

    if( record.relative !== '.' || !record.isDirectory )
    if( record.isDirectory )
    {
      if( record.inclusion && options.maskAnyFile ) record.inclusion = _.regexpObjectTest( options.maskAnyFile,pathFile );
      if( record.inclusion && options.maskDir ) record.inclusion = _.regexpObjectTest( options.maskDir,pathFile );
    }
    else
    {
      if( record.inclusion && options.maskAnyFile ) record.inclusion = _.regexpObjectTest( options.maskAnyFile,pathFile );
      if( record.inclusion && options.maskStoreFile ) record.inclusion = _.regexpObjectTest( options.maskStoreFile,pathFile );
    }

  }

  //

  _.assert( record.file.indexOf( '/' ) === -1,'something wrong with filename' );

  if( options.safe || options.safe === undefined )
  if( record.stat && record.inclusion )
  if( !_.pathIsSafe( record.absolute ) )
  {
    debugger;
    throw _.err( 'Unsafe record :',record.absolute );
  }

  if( record.stat && !record.stat.isFile() && !record.stat.isDirectory() && !record.stat.isSymbolicLink() )
  throw _.err( 'Unsafe record ( unknown kind of file ) :',record.absolute );

  //

  if( options.onRecord )
  {
    var onRecord = _.arrayAs( options.onRecord );
    for( var o = 0 ; o < onRecord.length ; o++ )
    onRecord[ o ].call( record );
  }

  return record;
}

_fileRecord.defaults =
{
  dir : null,
  relative : null,
  safe : true,
  maskAnyFile : null,
  maskStoreFile : null,
  maskDir : null,
  onRecord : null,
}

//

var fileRecords = function( records,options )
{

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assert( _.strIs( records ) || _.arrayIs( records ) || _.objectIs( records ) );

  if( !_.arrayIs( records ) )
  records = [ records ];

  for( var r = 0 ; r < records[ r ] ; r++ )
  {

    if( _.strIs( records[ r ] ) )
    records[ r ] = _.fileRecord( records[ r ],options );

  }

  /**/

  records = records.map( function( record )
  {

    if( _.strIs( record ) )
    return _.fileRecord( record,options );
    else if( _.objectIs( record ) )
    return record;
    else throw _.err( 'expects record or path' );

  });

  return records;
}

fileRecords.defaults = _fileRecord.defaults;

//

var fileRecordsFiltered = function( records,options )
{
  _.assert( arguments.length === 1 || arguments.length === 2 );

  var records = fileRecords( records );

  records = records.filter( function( record )
  {

    return record.inclusion && record.stat;

  });

  return records;
}

fileRecordsFiltered.defaults = _fileRecord.defaults;

//

var fileRecordToAbsolute = function( record )
{

  if( _.strIs( record ) )
  return record;

  _.assert( _.objectIs( record ) );

  var result = record.absolute;

  _.assert( _.strIs( result ) );

  return result;
}

//

var fileHash = function( filename,onReady )
{

  var result;
  var crypto = require( 'crypto' );
  var md5sum = crypto.createHash( 'md5' );

  //console.log( 'fileHash:',filename );

  if( onReady )
  {

    var stream = File.ReadStream( filename );

    stream.on( 'data', function( d ) {
      md5sum.update( d );
    });

    stream.on( 'end', function() {
      var hash = md5sum.digest( 'hex' );
      onReady( hash );
    });

    stream.on( 'error', function() {
      onReady( NaN );
    });

  }
  else
  {

    if( !_.fileIs( filename ) ) return;
    try
    {
      var read = File.readFileSync( filename );
      md5sum.update( read );
      result = md5sum.digest( 'hex' );
    }
    catch( err )
    {
      return NaN;
    }

    return result;
  }

}

//

var filesShadow = function( shadows,owners )
{

  for( var s = 0 ; s < shadows.length ; s++ )
  {
    var shadow = shadows[ s ];
    shadow = _.objectIs( shadow ) ? shadow.relative : shadow;

    for( var o = 0 ; o < owners.length ; o++ )
    {

      var owner = owners[ o ];

      owner = _.objectIs( owner ) ? owner.relative : owner;

      if( _.strBegins( shadow,_.pathPrefix( owner ) ) )
      {
        //logger.log( '?',shadow,'shadowed by',owner );
        shadows.splice( s,1 );
        s -= 1;
        break;
      }

    }

  }

}

// --
// find
// --

var _filesOptions = function( pathFile,maskStoreFile,options )
{

  _.assert( arguments.length === 3 );

  if( _.objectIs( pathFile ) )
  {
    options = pathFile;
    pathFile = options.pathFile;
    maskStoreFile = options.maskStoreFile;
  }

  options = options || {};
  options.maskStoreFile = maskStoreFile;
  options.pathFile = pathFile;

  return options;
}

//

var _filesMaskAdjust = function( options )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( options ) );
  /*_.assertMapOnly( _filesMaskAdjust.defaults );*/

  options.maskAnyFile = _.regexpMakeObject( options.maskAnyFile || {},'includeAny' );
  options.maskStoreFile = _.regexpMakeObject( options.maskStoreFile || {},'includeAny' );
  options.maskDir = _.regexpMakeObject( options.maskDir || {},'includeAny' );

/*
  if( options.hasExtension )
  {
    // /(^|\/)\.(?!$|\/)/,
    _.assert( _.strIs( options.hasExtension ) );
    options.hasExtension = new RegExp( '^' + _.regexpEscape( options.hasExtension ) ); xxx
    _.regexpObjectShrink( options.maskStoreFile,{ includeAll : options.hasExtension } );
    delete options.hasExtension;
  }
*/

  if( options.begins )
  {
    _.assert( _.strIs( options.begins ) );
    options.begins = new RegExp( '^' + _.regexpEscape( options.begins ) );
    _.regexpObjectShrink( options.maskStoreFile,{ includeAll : options.begins } );
    delete options.begins;
  }

  if( options.ends )
  {
    _.assert( _.strIs( options.ends ) );
    options.ends = new RegExp( _.regexpEscape( options.ends ) + '$' );
    _.regexpObjectShrink( options.maskStoreFile,{ includeAll : options.ends } );
    delete options.ends;
  }

  if( options.glob )
  {
    _.assert( _.strIs( options.glob ) );
    var globRegexp = _.regexpForGlob( options.glob );
    options.maskStoreFile = _.regexpObjectShrink( options.maskStoreFile,{ includeAll : globRegexp } );
    delete options.glob;
  }

  return options;
}

_filesMaskAdjust.defaults =
{

  maskAnyFile : null,
  maskStoreFile : null,
  maskDir : null,

  begins : null,
  ends : null,
  glob : null,

}

//

var _filesAddResultFor = function( options )
{
  var addResult;

  if( options.outputFormat === 'absolute' )
  addResult = function( record )
  {
    if( record.src )
    options.result.push([ record.src.absolute,record.dst.absolute ]);
    else
    options.result.push( record.absolute );
  }
  else if( options.outputFormat === 'relative' )
  addResult = function( record )
  {
    if( record.src )
    options.result.push([ record.src.relative,record.dst.relative ]);
    else
    options.result.push( record.relative );
  }
  else if( options.outputFormat === 'record' )
  addResult = function( record )
  {
    options.result.push( record );
  }
  else if( options.outputFormat === 'nothing' )
  addResult = function( record )
  {
  }
  else throw _.err( 'unexpected output format :',options.outputFormat );

  return addResult;
}

//

var filesFind = function()
{

  _.assert( arguments.length <= 4 );

  if( arguments[ 3 ] ) return _.timeOut( 0, function()
  {
    arguments[ 3 ]( filesFind( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  });

  var options = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _.assertMapOnly( options,filesFind.defaults );
  _.mapComplement( options,filesFind.defaults );
  _filesMaskAdjust( options );

  if( !options.pathFile )
  throw _.err( 'filesFind :','"pathFile" required' );

  options.pathFile = _.arrayAs( options.pathFile );

  var result = options.result = options.result || [];
  var relative = options.relative;
  /*var orderingExclusion = _.arrayAs( options.orderingExclusion );*/
  var orderingExclusion = _.regexpObjectOrering( options.orderingExclusion || [] );
  var addResult = _filesAddResultFor( options );

  //

  var eachFile = function( pathFile,options )
  {

    options = _.mapExtend( {},options );
    options.pathFile = pathFile;

    var files = _.filesList( pathFile );

    // files

    if( options.includeFiles )
    for( var f = 0 ; f < files.length ; f++ )
    {

      var recordOptions = _._mapScreen
      ({
        screenObjects : _fileRecord.defaults,
        srcObjects : [ options,{ dir : options.pathFile } ],
      });
      var record = _fileRecord( files[ f ],recordOptions );

      if( record.isDirectory ) continue;
      if( !record.inclusion ) continue;

      _.routinesCall( options,options.onUp,[ record ] );
      addResult( record );
      _.routinesCall( options,options.onDown,[ record ] );

    }

    // dirs

    for( var f = 0 ; f < files.length ; f++ )
    {

      var recordOptions = _._mapScreen
      ({
        screenObjects : _fileRecord.defaults,
        srcObjects : [ options,{ dir : options.pathFile } ],
      });
      var record = _fileRecord( files[ f ],recordOptions );

      if( !record.isDirectory ) continue;
      if( !record.inclusion ) continue;

      if( options.includeDirectories )
      {

        _.routinesCall( options,options.onUp,[ record ] );
        addResult( record );

      }

      if( options.recursive )
      eachFile( record.absolute + '/',options );

      if( options.includeDirectories )
      _.routinesCall( options,options.onDown,[ record ] );

    }

  }

  //

  var eachOrder = function( pathes,options )
  {

    if( _.strIs( pathes ) )
    pathes = [ pathes ];

    _.assert( _.arrayIs( pathes ) );

    for( var p = 0 ; p < pathes.length ; p++ )
    {
      var pathFile = pathes[ p ];

      _.assert( _.strIs( pathFile ) );

      if( pathFile[ pathFile.length-1 ] === '/' )
      pathFile = pathFile.substr( 0,pathFile.length-1 );

      options.pathFile = pathFile;

      if( relative === undefined || relative === null )
      options.relative = pathFile;

      if( options.ignoreNonexistent )
      if( !File.existsSync( pathFile ) )
      continue;

      eachFile( pathFile,options );

    }

  }

  //

  if( !orderingExclusion.length )
  {
    eachOrder( options.pathFile,options );
  }
  else
  {
    var maskStoreFile = options.maskStoreFile;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      options.maskStoreFile = _.regexpObjectShrink( {},maskStoreFile,orderingExclusion[ e ] );
      eachOrder( options.pathFile,options );
    }
  }

  //

  if( options.sortWithArray )
  {
    _.assert( _.arrayIs( options.sortWithArray ) );

    if( options.outputFormat === 'record' )
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( options.sortWithArray,a.relative ) - _.regexpArrayIndex( options.sortWithArray,b.relative );
    })
    else
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( options.sortWithArray,a ) - _.regexpArrayIndex( options.sortWithArray,b );
    });

  }

  return result;
}

filesFind.defaults =
{

  pathFile : null,
  relative : null,

  safe : 1,
  recursive : 0,
  ignoreNonexistent : 0,
  includeFiles : 1,
  includeDirectories : 0,
  outputFormat : 'record',

  result : [],
  orderingExclusion : [],
  sortWithArray : null,

  onRecord : [],
  onUp : [],
  onDown : [],

}

filesFind.defaults.__proto__ = _filesMaskAdjust.defaults;

//

var filesFindDifference = function( dst,src,options,onReady )
{

  if( onReady ) return _.timeOut( 0, function()
  {
    onReady( filesFindDifference.call( this,dst,src,options ) );
  });

  // options

  if( _.objectIs( dst ) )
  {
    options = dst;
    dst = options.dst;
    /*delete options.dst;*/
    src = options.src;
    /*delete options.src;*/
  }

  var options = ( options || {} );
  options.dst = dst;
  options.src = src;
  /*options.onFound = _.arrayAs( options.onFound );*/

  _.assertMapOnly( options,filesFindDifference.defaults );
  _.mapComplement( options,filesFindDifference.defaults );
  _filesMaskAdjust( options );
  _.strIs( options.dst );
  _.strIs( options.src );

  var ext = options.ext;
  var result = options.result = options.result || [];
  var addResult = _filesAddResultFor( options );

  if( options.read !== undefined || options.hash !== undefined || options.latters !== undefined )
  throw _.err( 'filesFind:','options are deprecated',_.toStr( options ) );

  // safety

  options.dst = _.pathNormalize( options.dst );
  options.src = _.pathNormalize( options.src );

  if( options.src !== options.dst && _.strBegins( options.src,options.dst ) )
  {
    debugger;
    throw _.err( 'overwrite of itself','\nsrc :',options.src,'\ndst :',options.dst )
  }

  if( options.src !== options.dst && _.strBegins( options.dst,options.src ) )
  {
    var exclude = '^' + options.dst.substr( options.src.length+1 ) + '($|\/)';
    _.regexpObjectShrink( options.maskAnyFile,{ excludeAny : new RegExp( exclude ) } );
  }

  // dst

  var dstOptions = _.mapScreen( _fileRecord.defaults,options );
  dstOptions.dir = dst;
  dstOptions.relative = dst;

  // src

  var srcOptions = _.mapScreen( _fileRecord.defaults,options );
  srcOptions.dir = src;
  srcOptions.relative = src;

  // src file

  var srcFile = function srcFile( dstOptions,srcOptions,file )
  {

    var srcRecord = _._fileRecord( file,_.mapScreen( _fileRecord.defaults,srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = _._fileRecord( file,_.mapScreen( _fileRecord.defaults,dstOptions ) );
    dstRecord.side = 'dst';
    if( _.strIs( ext ) && !dstRecord.isDirectory )
    {
      dstRecord.absolute = _.pathChangeExt( dstRecord.absolute,ext );
      dstRecord.relative = _.pathChangeExt( dstRecord.relative,ext );
    }

    var record =
    {
      relative : srcRecord.relative,
      dst : dstRecord,
      src : srcRecord,
      newer : srcRecord,
      older : null,
    }

    _.assert( srcRecord.stat );

    if( dstRecord.stat )
    {

      if( srcRecord.hash === undefined )
      srcRecord.hash = srcRecord.stat.size < options.maxSize ? _.fileHash( srcRecord.absolute ) : NaN;
      if( dstRecord.hash === undefined )
      dstRecord.hash = dstRecord.stat.size < options.maxSize ? _.fileHash( dstRecord.absolute ) : NaN;

      if( !dstRecord.isDirectory )
      {
        record.same = _.filesSame( dstRecord, srcRecord, options.usingTime );
        record.link = _.filesLinked( dstRecord, srcRecord, record.same );
      }
      else
      {
        record.same = false;
        record.link = false;
      }

      record.newer = _.filesNewer( dstRecord, srcRecord );
      record.older = _.filesOlder( dstRecord, srcRecord );

    }

    _.routinesCall( options,options.onUp,[ record ] );
    addResult( record );
    _.routinesCall( options,options.onDown,[ record ] );

  }

  // src directory

  var srcDir = function srcDir( dstOptions,srcOptions,file,recursive )
  {

    var srcRecord = _._fileRecord( file,srcOptions );
    srcRecord.side = 'src';

    if( !srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = _._fileRecord( file,dstOptions );
    dstRecord.side = 'dst';

    //
/*
    debugger;

    var srcRecord = _._fileRecord( file,srcOptions );
    srcRecord.side = 'src';

    var dstRecord = _._fileRecord( file,dstOptions );
    dstRecord.side = 'dst';
*/
    //

    if( options.includeDirectories )
    {

      var record =
      {
        relative : srcRecord.relative,
        dst : dstRecord,
        src : srcRecord,
        newer : srcRecord,
        older : null,
      }

      if( dstRecord.stat )
      {
        record.newer = _.filesNewer( dstRecord, srcRecord );
        record.older = _.filesOlder( dstRecord, srcRecord );
        if( !dstRecord.isDirectory )
        record.same = false;
      }

      _.routinesCall( options,options.onUp,[ record ] );
      addResult( record );

    }

    if( options.recursive && recursive )
    {
      var dstOptionsSub = _.mapExtend( {},dstOptions );
      dstOptionsSub.dir = dstRecord.absolute;
      var srcOptionsSub = _.mapExtend( {},srcOptions );
      srcOptionsSub.dir = srcRecord.absolute;
      filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
    }

    if( options.includeDirectories )
    _.routinesCall( options,options.onDown,[ record ] );

  }

  // dst file

  var dstFile = function dstFile( dstOptions,srcOptions,file )
  {

    var srcRecord = _._fileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = _._fileRecord( file,dstOptions );
    dstRecord.side = 'dst';
    if( ext !== undefined && ext !== null && !dstRecord.isDirectory )
    {
      dstRecord.absolute = _.pathChangeExt( dstRecord.absolute,ext );
      dstRecord.relative = _.pathChangeExt( dstRecord.relative,ext );
    }

    if( dstRecord.isDirectory )
    return;

    var check = false;
    check = check || !srcRecord.inclusion;
    check = check || !srcRecord.stat;
    /*check = check || ( srcRecord.isDirectory && options.includeDirectories );*/

    if( !check )
    return;

    var record =
    {
      relative : srcRecord.relative,
      dst : dstRecord,
      src : srcRecord,
      del : true,
      newer : dstRecord,
      older : null,
    };

    delete srcRecord.stat;

    _.routinesCall( options,options.onUp,[ record ] );
    addResult( record );
    _.routinesCall( options,options.onDown,[ record ] );

  }

  // dst directory

  var dstDir = function dstDir( dstOptions,srcOptions,file,recursive )
  {

    var srcRecord = _._fileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = _._fileRecord( file,dstOptions );
    dstRecord.side = 'dst';

    if( !dstRecord.isDirectory )
    return;

    var check = false;
    check = check || !srcRecord.inclusion;
    check = check || !srcRecord.stat;
    check = check || !srcRecord.isDirectory;

    if( !check )
    return;

    if( options.includeDirectories && ( !srcRecord.inclusion || !srcRecord.stat ) )
    {

      var record =
      {
        relative : srcRecord.relative,
        dst : dstRecord,
        src : srcRecord,
        del : true,
        newer : dstRecord,
        older : null,
      };

      _.routinesCall( options,options.onUp,[ record ] );
      addResult( record );

    }

    if( options.recursive && recursive )
    {

      var found = _.filesFind
      ({
        includeDirectories: options.includeDirectories,
        includeFiles: options.includeFiles,
        pathFile: dstRecord.absolute,
        outputFormat: options.outputFormat,
        recursive: 1,
        safe : 0,
      })

      srcOptions = _.mapExtend( {},srcOptions );
      delete srcOptions.dir;
      for( var fo = 0 ; fo < found.length ; fo++ )
      {
        var dstRecord = _fileRecord( found[ fo ].absolute,dstOptions );
        dstRecord.side = 'dst';
        var srcRecord = _fileRecord( dstRecord.relative,srcOptions );
        srcRecord.side = 'src';
        var rec =
        {
          relative : srcRecord.relative,
          dst : dstRecord,
          src : srcRecord,
          del : true,
          newer : dstRecord,
          older : null,
        }

        found[ fo ] = rec;
        _.routinesCall( options,options.onUp,[ rec ] );
        addResult( rec );
      }
/*
      if( found.length )
      debugger;
*/
      if( options.onDown.length )
      for( var fo = found.length-1 ; fo >= 0 ; fo-- )
      {
        _.routinesCall( options,options.onDown,[ found[ fo ] ] );
      }

    }

    if( record )
    _.routinesCall( options,options.onDown,[ record ] );

  }

  //

  var filesFindDifferenceAct = function filesFindDifferenceAct( dstOptions,srcOptions )
  {

    // dst

    var dstExists = File.existsSync( dstOptions.dir );
    if( options.investigateDestination )
    if( dstExists && File.statSync( dstOptions.dir ).isDirectory() )
    {

      var files = _.filesList( dstOptions.dir );

      if( options.includeFiles )
      for( var f = 0 ; f < files.length ; f++ )
      dstFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      dstDir( dstOptions,srcOptions,files[ f ],1 );

    }

    // src

    var srcExists = File.existsSync( srcOptions.dir );
    if( srcExists && File.statSync( srcOptions.dir ).isDirectory() )
    {

      var files = _.filesList( srcOptions.dir );

      if( options.includeFiles )
      for( var f = 0 ; f < files.length ; f++ )
      srcFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      srcDir( dstOptions,srcOptions,files[ f ],1 );

    }

  }

  //

  dstFile( dstOptions,srcOptions,'.' );
  dstDir( dstOptions,srcOptions,'.',1 );

  srcFile( dstOptions,srcOptions,'.' );
  srcDir( dstOptions,srcOptions,'.',1 );

  return result;
}

filesFindDifference.defaults =
{
  outputFormat : 'record',
  ext : null,
  investigateDestination : 1,

  maxSize : 1 << 21,
  usingTime : 1,

  recursive : 0,
  includeFiles : 1,
  includeDirectories : 1,

  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

filesFindDifference.defaults.__proto__ = _filesMaskAdjust.defaults

//

var filesFindSame = function()
{

  _.assert( arguments.length <= 4 );

  if( arguments[ 3 ] ) return _.timeOut( 0, function()
  {
    arguments[ 3 ]( filesFindSame( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  });

  var options = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

  _.assertMapOnly( options,filesFindSame.defaults );
  _.mapComplement( options,filesFindSame.defaults );

  // output format

  if( !options.pathFile ) throw _.err( 'filesFindSame:','"pathFile" required' );
  if( options.pathOnly !== undefined ) throw _.err( 'filesFindSame:','"pathOnly" is deprecated, use "outputFormat"' );
  if( options.outputFormat === undefined ) options.outputFormat = 'record';
  if( options.outputFormat !== 'record' ) throw _.err( 'filesFindSame:','outputFormat could be only full' );

  //

  var result = options.result || {};
  if( !result.same ) result.same = [];
  if( !result.sameContent ) result.sameContent = [];
  if( !result.sameName ) result.sameName = [];
  if( !result.similar ) result.similar = [];

  //

  var findOptions = _.mapScreen( filesFind.defaults,options );
  findOptions.result = [];

  //

  var files = _.filesFind( findOptions );

  for( var f1 = 0 ; f1 < files.length ; f1++ )
  {

    var file1 = files[ f1 ];

    if( !file1.stat ) continue;

    if( file1.hash === undefined )
    {
      file1.hash = file1.stat.size <= options.maxSize ? _.fileHash( file1.absolute ) : NaN;
    }

    var sameRecord = [ file1 ];
    var sameNameRecord = [ file1 ];
    var sameContentRecord = [ file1 ];

    for( var f2 = f1 + 1 ; f2 < files.length ; f2++ )
    {

      var file2 = files[ f2 ];

      if( file2.hash === undefined )
      {
        file2.hash = file2.stat.size <= options.maxSize ? _.fileHash( file2.absolute ) : NaN;
      }

      if( !file2.stat ) continue;

      var same = _.filesSame( file1,file2,options.usingTime );
      if( same )
      {

        if( options.useName && file1.file !== file2.file )
        {
          if( !file2._haveSameContent )
          {
            file2._haveSameContent = 1;
            sameContentRecord.push( file2 );
          }
          continue;
        }
        sameRecord.push( file2 );
        files.splice( f2,1 );
        f2 -= 1;
      }
      else
      {

        if( options.similarity )
        if( file1.stat.size <= options.lattersFileSizeLimit && file1.stat.size <= options.lattersFileSizeLimit )
        if( Math.min( file1.stat.size,file2.stat.size ) / Math.max( file1.stat.size,file2.stat.size ) >= options.similarity )
        {
          var similarity = _.filesSimilarity( file1,file2 );
          if( similarity >= options.similarity )
          {
            var similarity = _.filesSimilarity( file1,file2 );
            result.similar.push({ files:[ file1,file2 ],similarity:similarity });

            //logger.logUp( 'Similar content( ',similarity*100,'% )' );
            //logger.log( file1.absolute );
            //logger.log( file2.absolute );
            //logger.logDown();

          }
        }
        if( file1.file === file2.file && !file2._haveSameName )
        {
          file2._haveSameName = 1;
          sameNameRecord.push( file2 );
          continue;
        }
      }

    }

    if( sameRecord.length > 1 )
    result.same.push( sameRecord );

    if( sameContentRecord.length > 1  )
    result.sameContent.push( sameContentRecord );

    if( sameNameRecord.length > 1 )
    result.sameName.push( sameNameRecord );

  }

  return result;
}

filesFindSame.defaults =
{
  maxSize : 1 << 22,
  lattersFileSizeLimit : 1048576,
  useName : 1,
  usingTime : 0,
  similarity : 0,
}

filesFindSame.defaults.__proto__ = filesFind.defaults;

// --
// action
// --

var filesGlob = function( options )
{

  if( options.glob === undefined )
  options.glob = '*';

  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.glob ) );

  if( options.pathFile === undefined )
  {
    var i = options.glob.search( /[^\\\/]*?(\*\*|\?|\*)[^\\\/]*/ );
    if( i === -1 )
    options.pathFile = options.glob;
    else options.pathFile = options.glob.substr( 0,i );
    if( !options.pathFile )
    options.pathFile = _.pathMainDir();
  }

  if( options.relative === undefined )
  options.relative = options.pathFile;

  var relative = _.strAppendOnce( options.relative,'/' );
  if( _.strBegins( options.glob,relative ) )
  options.glob = options.glob.substr( relative.length,options.glob.length );
  else
  {
    debugger;
    console.log( 'strBegins :', _.strBegins( options.glob,relative ) );
    throw _.err( 'not tested' );
  }

  if( options.outputFormat === undefined )
  options.outputFormat = 'absolute';

  if( options.recursive === undefined )
  options.recursive = 1;

  var result = filesFind( options );

/*
  if( !Glob )
  Glob = require( 'glob' );

  if( options.pattern === undefined )
  options.pattern = '*';

  var globOptions =
  {
    cwd : options.pathFile,
    nosort : false,
  }

  var result = Glob.sync( options.pattern,globOptions );
*/

  return result;
}

filesGlob.defaults = {};
filesGlob.defaults.__proto__ = filesFind.defaults;

//

var filesCopy = function( options,onReady )
{

  _.assert( arguments.length <= 2 );

  if( onReady ) return _.timeOut( 0, function()
  {
    onReady( filesCopy.call( this,options ) );
  });

  var options = options || {};

  if( !options.allowDelete && options.investigateDestination === undefined )
  options.investigateDestination = 0;

  if( options.allowRewrite && options.allowWrite === undefined )
  options.allowWrite = 1;

  if( options.allowRewrite && options.allowRewriteFileByDir === undefined  )
  options.allowRewriteFileByDir = true;

  //if( options.allowRewrite )
  //_.assert( options.allowWrite,'allowRewrite without allowWrite is useless' );

  _.assertMapOnly( options,filesCopy.defaults );
  _.mapComplement( options,filesCopy.defaults );

  var includeDirectories = options.includeDirectories !== undefined ? options.includeDirectories : 1;
  var onUp = _.arrayAs( options.onUp );
  var onDown = _.arrayAs( options.onDown );
  var deirectories = {};

  // safe

  if( options.safe )
  if( options.removeSource && ( !options.allowWrite || !options.allowRewrite ) )
  throw _.err( 'not safe removeSource:1 with allowWrite:0 or allowRewrite:0' );

  // make dir

  var dirname = Path.dirname( options.dst );

  if( options.safe )
  if( !_.pathIsSafe( dirname ) )
  throw _.err( dirname,'Unsafe to use :',dirname );

  var rewriteDir = !_.directoryIs( dirname ) && File.existsSync( dirname );
  if( rewriteDir )
  if( options.allowRewrite )
  {

    debugger;
    throw _.err( 'not tested' );
    if( options.usingLogging )
    logger.log( '- rewritten file by directory :',dirname );
    File.unlinkSync( dirname );
    File.mkdirsSync( dirname );

  }
  else
  {
    throw _.err( 'cant rewrite',dirname );
  }

  // on up

  var handleUp = function( record )
  {
/*
    if( record.relative.indexOf( 'dist-resource' ) !== -1 )
    debugger;
*/
    // same

    if( options.tryingPreserve )
    if( record.same && record.link == options.usingLinking )
    {
      record.action = 'same';
      record.allowed = true;
    }

    // delete redundant

    /*if( !record.src || !record.src.stat || !record.src.inclusion )*/
    if( record.del )
    {
/*
      if( !record.del )
      throw _.err( 'unexpected' );
*/
      if( record.dst && record.dst.stat )
      {
        if( options.allowDelete )
        {
          record.action = 'deleted';
          record.allowed = true;
/*
          if( options.usingLogging )
          logger.log( '- deleted :',record.dst.absolute ); debugger;
          _.fileDelete( record.dst.absolute );
*/
        }
        else
        {
          record.action = 'deleted';
          record.allowed = false;
/*
          if( options.usingLogging && !options.silentPreserve )
          logger.log( '? not deleted :',record.dst.absolute );
*/
        }
      }
      else
      {
        debugger;
        record.action = 'ignored';
        record.allowed = false;
      }
      return;
    }

    // preserve directory

    if( !record.action )
    {

      /*if( options.tryingPreserve )*/
      if( record.src.stat && record.dst.stat )
      if( record.src.stat.isDirectory() && record.dst.stat.isDirectory() )
      {
        deirectories[ record.dst.absolute ] = true;
        record.action = 'directory preserved';
        record.allowed = true;
        if( record.preserveTime )
        File.utimesSync( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
      }

    }

    // rewrite

    if( !record.action )
    {

      var rewriteFile = File.existsSync( record.dst.absolute );

      if( rewriteFile )
      {

        if( !options.allowRewriteFileByDir && record.src.stat && record.src.stat.isDirectory() )
        rewriteFile = false;

        if( rewriteFile && options.allowRewrite && options.allowWrite )
        {
          rewriteFile = record.dst.absolute + '.' + _.idGenerateDate() + '.back' ;
          File.renameSync( record.dst.absolute,rewriteFile );
          /*File.unlinkSync( record.dst.absolute );*/
        }
        else
        {
          rewriteFile = false;
          record.action = 'cant rewrite';
          record.allowed = false;
          if( options.usingLogging )
          logger.log( '? cant rewrite :',record.dst.absolute );
        }

      }

    }

    // new directory

    if( !record.action && record.src.stat && record.src.stat.isDirectory() )
    {

      deirectories[ record.dst.absolute ] = true;
      record.action = 'directory new';
      record.allowed = false;
      if( options.allowWrite )
      {
        File.mkdirsSync( record.dst.absolute );
        if( record.preserveTime )
        File.utimesSync( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        record.allowed = true;
      }

    }

    // unknown

    if( !record.action && record.src.stat && !record.src.stat.isFile() )
    {
      throw _.err( 'unknown kind of source : unsafe' );
    }

    // is write possible

    if( !record.action )
    {

      /*if( !_.directoryIs( record.dst.dir ) )*/
      if( !deirectories[ record.dst.dir ] )
      {
        record.action = 'cant rewrite';
        record.allowed = false;
        return;
      }

    }

    // write

    if( !record.action )
    {

      /* write */

      if( !record.action )
      if( options.usingLinking )
      {

        record.action = 'linked';
        record.allowed = false;

        if( options.allowWrite )
        {
          record.allowed = true;
          if( options.usingLogging )
          logger.log( '+ ' + record.action + ' :',record.dst.absolute );
          _.fileHardlink( record.dst.absolute,record.src.absolute )
          /*File.linkSync( record.src.absolute,record.dst.absolute ); xxx*/
        }

      }
      else
      {

        record.action = 'copied';
        record.allowed = false;

        if( options.allowWrite )
        {
          record.allowed = true;
          if( options.usingLogging )
          logger.log( '+ ' + record.action + ' :',record.dst.absolute );
          File.copySync( record.src.absolute,record.dst.absolute );
          if( record.preserveTime )
          File.utimesSync( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        }

      }

    }

    // rewrite

    if( rewriteFile && options.allowRewrite )
    {
      _.fileDelete
      ({
        pathFile : rewriteFile,
        force : 1,
      });
      /*File.removeSync( rewriteFile );*/
      /*File.unlinkSync( rewriteFile );*/
    }

    // callback

    if( !includeDirectories &&  record.src.stat && record.src.stat.isDirectory() )
    return false;

    _.routinesCall( options,onUp,[ record ] );

  }

  // on down

  var handleDown = function( record )
  {
/*
    if( record.relative.indexOf( 'dist-resource' ) !== -1 )
    debugger;
*/
    if( record.action === 'linked' && record.del )
    throw _.err( 'unexpected' );

    // delete redundant

    if( record.action === 'deleted' )
    {
      if( record.allowed )
      {
        if( options.usingLogging )
        logger.log( '- deleted :',record.dst.absolute );
        _.fileDelete( record.dst.absolute );
      }
      else
      {
        if( options.usingLogging && !options.silentPreserve )
        logger.log( '? not deleted :',record.dst.absolute );
      }
    }

    // remove source

    var removeSource = false;
    removeSource = removeSource || options.removeSource;
    removeSource = removeSource || ( options.removeSourceFiles && !record.src.isDirectory );

    if( removeSource && record.src.stat && record.src.inclusion )
    {
      if( options.usingLogging )
      logger.log( '- removed-source :',record.src.absolute );
      _.fileDelete( record.src.absolute );
    }

    // callback

    if( !includeDirectories && record.src.isDirectory )
    return;

    _.routinesCall( options,onDown,[ record ] );

  }

  // launch

  try
  {

    var findOptions = _.mapScreen( filesFindDifference.defaults,options );
    findOptions.onUp = handleUp;
    findOptions.onDown = handleDown;
    findOptions.includeDirectories = true;
    var records = _.filesFindDifference( options.dst,options.src,findOptions );

    if( options.usingLogging )
    if( !records.length && options.outputFormat !== 'nothing' )
    logger.log( '? copy:', 'nothing was copied:',options.dst,'<-',options.src );

    if( !includeDirectories )
    {
      records = records.filter( function( e )
      {
        if( e.src.stat && e.src.isDirectory )
        return false;

        if( e.src.stat && !e.src.isDirectory )
        return true;

        if( e.dst.stat && e.dst.isDirectory )
        return false;

        return true;
      });
    }

  }
  catch( err )
  {
    throw _.err( 'filesCopy( ',_.toStr( options ),' )','\n',err );
  }

  return records;
}

filesCopy.defaults =
{

  usingLogging : 1,
  usingLinking : 0,
  removeSource : 0,
  removeSourceFiles : 0,

  /*usingDelete : 0,*/
  allowDelete : 0,
  allowWrite : 0,
  allowRewrite : 0,
  allowRewriteFileByDir : 0,

  tryingPreserve : 1,
  silentPreserve : 1,
  preserveTime : 1,

  safe : 1,

  /*onCopy : null,*/

}

filesCopy.defaults.__proto__ = filesFindDifference.defaults;

//

var filesDelete = function()
{

  _.assert( arguments.length <= 4 );

  if( arguments[ 3 ] ) return _.timeOut( 0, function()
  {
    arguments[ 3 ]( filesFindSame( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  });

  var options = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

  //

  options.outputFormat = 'absolute';

  _.mapComplement( options,filesDelete.defaults );

  //

  var o = _.mapBut( options,filesDelete.defaults );
  var files = _.filesFind( o );

  for( var f = 0 ; f < files.length ; f++ ) try
  {
    if( options.usingLogging )
    logger.log( '- deleted:',files[ f ] )
    File.removeSync( files[ f ] );
  }
  catch( err )
  {
    if( !options.silent )
    throw _.err( err );
  }

  return new wConsequence().give();
}

filesDelete.defaults =
{
  silent : false,
  usingLogging : false,
}

//

var filesDeleteEmptyDirs = function()
{

  var options = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

  //

  options.outputFormat = 'absolute';
  options.includeFiles = 0;
  options.includeDirectories = 1;
  if( options.recursive === undefined )
  options.recursive = 1;

  _.mapComplement( options,filesDeleteEmptyDirs.defaults );

  //

  var o = _.mapBut( options,filesDeleteEmptyDirs.defaults );
  o.onDown = _.arrayAppendMerging( _.arrayAs( options.onDown ), function( record )
  {

    try
    {
      var sub = File.readdirSync( record.absolute );
      if( !sub.length )
      {
        /* throw _.err( 'not tested' ); */
        logger.log( '- deleted:',record.absolute )
        File.removeSync( record.absolute );
      }
    }
    catch( err )
    {
      if( !options.silent )
      throw _.err( err );
    }

  });

  var files = _.filesFind( o );

/*
  for( var f = 0 ; f < files.length ; f++ ) try
  {
    var sub = File.readdirSync( files[ f ] );
    if( !sub.length )
    {
      throw _.err( 'not tested' );
      logger.log( '- deleted:',files[ f ] )
      File.removeSync( files[ f ] );
    }
  }
  catch( err )
  {
    if( !options.silent )
    throw _.err( err );
  }
*/

  return new wConsequence().give();
}

filesDeleteEmptyDirs.defaults =
{
  silent : false,
  usingLogging : false,
}

// --
// tree
// --

var filesTreeWrite = function( options )
{

  _.assert( arguments.length === 1 );
  _.assertMapOnly( options,filesTreeWrite.defaults );
  _.mapComplement( options,filesTreeWrite.defaults );
  _.assert( _.strIs( options.pathFile ) );

  //

  var stat = null;
  var handleWritten = function( pathFile )
  {
    if( !options.allowWrite )
    return;
    if( !options.sameTime )
    return;
    if( !stat )
    stat = File.statSync( pathFile );
    else
    File.utimesSync( pathFile, stat.atime, stat.mtime );
  }

  //

  var write = function( pathFile,tree )
  {

    _.assert( _.strIs( pathFile ) );
    _.assert( _.strIs( tree ) || _.objectIs( tree ) || _.arrayIs( tree ) );

    var exists = File.existsSync( pathFile );
    if( options.allowDelete && exists )
    {
      File.removeSync( pathFile );
      exists = false;
    }

    if( _.strIs( tree ) )
    {
      if( options.allowWrite && !exists )
      _.fileWrite( pathFile,tree );
      handleWritten( pathFile );
    }
    else if( _.objectIs( tree ) )
    {
      if( options.allowWrite && !exists )
      File.ensureDirSync( pathFile );
      handleWritten( pathFile );
      for( var t in tree )
      {
        write( _.pathJoin( pathFile,t ),tree[ t ] );
      }
    }
    else if( _.arrayIs( tree ) )
    {
      _.assert( tree.length === 1 );
      tree = tree[ 0 ];

      _.assert( _.strIs( tree.softlink ) );
      if( options.allowWrite && !exists )
      {
        var pathTarget = tree.softlink;
        if( options.absolutePathForLink )
        pathTarget = _.pathResolve( _.pathJoin( pathFile,'..',tree.softlink ) );
        File.symlinkSync( pathTarget,pathFile );
      }
      handleWritten( pathFile );
    }

  }

  write( options.pathFile,options.tree );

}

filesTreeWrite.defaults =
{
  tree : null,
  pathFile : null,
  sameTime : 1,
  absolutePathForLink : 0,
  allowWrite : 1,
  allowDelete : 0,
}

//

/** usage

    var treeWriten = _.filesTreeRead
    ({
      pathFile : dir,
      read : 0,
    });

    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );

*/

var filesTreeRead = function( options )
{
  var result = {};

  if( _.strIs( options ) )
  options = { pathFile : options };

  _.assert( arguments.length === 1 );
  _.assertMapOnly( options,filesTreeRead.defaults );
  _.mapComplement( options,filesTreeRead.defaults );
  _.assert( _.strIs( options.pathFile ) );

  options.outputFormat = 'record';

  //

  options.onUp = _.arrayPrependMerging( _.arrayAs( options.onUp ), function( record )
  {
    var data = {};

    if( !record.stat.isDirectory() )
    if( options.read )
    data = _.fileRead( record.absolute );
    else
    data = '';

    var r = record.relative;
    if( r.length > 2 )
    r = r.substr( 2 );

    _.entitySelectSet
    ({
      container : result,
      query : r,
      delimeter : '/',
      set : data,
    });

  });

  var found = _.filesFind( _.mapScreen( _.filesFind.defaults,options ) );

  return result;
}

filesTreeRead.defaults =
{
  read : 1,
  recursive : 1,
  includeFiles : 1,
  includeDirectories : 1,
  safe : 0,
  outputFormat : 'nothing',
}

filesTreeRead.defaults.__proto__ = filesFind.defaults;

// --
// resolve
// --

var filesResolve = function( options )
{
  var result = [];

  _.assertMapOnly( options,filesResolve.defaults );
  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.pathLookRoot ) );

  options.pathLookRoot = _.pathNormalize( options.pathLookRoot );

  if( !options.pathOutputRoot )
  options.pathOutputRoot = options.pathLookRoot;
  else
  options.pathOutputRoot = _.pathNormalize( options.pathOutputRoot );

  if( options.usingRecord === undefined )
  options.usingRecord = true;

  var glob = _filesResolveMakeGlob( options );

  var globOptions = _.mapScreen( filesGlob.defaults,options );
  globOptions.glob = glob;
  globOptions.relative = options.pathOutputRoot;
  globOptions.outputFormat = options.outputFormat;

  var result = _.filesGlob( globOptions );

  return result;
}

filesResolve.defaults =
{
  pathGlob : null,
  pathVirtualRoot : null,
  pathVirtualDir : null,
  pathLookRoot : null,
  pathOutputRoot : null,
  outputFormat : 'record',
}

filesResolve.defaults.__proto__ = filesGlob.defaults;
/*filesResolve.defaults.__proto__ = _filesMaskAdjust.defaults;*/

//

var _filesResolveMakeGlob = function( options )
{
  var pathGlob = options.pathGlob;

  _.assert( options.pathVirtualRoot === options.pathLookRoot,'not tested' );

/*
  if( options.pathVirtualRoot !== options.pathVirtualDir )
  debugger;
*/

  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.pathGlob ) );
  _.assert( _.strIs( options.pathVirtualDir ) );
  _.assert( _.strIs( options.pathLookRoot ) );

  if( options.pathVirtualRoot === undefined )
  options.pathVirtualRoot = options.pathLookRoot;

  if( pathGlob[ 0 ] !== '/' )
  {
    pathGlob = _.pathReroot( options.pathVirtualDir,pathGlob );
    pathGlob = _.pathRelative( options.pathVirtualRoot,pathGlob );
  }

  if( _.strBegins( pathGlob,options.pathLookRoot ) )
  {
    debugger;
    _.errLog( 'probably something wrong with pathGlob :',pathGlob );
    throw _.err( 'probably something wrong with pathGlob :',pathGlob );
  }

  var result = pathGlob;
  result = _.pathReroot( options.pathLookRoot,pathGlob );

  return result;
}

// --
// individual
// --

var directoryIs = function( filename )
{

  if( fileSymbolicLinkIs( filename ) )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  try
  {

    var stat = File.statSync( filename );
    return stat.isDirectory();

  } catch( err ){ return };

}

//

var fileIs = function( filename )
{

  if( fileSymbolicLinkIs( filename ) )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  try
  {

    var stat = File.statSync( filename );
    return stat.isFile();

  } catch( err ){ return };

}

//

var fileSymbolicLinkIs = function( filename )
{

  if( !File.existsSync( filename ) )
  return false;

  var stat = File.statSync( filename );

  if( !stat )
  return false;

  return stat.isSymbolicLink();
}


//

var _fileOptionsGet = function( pathFile,o )
{
  var o = o || {};

  if( _.objectIs( pathFile ) )
  {
    o = pathFile;
  }
  else
  {
    o.pathFile = pathFile;
  }

  if( !o.pathFile )
  throw _.err( 'Files.fileWrite:','"o.pathFile" is required' );

  _.assertMapOnly( o,this.defaults );
  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( o.sync === undefined )
  o.sync = 1;

  return o;
}

//

/*
  _.fileWrite
  ({
    pathFile: fileName,
    data: _.toStr( args,strOptions ) + '\n',
    append: true,
  });
*/

var fileWrite = function( pathFile,data )
{
  var con = wConsequence();
  var options;

  if( _.strIs( pathFile ) )
  {
    options = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    options = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  if( options.data === undefined )
  options.data = data;

  if( _.bufferIs( options.data ) )
  {
    if( !toBuffer )
    toBuffer = require( 'typedarray-to-buffer' );
    options.data = toBuffer( options.data );
  }

  _.mapComplement( options,fileWrite.defaults );
  _.assertMapOnly( options,fileWrite.defaults );
  _.assert( _.strIs( options.pathFile ) );
  _.assert( _.strIs( options.data ) || _.bufferNodeIs( options.data ),'expects string or node buffer, but got',_.strTypeOf( options.data ) );

  // log

  if( options.usingLogging )
  logger.log( '+ writing',_.toStr( options.data,{ levels : 0 } ),'to',options.pathFile );

  // force

  if( options.force )
  {

    var pathFile = Path.dirname( options.pathFile );
    if( !File.existsSync( pathFile ) )
    File.mkdirsSync( pathFile );

  }

  // clean

  if( options.clean )
  {
    try
    {
      File.unlinkSync( options.pathFile );
    }
    catch( err )
    {
    }
  }

  // write

  if( options.sync )
  {

    if( options.silentError ) try
    {
      if( options.append ) File.appendFileSync( options.pathFile, options.data );
      else File.writeFileSync( options.pathFile, options.data );
    }
    catch( err ){}
    else
    {
      if( options.append ) File.appendFileSync( options.pathFile, options.data );
      else File.writeFileSync( options.pathFile, options.data );
    }
    con.give();

  }
  else
  {

    var handleEnd = function( err )
    {
      if( err && !options.silentError )
      logger.error( err );
      con.giveWithError( err,null );
    }
    if( options.append ) File.appendFile( options.pathFile, options.data, handleEnd );
    else File.writeFile( options.pathFile, options.data, handleEnd );

  }

  return con;
}

fileWrite.defaults =
{
  pathFile : null,
  data : '',
  append : false,
  sync : true,
  force : true,
  silentError : false,
  usingLogging : false,
  clean : false,
}

fileWrite.isWriter = 1;

//

var fileWriteJson = function( pathFile,data )
{
  var options;

  if( _.strIs( pathFile ) )
  {
    options = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    options = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  _.mapComplement( options,fileWriteJson.defaults );
  _.assertMapOnly( options,fileWriteJson.defaults );

  /**/

  if( _.stringify && options.pretty )
  options.data = JSON.stringify( options.data );
  else
  options.data = _.stringify( options.data );

  /**/

  delete options.pretty;
  return fileWrite( options );
}

fileWriteJson.defaults =
{
  pretty : '',
}

fileWriteJson.defaults.__proto__ = fileWrite.defaults;

fileWriteJson.isWriter = 1;

//

/*
fileRead({ pathFile : file.absolute, encoding : 'buffer' })
*/

var fileRead = function( o )
{
  var con = new wConsequence();
  var result = null;
  var o = _fileOptionsGet.apply( fileRead,arguments );

  _.mapSupplement( o,fileRead.defaults );
  /* _.assert( o.sync,'not implemented' ); */

  var encodingProcessor = fileRead.encodings[ o.encoding ];

  //

  var handleBegin = function()
  {

    if( encodingProcessor && encodingProcessor.onBegin )
    encodingProcessor.onBegin( o );

    if( !o.onBegin )
    return;

    var r = null;
    if( o.wrap )
    r = { options : o };
    else
    r = data;

    wConsequence.give( o.onBegin,r );
  }

  var handleEnd = function( data )
  {

    if( encodingProcessor && encodingProcessor.onEnd )
    data = encodingProcessor.onEnd({ data : data, options : o });

    var r = null;
    if( o.wrap )
    r = { data : data, options : o };
    else
    r = data;

    if( o.onEnd )
    wConsequence.give( o.onEnd,r );
    wConsequence.give( con,r );
    if( o.returnRead )
    return r;
    else
    return con;
  }

  var handleError = function( err )
  {
    var r = null;
    r = err;

    if( o.onEnd )
    wConsequence.error( o.onEnd,r );
    wConsequence.error( con,r );
    return con;
  }

  // exec

  handleBegin();

  if( o.sync )
  {

    if( o.silent )
    {

      try
      {
        result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );
      }
      catch( err )
      {
        return handleError( err );
      }

    }
    else
    {
      result = File.readFileSync( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding );
    }

    return handleEnd( result );

  }
  else
  {

    File.readFile( o.pathFile,o.encoding === 'buffer' ? undefined : o.encoding,function( err,data )
    {

      if( err )
      return handleError( err );
      else
      return handleEnd( data );

    });

  }

  //

/*
  if( o.onEnd ) return _.timeOut( 0, function()
  {
    debugger;
    o.onEnd.call( o,null,result );
  });
*/

  return con;
}

fileRead.defaults =
{

  sync : 1,
  wrap : 0,
  returnRead : 0,
  silent : 0,

  pathFile : null,
  name : null,
  encoding : 'utf8',

  onBegin : null,
  onEnd : null,
  onError : null,

  advanced : null,

}

fileRead.isOriginalReader = 1;

//

var fileReadSync = function()
{
  var o = _fileOptionsGet.apply( fileRead,arguments );
  o.returnRead = 1;
  o.sync = 1;

  return _.fileRead( o );
}

fileReadSync.defaults =
{
}

fileReadSync.defaults.__proto__ = fileRead.defaults;
fileReadSync.isOriginalReader = 1;

//
/*
var filesRead = function( paths,o )
{

  throw _.err( 'not tested' );

  // options

  if( _.objectIs( paths ) )
  {
    o = paths;
    paths = o.paths;
    _.assert( arguments.length === 1 );
  }
  else
  {
    _.assert( arguments.length === 1 || arguments.length === 2 );
  }

  var o = o || {};
  paths = o.paths = paths || o.paths;
  paths = _.arrayAs( paths );

  var result = o.concat ? '' : [];

  if( !o.sync )
  throw _.err( 'not implemented' );

  // exec

  for( var p = 0 ; p < paths.length ; p++ )
  {

    var pathFile = paths[ p ];
    var readOptions = _.mapScreen( _.fileRead.defaults,o );

    readOptions.pathFile = pathFile;

    if( o.concat )
    {
      result += _.fileRead( pathFile,o );
      if( p < pathFile.length - 1 )
      result += o.delimeter;
    }
    else
    {
      result[ p ] = fileRead( pathFile,o );
    }

  }

  //

  return result;
}

filesRead.defaults =
{

  delimeter : '',
  concat : 0,

}

filesRead.defaults.__proto__ = fileRead.default;
*/

//

var fileReadJson = function( pathFile )
{
  var result = null;

  _.assert( arguments.length === 1 );

  if( File.existsSync( pathFile ) )
  {

    try
    {
      var str = File.readFileSync( pathFile,'utf8' );
      result = JSON.parse( str );
    }
    catch( err )
    {
      throw _.err( 'cant read json from',pathFile,'\n',err );
    }

  }

  return result;
}

// --
//
// --

var filesSame = function( ins1,ins2,usingTime )
{
  var usingTime = usingTime === undefined ? 0 : usingTime;

  if( _.strIs( ins1 ) ) ins1 = _.fileRecord( ins1 );
  if( _.strIs( ins2 ) ) ins2 = _.fileRecord( ins2 );

  if( !ins1.stat || !ins2.stat ) return;
  if( ins1.stat.size !== ins2.stat.size ) return false;
  if( !ins1.stat.size || !ins2.stat.size ) return;

  if( usingTime )
  if( ins1.stat.mtime.getTime() !== ins2.stat.mtime.getTime() )
  return false;

  if( ins1.hash === undefined ) ins1.hash = _.fileHash( ins1.absolute );
  if( ins2.hash === undefined ) ins2.hash = _.fileHash( ins2.absolute );

  //if( !strict && isNaN( ins1.hash ) && isNaN( ins2.hash ) )
  //return false;

  if( ( _.numberIs( ins1.hash ) && isNaN( ins1.hash ) ) || ( _.numberIs( ins2.hash ) && isNaN( ins2.hash ) ) )
  return;

  return ins1.hash === ins2.hash;
}

//

var filesLinked = function( ins1,ins2,isSame )
{

  if( _.strIs( ins1 ) )
  ins1 = { absolute : ins1, stat : File.lstatSync( ins1 ) };

  if( _.strIs( ins2 ) )
  ins2 = { absolute : ins2, stat : File.lstatSync( ins2 ) };

  if( ins1.stat.isSymbolicLink() || ins2.stat.isSymbolicLink() )
  {
    throw _.err( 'Not tested' );
    return true;
  }

  /* ino comparison reliable test if ino present */
  if( ins1.stat.ino !== ins2.stat.ino ) return false;
  if( ins1.stat.ino !== -1 && ins1.stat.ino !== 0 ) return true;

  /* try to guess otherwise */
  if( ins1.stat.nlink !== ins2.stat.nlink ) return false;
  if( ins1.stat.mode !== ins2.stat.mode ) return false;
  if( ins1.stat.mtime.getTime() !== ins2.stat.mtime.getTime() ) return false;
  if( ins1.stat.ctime.getTime() !== ins2.stat.ctime.getTime() ) return false;

  /* gives false negative if folder hardlinked */
  /*if( ins1.stat.nlink === 1 ) return false;*/

  if( isSame === undefined )
  isSame = _.filesSame( ins1,ins2 );

  if( !isSame )
  return false;

  return true;
}

//

var filesLink = function( dst,src )
{

  _.assert( arguments.length === 2 );
  _.assert( _.strIs( dst ) );
  _.assert( _.strIs( src ) );

  var temp = dst + _.idGenerateGuid();

  if( !File.existsSync( src ) )
  return false;

  try
  {
    File.renameSync( dst,temp );
    File.linkSync( src,dst );
    File.unlinkSync( temp );
    return true;
  }
  catch( err )
  {
    File.renameSync( temp,dst );
    return false;
  }

}

//

var filesNewer = function( dst,src )
{
  var odst = dst;
  var osrc = src;

  if( src instanceof File.Stats )
  src = { stat : src };
  else if( _.strIs( src ) )
  src = { stat : File.statSync( src ) };
  else if( !_.objectIs( src ) )
  throw _.err( 'unknown src type' );

  if( dst instanceof File.Stats )
  dst = { stat : dst };
  else if( _.strIs( dst ) )
  dst = { stat : File.statSync( dst ) };
  else if( !_.objectIs( dst ) )
  throw _.err( 'unknown dst type' );

  if( src.stat.mtime > dst.stat.mtime )
  return osrc;
  else if( src.stat.mtime < dst.stat.mtime )
  return odst;
  else
  return null;

}

  //

var filesOlder = function( dst,src )
{
  var result = filesNewer( dst,src );

  if( result === dst )
  return dst;
  else if( result === src )
  return src;
  else
  return null;

}

//

var filesSpectre = function( src )
{

  _.assert( arguments.length === 1, 'filesSpectre:','expect single argument' );

  if( _.strIs( src ) ) src = _.fileRecord( src );
  var read = src.read;

  if( !read )
  read = _.fileRead
  ({
    pathFile: src.absolute,
    silent: 1,
  });

  return _.strLattersSpectre( read );
}

//

var filesSimilarity = function( src1,src2,options,onReady )
{

  if( onReady ) return _.timeOut( 0, function()
  {
    onReady( filesSimilarity.call( this,options ) );
  });

  var options = options || { latters : 1 };

  //if( _.strIs( src1 ) || _.strIs( src2 ) ) throw _.err( 'filesSimilarity:','require file records' );

  if( _.strIs( src1 ) ) src1 = _.fileRecord( src1 );
  if( _.strIs( src2 ) ) src2 = _.fileRecord( src2 );

  if( !src1.latters ) src1.latters = _.filesSpectre( src1 );
  if( !src2.latters ) src2.latters = _.filesSpectre( src2 );

  var result = _.lattersSpectreComparison( src1.latters,src2.latters );

  return result;
}

//

var filesSize = function( paths,options )
{
  var result = 0;
  var options = options || {};
  var paths = _.arrayAs( paths );

  if( options.onBegin ) options.onBegin.call( this,null );

  if( options.onEnd ) throw 'Not implemented';

  for( var p = 0 ; p < paths.length ; p++ )
  {
    result += fileSize( paths[ p ] );
  }

  return result;
}

//

var fileSize = function( options )
{
  var result = 0;
  var options = options || {};

  if( _.strIs( options ) )
  options = { pathFile : options };

  _.assert( arguments.length === 1 );
  _.assertMapOnly( options,fileSize.defaults );
  _.mapComplement( options,fileSize.defaults );
  _.assert( _.strIs( options.pathFile ) );

  if( fileSymbolicLinkIs( options.pathFile ) )
  {
    throw _.err( 'Not tested' );
    return false;
  }

  // synchronization

  if( options.onEnd ) return _.timeOut( 0, function()
  {
    var onEnd = options.onEnd;
    delete options.onEnd;
    onEnd.call( this,fileSize.call( this,options ) );
  });

  if( options.onBegin ) options.onBegin.call( this,null );

  var stat = File.statSync( options.pathFile );

  return stat.size;
}

fileSize.defaults =
{
  pathFile : null,
  onBegin : null,
  onEnd : null,
}

//

var fileDelete = function( options )
{
  var con = new wConsequence();

  if( _.strIs( options ) )
  options = { pathFile : options };

  _.assert( arguments.length === 1 );
  _.assertMapOnly( options,fileDelete.defaults );
  _.mapComplement( options,fileDelete.defaults );
  _.assert( _.strIs( options.pathFile ) );

  var stat;
  if( options.sync )
  {

    if( !options.force )
    {
      try
      {
        stat = File.lstatSync( options.pathFile );
      }
      catch( err ){};
      if( !stat )
      return con.error();
      if( stat.isSymbolicLink() )
      {
        debugger;
        //throw _.err( 'not tested' );
      }
      if( stat.isDirectory() )
      File.rmdirSync( options.pathFile );
      else
      File.unlinkSync( options.pathFile );
    }
    else
    {
      File.removeSync( options.pathFile );
    }

    con.give();

  }
  else
  {

    if( !options.force )
    {
      try
      {
        stat = File.lstatSync( options.pathFile );
      }
      catch( err ){};
      if( !stat )
      return con.error();
      if( stat.isSymbolicLink() )
      throw _.err( 'not tested' );
      if( stat.isDirectory() )
      File.rmdir( options.pathFile,function( err,data ){ con.giveWithError( err,data ) } );
      else
      File.unlink( options.pathFile,function( err,data ){ con.giveWithError( err,data ) } );
    }
    else
    {
      File.remove( options.pathFile,function( err,data ){ con.giveWithError( err,data ) } );
    }

  }

  return con;
}

fileDelete.defaults =
{
  pathFile : null,
  force : 0,
  sync : 1,
}

//

var fileHardlink = function( options )
{
  var con = new wConsequence();

  if( arguments.length === 2 )
  {
    options = { pathDst : arguments[ 0 ], pathSrc : arguments[ 1 ] };
  }
  else
  {
    _.assert( arguments.length === 1 );
  }

  _.assertMapOnly( options,fileHardlink.defaults );
  _.mapComplement( options,fileHardlink.defaults );
  _.assert( _.strIs( options.pathSrc ) );
  _.assert( _.strIs( options.pathDst ) );

  var stat = File.statSync( options.pathSrc );
  if( !stat.isFile() )
  throw _.err( 'cant hardlink not file :',options.pathSrc );

  File.linkSync( options.pathSrc,options.pathDst );

  return con.give();
}

fileHardlink.defaults =
{
  pathDst : null,
  pathSrc : null,
}

//

var filesList = function filesList( pathFile )
{
  var files = [];

  if( File.existsSync( pathFile ) )
  {
    var stat = File.statSync( pathFile );
    if( stat.isDirectory() )
    files = File.readdirSync( pathFile );
    else
    {
      files = [ pathFile ];
      return files;
    }
  }

  files.sort( function( a, b )
  {
    a = a.toLowerCase();
    b = b.toLowerCase();
    if( a < b ) return -1;
    if( a > b ) return +1;
    return 0;
  });

  return files;
}

//

var filesIsUpToDate = function( o )
{
  _.assertMapOnly( o,filesIsUpToDate.defaults );
  _.mapComplement( o,filesIsUpToDate.defaults );

  if( o.srcOptions || o.dstOptions )
  throw _.err( 'not tested' );

/*
  var recordOptions =
  {
    pathFile : o.path,
    recursive : o.recursive,
    maskAnyFile : _.pathRegexpSafeShrink(),
  }
*/

  var srcFiles = _.fileRecordsFiltered( o.src,o.srcOptions );

/*
  var srcFiles = _.filesFind
  ({

    pathFile : o.path,
    recursive : o.recursive,
    outputFormat : 'record',
    maskAnyFile : _.pathRegexpSafeShrink( o.srcMask ),

  });
*/

  if( !srcFiles.length )
  {
    if( o.usingLogging )
    logger.logDown( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.max( srcFiles,function( file ){ return file.stat.mtime.getTime() } );

  /**/

/*
  var dstFiles = _.filesFind
  ({

    pathFile : o.path,
    recursive : o.recursive,
    outputFormat : 'record',
    maskAnyFile : _.pathRegexpSafeShrink( o.dstMask ),

  });
*/

  var dstFiles = _.fileRecordsFiltered( o.dst,o.dstOptions );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.min( dstFiles,function( file ){ return file.stat.mtime.getTime() } );

/*
  var newest = allFiles[ 0 ].stat.mtime.getTime();
  for( var f = 1, fl = allFiles.length ; f < fl ; f++ ) {

    var file = allFiles[ f ];

    if( newest < file.stat.mtime.getTime() )
    newest = file.stat.mtime.getTime();

  }

  var stat = File.statSync( abs );
*/

  debugger;
  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.usingLogging )
    logger.logDown( 'Up to date' );
    return true;

  }

  return false;
}

filesIsUpToDate.defaults =
{
  //path : null,
  //recursive : 1,
  src : null,
  srcOptions : null,
  dst : null,
  dstOptions : null,
  usingLogging : 1,
}

// --
// path
// --

var pathNormalize = function( src )
{
  var result = Path.normalize( src ).replace( /\\/g,'/' );
  return result;
}

//

var pathRelative = function( relative,path )
{

  var result = Path.relative( relative,path );
  result = _.pathNormalize( result );

  return result;
}

//

var pathResolve = function()
{

  var result = Path.resolve.apply( this,arguments );
  result = _.pathNormalize( result );

  return result;
}

//

var pathIsSafe = function( pathFile )
{
  var safe = true;

  _.assert( _.strIs( pathFile ) );

  safe = safe && !/(^|\/)\.(?!$|\/)/.test( pathFile );

  if( safe )
  safe = pathFile.length > 8 || ( pathFile[ 0 ] !== '/' && pathFile[ 1 ] !== ':' );

  return safe;
}

//

var pathRegexpSafeShrink = function( maskAnyFile )
{

  var maskAnyFile = _.regexpObjectMake( maskAnyFile || {},'includeAny' );
  var excludeMask = _.regexpObjectMake
  ({
    excludeAny :
    [
      'node_modules',
      '.unique',
      '.git',
      '.svn',
      /(^|\/)\.(?!$|\/)/,
      /(^|\/)file($|\/)/,
    ],
  });

  maskAnyFile = _.regexpObjectShrink( maskAnyFile,excludeMask );

  return maskAnyFile;
}

//

var _pathMainFile;
var pathMainFile = function()
{
  if( _pathMainFile ) return _pathMainFile;
  _pathMainFile = _.pathNormalize( require.main.filename );
  return _pathMainFile;
}

//

var _pathMainDir;
var pathMainDir = function()
{
  if( _pathMainDir ) return _pathMainDir;
  _pathMainDir = _.pathNormalize( Path.dirname( require.main.filename ) );
  return _pathMainDir;
}

//

var pathCurrent = function()
{
  _.assert( arguments.length === 0 || arguments.length === 1 );

  if( arguments.length === 1 && arguments[ 0 ] )
  try
  {

    var path = arguments[ 0 ];
    _.assert( _.strIs( path ) );

    if( File.existsSync( path ) && _.fileIs( path ) )
    path = _.pathJoin( path,'..' );

    process.chdir( path );

  }
  catch( err )
  {
    throw _.err( 'file was not found : ' + arguments[ 0 ] + '\n',err );
  }

  var result = process.cwd();
  result = _.pathNormalize( result );

  return result;
}

//

var pathHome = function()
{
  var home = process.env[ ( process.platform == 'win32' ) ? 'USERPROFILE' : 'HOME' ] || __dirname;
  return home;
}

// --
// encoding
// --

var encodings = {};

encodings[ 'json' ] =
{

  onBegin : function( o )
  {
    _.assert( o.encoding === 'json' );
    o.encoding = 'utf8';
  },

  onEnd : function( read )
  {
    _.assert( _.strIs( read.data ) );
    var result = JSON.parse( read.data );
    return result;
  },

}

encodings[ 'arraybuffer' ] =
{

  onBegin : function( o )
  {

    //logger.log( '! debug : ' + Config.debug );

    _.assert( o.encoding === 'arraybuffer' );
    o.encoding = 'buffer';
  },

  onEnd : function( read )
  {

    _.assert( _.bufferNodeIs( read.data ) );
    _.assert( !_.bufferIs( read.data ) );
    _.assert( !_.bufferRawIs( read.data ) );

    var result = _.bufferRawFrom( read.data );

    _.assert( !_.bufferNodeIs( result ) );
    _.assert( _.bufferRawIs( result ) );

    return result;
  },

}

fileRead.encodings = encodings;

// --
// file provider
// --

var fileProviderFileSystem = (function( o )
{

  var provider =
  {

    name : 'fileProviderFileSystem',

    fileRead : fileRead,
    fileWrite : fileWrite,

    filesRead: _.filesRead_gen( fileRead ),

  };

  return fileProviderFileSystem = function( o )
  {
    var o = o || {};

    _.assert( arguments.length === 0 || arguments.length === 1 );
    _.assertMapOnly( o,fileProviderFileSystem.defaults );

    return provider;
  }

})();

fileProviderFileSystem.defaults = {};

//

var fileProvider =
{

  fileSystem : fileProviderFileSystem,

  def : fileProviderFileSystem,

}

// --
// prototype
// --

var Proto =
{

  fileRecord: fileRecord,
  _fileRecord: _fileRecord,
  fileRecordToAbsolute: fileRecordToAbsolute,

  fileRecords: fileRecords,
  fileRecordsFiltered: fileRecordsFiltered,

  fileHash: fileHash,
  filesShadow: filesShadow,


  // find

  _filesOptions: _filesOptions,
  _filesMaskAdjust: _filesMaskAdjust,
  _filesAddResultFor: _filesAddResultFor,

  filesFind: filesFind,
  filesFindDifference: filesFindDifference,
  filesFindSame: filesFindSame,


  // action

  filesGlob: filesGlob,
  filesCopy: filesCopy,
  filesDelete: filesDelete,
  filesDeleteEmptyDirs: filesDeleteEmptyDirs,


  // tree

  filesTreeWrite: filesTreeWrite,
  filesTreeRead: filesTreeRead,


  // resolve

  filesResolve: filesResolve,
  _filesResolveMakeGlob: _filesResolveMakeGlob,


  // individual

  directoryIs: directoryIs,
  fileIs: fileIs,
  fileSymbolicLinkIs: fileSymbolicLinkIs,

  _fileOptionsGet: _fileOptionsGet,

  fileWrite: fileWrite,
  fileWriteJson: fileWriteJson,

  fileRead: fileRead,
  fileReadSync: fileReadSync,
  fileReadJson: fileReadJson,

  filesRead: _.filesRead_gen ? _.filesRead_gen( fileRead ) : null,

  filesSame: filesSame,
  filesLinked: filesLinked,
  filesLink: filesLink,
  filesNewer: filesNewer,
  filesOlder: filesOlder,

  filesSpectre: filesSpectre,
  filesSimilarity: filesSimilarity,

  filesSize: filesSize,
  fileSize: fileSize,

  fileDelete: fileDelete,
  fileHardlink: fileHardlink,

  filesList: filesList,
  filesIsUpToDate: filesIsUpToDate,


  // path

  /*urlNormalize: urlNormalize,*/
  pathNormalize: pathNormalize,
  pathRelative: pathRelative,
  pathResolve: pathResolve,

  pathIsSafe: pathIsSafe,
  pathRegexpSafeShrink: pathRegexpSafeShrink,

  pathMainFile: pathMainFile,
  pathMainDir: pathMainDir,
  pathCurrent: pathCurrent,

  pathHome: pathHome,

};

_.mapExtend( Self,Proto );
Self.fileProvider = _.mapExtend( Self.fileProvider || {},fileProvider );

//

if( typeof module !== 'undefined' )
{
  module['exports'] = Self;
}

})();
