(function _Files_ss_() {

'use strict';

var toBuffer = null;

if( typeof module !== 'undefined' )
{

  try
  {
    require( 'wFileCommon' );
  }
  catch( err )
  {
    require( './FileCommon.s' );
  }

  require( './FileRecord.ss' );

}

var Path = require( 'path' );
var File = require( 'fs-extra' );
var Os = require( 'os' );

var _ = wTools;
var FileRecord = _.FileRecord;
var Self = wTools;

//

/*

problems :

  !!! naming problem : fileStore / fileDirectory / fileAny

*/

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

var filesFind = function()
{

  _.assert( arguments.length <= 4 );

  if( arguments[ 3 ] ) return _.timeOut( 0, function()
  {
    arguments[ 3 ]( filesFind( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  });

  var o = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _.assertMapOnly( o,filesFind.defaults );
  _.mapComplement( o,filesFind.defaults );
  _filesMaskAdjust( o );

  if( !o.pathFile )
  throw _.err( 'filesFind :','"pathFile" required' );

  var time;
  if( o.usingTiming )
  time = _.timeNow();

  o.pathFile = _.arrayAs( o.pathFile );

  var result = o.result = o.result || [];
  var relative = o.relative;
  /*var orderingExclusion = _.arrayAs( o.orderingExclusion );*/
  var orderingExclusion = _.regexpObjectOrering( o.orderingExclusion || [] );

  //

  var _filesAddResultFor = function( options )
  {
    var addResult;

    if( options.outputFormat === 'absolute' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( options.result,record.absolute ) >= 0 )
      {
        debugger;
        return;
      }
      options.result.push( record.absolute );
    }
    else if( options.outputFormat === 'relative' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( options.result,record.relative ) >= 0 )
      {
        debugger;
        return;
      }
      options.result.push( record.relative );
    }
    else if( options.outputFormat === 'record' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( options.result,record.absolute,function( e ){ return e.absolute; } ) >= 0 )
      {
        debugger;
        return;
      }
      options.result.push( record );
    }
    else if( options.outputFormat === 'nothing' )
    addResult = function( record )
    {
    }
    else throw _.err( 'unexpected output format :',options.outputFormat );

    return addResult;
  }

  var addResult = _filesAddResultFor( o );

  //

  var eachFile = function( pathFile,o )
  {

    o = _.mapExtend( {},o );
    o.pathFile = pathFile;

    var files = _.filesList( pathFile );

    if( _.fileIs( o.pathFile ) )
    {
      o.pathFile = _.pathDir( o.pathFile );
    }

    // files

    var recordOptions = _._mapScreen
    ({
      screenObjects : wFileRecord.prototype.Composes,
      /* srcObjects : [ o ], */
      srcObjects : [ o,{ dir : o.pathFile } ],
    });

    if( o.includeFiles )
    for( var f = 0 ; f < files.length ; f++ )
    {

      var record = FileRecord( files[ f ],recordOptions );

      if( record.isDirectory ) continue;
      if( !record.inclusion ) continue;

      _.routinesCall( o,o.onUp,[ record ] );
      addResult( record );
      _.routinesCall( o,o.onDown,[ record ] );

    }

    // dirs

    var recordOptions = _._mapScreen
    ({
      screenObjects : wFileRecord.prototype.Composes,
      srcObjects : [ o,{ dir : o.pathFile } ],
    });

    for( var f = 0 ; f < files.length ; f++ )
    {

      var record = FileRecord( files[ f ],recordOptions );

      if( !record.isDirectory ) continue;
      if( !record.inclusion ) continue;

      if( o.includeDirectories )
      {

        _.routinesCall( o,o.onUp,[ record ] );
        addResult( record );

      }

      if( o.recursive )
      eachFile( record.absolute + '/',o );

      if( o.includeDirectories )
      _.routinesCall( o,o.onDown,[ record ] );

    }

  }

  /**/

  var ordering = function( pathes,o )
  {

    if( _.strIs( pathes ) )
    pathes = [ pathes ];
    pathes = _.arrayUnique( pathes );

    _.assert( _.arrayIs( pathes ),'expects string or array' );

    for( var p = 0 ; p < pathes.length ; p++ )
    {
      var pathFile = pathes[ p ];

      _.assert( _.strIs( pathFile ) );

      if( pathFile[ pathFile.length-1 ] === '/' )
      pathFile = pathFile.substr( 0,pathFile.length-1 );

      o.pathFile = pathFile;

      if( relative === undefined || relative === null )
      o.relative = pathFile;

      if( o.ignoreNonexistent )
      if( !File.existsSync( pathFile ) )
      continue;

      eachFile( pathFile,o );

    }

  }

  /* ordering */

  if( !orderingExclusion.length )
  {
    ordering( o.pathFile,_.mapExtend( {},o ) );
  }
  else
  {
    var maskStoreFile = o.maskStoreFile;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      o.maskStoreFile = _.regexpObjectShrink( {},maskStoreFile,orderingExclusion[ e ] );
      ordering( o.pathFile,_.mapExtend( {},o ) );
    }
  }

  /* sort */

  if( o.sortWithArray )
  {

    _.assert( _.arrayIs( o.sortWithArray ) );

    if( o.outputFormat === 'record' )
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortWithArray,a.relative ) - _.regexpArrayIndex( o.sortWithArray,b.relative );
    })
    else
    result.sort( function( a,b )
    {
      return _.regexpArrayIndex( o.sortWithArray,a ) - _.regexpArrayIndex( o.sortWithArray,b );
    });

  }

  /* timing */

  //debugger;

  if( o.usingTiming )
  logger.log( _.timeSpent( time,'to find at ' + o.pathFile + ' found ' + result.length ) );

  /**/
/*
  logger.log( 'filesFind result.length : ' + result.length );

  if( Config.debug && 1 )
  _.assert( _.arrayCountSame( result,function( e ){ return e.absolute } ) === 0,'filesFind result should not have duplicates' );

  logger.log( 'filesFind result.length : ' + result.length );
*/

  /**/

  return result;
}

filesFind.defaults =
{

  pathFile : null,
  relative : null,

  safe : 1,
  verboseCantAccess : 0,
  recursive : 0,
  ignoreNonexistent : 0,
  includeFiles : 1,
  includeDirectories : 0,
  outputFormat : 'record',

  result : [],
  orderingExclusion : [],
  sortWithArray : null,
  usingTiming : 0,

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

  if( options.read !== undefined || options.hash !== undefined || options.latters !== undefined )
  throw _.err( 'filesFind:','options are deprecated',_.toStr( options ) );

  //

  var _filesAddResultFor = function( options )
  {
    var addResult;

    if( options.outputFormat === 'absolute' )
    addResult = function( record )
    {
      options.result.push([ record.src.absolute,record.dst.absolute ]);
    }
    else if( options.outputFormat === 'relative' )
    addResult = function( record )
    {
      options.result.push([ record.src.relative,record.dst.relative ]);
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

  var addResult = _filesAddResultFor( options );

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

  var dstOptions = _.mapScreen( wFileRecord.prototype.Composes,options );
  dstOptions.dir = dst;
  dstOptions.relative = dst;

  // src

  var srcOptions = _.mapScreen( wFileRecord.prototype.Composes,options );
  srcOptions.dir = src;
  srcOptions.relative = src;

  // src file

  var srcFile = function srcFile( dstOptions,srcOptions,file )
  {

    var srcRecord = FileRecord( file,_.mapScreen( wFileRecord.prototype.Composes,srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = FileRecord( file,_.mapScreen( wFileRecord.prototype.Composes,dstOptions ) );
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
        record.link = _.filesLinked( dstRecord, srcRecord );
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

    var srcRecord = FileRecord( file,srcOptions );
    srcRecord.side = 'src';

    if( !srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = FileRecord( file,dstOptions );
    dstRecord.side = 'dst';

    //
/*
    debugger;

    var srcRecord = FileRecord( file,srcOptions );
    srcRecord.side = 'src';

    var dstRecord = FileRecord( file,dstOptions );
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

    var srcRecord = FileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = FileRecord( file,dstOptions );
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

    var srcRecord = FileRecord( file,srcOptions );
    srcRecord.side = 'src';
    var dstRecord = FileRecord( file,dstOptions );
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
        var dstRecord = FileRecord( found[ fo ].absolute,dstOptions );
        dstRecord.side = 'dst';
        var srcRecord = FileRecord( dstRecord.relative,srcOptions );
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

  var o = _filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _filesMaskAdjust( o );
  debugger;

  _.assertMapOnly( o,filesFindSame.defaults );
  _.mapComplement( o,filesFindSame.defaults );

  if( !o.pathFile ) throw _.err( 'filesFindSame:','"pathFile" required' );
  if( o.pathOnly !== undefined ) throw _.err( 'filesFindSame:','"pathOnly" is deprecated, use "outputFormat"' );

  /* output format */

  if( o.outputFormat === undefined ) o.outputFormat = 'record';
  //if( o.outputFormat !== 'record' ) throw _.err( 'filesFindSame:','outputFormat could be only full' );
  var outputFormat = o.outputFormat;
  o.outputFormat = 'record';

  /* result */

  var result = o.result;
  _.assert( _.objectIs( result ) );
  /* if( !result.same ) result.same = []; */
  if( !result.sameContent && o.usingContentComparing ) result.sameContent = [];
  if( !result.sameName ) result.sameName = [];
  if( !result.linked && o.usingLinkedCollecting ) result.linked = []
  if( !result.similar && o.similarity ) result.similar = [];

  /* time */

  var time;
  if( o.usingTiming )
  time = _.timeNow();

  /* find */

  var findOptions = _.mapScreen( filesFind.defaults,o );
  findOptions.outputFormat = 'record';
  findOptions.result = [];
  result.unique = _.filesFind( findOptions );
  //console.log( 'result.unique.length : ' + result.unique.length );
  //console.log( 'Object.keys( result ).length : ' + Object.keys( result ).length );
  //debugger;

  /* link */

  var checkLink = function()
  {

    if( _.filesLinked( file1,file2 ) )
    {
      file2._linked = 1;
      if( o.usingLinkedCollecting )
      linkedRecord.push( file2 );
      return true;
    }

    return false;
  }

  /* content */

  var checkContent = function()
  {

    var same = false;
    if( o.usingContentComparing )
    same = _.filesSame( file1,file2,o.usingTime );
    if( same )
    {

      if( o.usingNameComparingContent && file1.file !== file2.file )
      return false;

      if( !file2._haveSameContent )
      {
        file2._haveSameContent = 1;
        sameContentRecord.push( file2 );
        return true;
      }

    }

    return false;
  }

  /* similarity */

  var checkSimilarity = function()
  {

    if( o.similarity )
    if( file1.stat.size <= o.lattersFileSizeLimit && file1.stat.size <= o.lattersFileSizeLimit )
    if( Math.min( file1.stat.size,file2.stat.size ) / Math.max( file1.stat.size,file2.stat.size ) >= o.similarity )
    {
      var similarity = _.filesSimilarity( file1,file2 );
      if( similarity >= o.similarity )
      {
        var similarity = _.filesSimilarity( file1,file2 );
        result.similar.push({ files:[ file1,file2 ],similarity:similarity });
        return true;
      }
    }

    return false;
  }

  /* name */

  var checkName = function()
  {

    if( file1.file === file2.file && !file2._haveSameName )
    {
      file2._haveSameName = 1;
      sameNameRecord.push( file2 );
      return true;
    }

    return false;
  }

  /* compare */

  //console.log( 'result.unique : ' + _.toStr( _.entitySelect( result.unique,'*.absolute' ),{ levels : 3 } ) );
  //debugger;

  debugger;
  var sameNameRecord, sameContentRecord, linkedRecord;
  for( var f1 = 0 ; f1 < result.unique.length ; f1++ )
  {

    var file1 = result.unique[ f1 ];

    if( !file1.stat )
    continue;

    if( o.usingContentComparing )
    if( file1.hash === undefined )
    {
      file1.hash = file1.stat.size <= o.maxSize ? _.fileHash( file1.absolute ) : NaN;
    }

    sameNameRecord = [ file1 ];
    sameContentRecord = [ file1 ];
    linkedRecord = [ file1 ];

    debugger;
    for( var f2 = f1 + 1 ; f2 < result.unique.length ; f2++ )
    {

      var file2 = result.unique[ f2 ];

/*
      if( file1.absolute.indexOf( 'wFiles' ) !== -1 && file2.absolute.indexOf( 'wFiles' ) !== -1 )
      if( file1.absolute.indexOf( '/amid/file/Files.ss' ) !== -1 && file2.absolute.indexOf( '/amid/file/Files.ss' ) !== -1 )
      debugger;
*/

      if( file1.absolute.indexOf( '/amid/file/Files.ss' ) !== -1 && file2.absolute.indexOf( '/amid/file/Files.ss' ) !== -1 )
      debugger;

      if( o.usingContentComparing )
      if( file2.hash === undefined )
      {
        file2.hash = file2.stat.size <= o.maxSize ? _.fileHash( file2.absolute ) : NaN;
      }

      if( !file2.stat )
      continue;

      checkName();

      if( checkLink() )
      {
        result.unique.splice( f2,1 );
        f2 -= 1;
      }
      else if( checkContent() )
      {
        result.unique.splice( f2,1 );
        f2 -= 1;
      }
      else
      {

        checkSimilarity();

      }

    }

    /* store */

    if( linkedRecord && linkedRecord.length > 1 )
    {
      _.assert( _.arrayCountSame( linkedRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in linkedRecord' );
      result.linked.push( linkedRecord );
    }

    if( sameContentRecord && sameContentRecord.length > 1  )
    {
      _.assert( _.arrayCountSame( sameContentRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameContentRecord' );
      result.sameContent.push( sameContentRecord );
    }

    if( sameNameRecord && sameNameRecord.length > 1 )
    {
      _.assert( _.arrayCountSame( sameNameRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameNameRecord' );
      result.sameName.push( sameNameRecord );
    }

  }

  /* output format */

  if( outputFormat !== 'record' )
  for( var r in result )
  {
    if( r === 'unique' )
    result[ r ] = _.entitySelect( result[ r ],'*.' + outputFormat );
    else
    result[ r ] = _.entitySelect( result[ r ],'*.*.' + outputFormat );
  }

  /* validation */

  _.accessorForbid( result,{ same : 'same' } );

  /* timing */

  if( o.usingTiming )
  console.log( _.timeSpent( time,'to find same at ' + o.pathFile ) );

  return result;
}

filesFindSame.defaults =
{

  maxSize : 1 << 22,
  lattersFileSizeLimit : 1048576,
  similarity : 0,

  usingNameComparingContent : 1,
  usingTime : 0,
  usingLinkedCollecting : 0,
  usingContentComparing : 1,
  result : {},

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
          delete record.dst.stat;
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
          _.filesLink( record.dst.absolute,record.src.absolute )
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
        _.fileDelete({ pathFile : record.dst.absolute, force : 1 });
        delete record.dst.stat;

        // !!! error here. attempt to delete redundant dir with files.

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
      delete record.src.stat;
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

var filesTreeWrite = function( o )
{

  _.assert( arguments.length === 1 );
  _.assertMapOnly( o,filesTreeWrite.defaults );
  _.mapComplement( o,filesTreeWrite.defaults );
  _.assert( _.strIs( o.pathFile ) );

  //

  var stat = null;
  var handleWritten = function( pathFile )
  {
    if( !o.allowWrite )
    return;
    if( !o.sameTime )
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
    if( o.allowDelete && exists )
    {
      File.removeSync( pathFile );
      exists = false;
    }

    if( _.strIs( tree ) )
    {
      if( o.allowWrite && !exists )
      _.fileWrite( pathFile,tree );
      handleWritten( pathFile );
    }
    else if( _.objectIs( tree ) )
    {
      if( o.allowWrite && !exists )
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
      if( o.allowWrite && !exists )
      {
        var pathTarget = tree.softlink;
        if( o.absolutePathForLink )
        pathTarget = _.pathResolve( _.pathJoin( pathFile,'..',tree.softlink ) );
        File.symlinkSync( pathTarget,pathFile );
      }
      handleWritten( pathFile );
    }

  }

  write( o.pathFile,o.tree );

}

filesTreeWrite.defaults =
{
  tree : null,
  pathFile : null,
  sameTime : 0,
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

  /**
   * Return True if path is an existing directory. If path is symbolic link to file or directory return false.
   * @example
   * wTools.directoryIs( './existingDir/' ); // true
   * @param {string} filename Tested path string
   * @returns {boolean}
   * @method directoryIs
   * @memberof wTools
   */

var directoryIs = function( filename )
{

  if( fileSymbolicLinkIs( filename ) )
  {
    // throw _.err( 'Not tested' );
    return false;
  }

  try
  {

    var stat = File.statSync( filename );
    return stat.isDirectory();

  } catch( err ){ return };

}

//

  /**
   * Returns true if path is an existing regular file.
   * @example
   * wTools.fileIs( './existingDir/test.txt' ); // true
   * @param {string} filename Path string
   * @returns {boolean}
   * @method fileIs
   * @memberof wTools
   */

var fileIs = function( filename )
{

  if( fileSymbolicLinkIs( filename ) )
  {
    // throw _.err( 'Not tested' );
    return false;
  }

  try
  {

    var stat = File.statSync( filename );
    return stat.isFile();

  } catch( err ){ return };

}

//


  /**
   * Return True if `filename` refers to a directory entry that is a symbolic link.
   * @param filename
   * @returns {boolean}
   * @method fileSymbolicLinkIs
   * @memberof wTools
   */

var fileSymbolicLinkIs = function( filename )
{

  if( !File.existsSync( filename ) )
  return false;

  var stat = File.lstatSync( filename );

  if( !stat )
  return false;

  return stat.isSymbolicLink();
}


//

  /**
   * Return options for file red/write. If `pathFile is an object, method returns it. Method validate result option
      properties by default parameters from invocation context.
   * @param {string|Object} pathFile
   * @param {Object} [o] Object with default options parameters
   * @returns {Object} Result options
   * @private
   * @throws {Error} If arguments is missed
   * @throws {Error} If passed extra arguments
   * @throws {Error} If missed `PathFiile`
   * @method _fileOptionsGet
   * @memberof wTools
   */

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

  /**
   * Writes data to a file. `data` can be a string or a buffer. Creating the file if it does not exist yet.
   * Returns wConsequence instance.
   * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
     exist, it's created. Method can accept two parameters: string `pathFile` and string\buffer `data`, or single
     argument: options object, with required 'pathFile' and 'data' parameters.
   * @example
   *  var fs = require('fs');
      var data = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
        options =
        {
          pathFile : 'tmp/sample.txt',
          data : data,
          sync : false,
          force : true,
        };
      var con = wTools.fileWrite( options );
      con.got( function()
      {
          console.log('write finished');
          var fileContent = fs.readFileSync( 'tmp/sample.txt', { encoding: 'utf8' } );
          // 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.'
      });
   * @param {Object} options write options
   * @param {string} options.pathFile path to file is written.
   * @param {string|Buffer} [options.data=''] data to write
   * @param {boolean} [options.append=false] if this options sets to true, method appends passed data to existing data
      in a file
   * @param {boolean} [options.sync=true] if this parameter sets to false, method writes file asynchronously.
   * @param {boolean} [options.force=true] if it's set to false, method throws exception if parents dir in `pathFile`
      path is not exists
   * @param {boolean} [options.silentError=false] if it's set to true, method will catch error, that occurs during
      file writes.
   * @param {boolean} [options.usingLogging=false] if sets to true, method logs write process.
   * @param {boolean} [options.clean=false] if sets to true, method removes file if exists before writing
   * @returns {wConsequence}
   * @throws {Error} If arguments are missed
   * @throws {Error} If passed more then 2 arguments.
   * @throws {Error} If `pathFile` argument or options.PathFile is not string.
   * @throws {Error} If `data` argument or options.data is not string or Buffer,
   * @throws {Error} If options has unexpected property.
   * @method fileWrite
   * @memberof wTools
   */

var fileWrite = function( pathFile,data )
{
  var con = wConsequence();
  var o;

  if( _.strIs( pathFile ) )
  {
    o = { pathFile : pathFile, data : data };
    _.assert( arguments.length === 2 );
  }
  else
  {
    o = arguments[ 0 ];
    _.assert( arguments.length === 1 );
  }

  if( o.data === undefined )
  o.data = data;

  /* from buffer */

  if( _.bufferIs( o.data ) )
  {
    o.data = _.bufferToNodeBuffer( o.data );
  }

  /* log */

  if( o.usingLogging )
  logger.log( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',o.pathFile );

  /* verification */

  _.mapComplement( o,fileWrite.defaults );
  _.assertMapOnly( o,fileWrite.defaults );
  _.assert( _.strIs( o.pathFile ) );
  _.assert( _.strIs( o.data ) || _.bufferNodeIs( o.data ),'expects string or node buffer, but got',_.strTypeOf( o.data ) );

  /* force */

  if( o.force )
  {

    var pathFile = Path.dirname( o.pathFile );
    if( !File.existsSync( pathFile ) )
    File.mkdirsSync( pathFile );

  }

  /* clean */

  if( o.clean )
  {
    try
    {
      File.unlinkSync( o.pathFile );
    }
    catch( err )
    {
    }
  }

  /* write */

  if( o.sync )
  {

    if( o.silentError ) try
    {
      if( o.append )
      File.appendFileSync( o.pathFile, o.data );
      else
      File.writeFileSync( o.pathFile, o.data );
    }
    catch( err ){}
    else
    {
      if( o.append )
      File.appendFileSync( o.pathFile, o.data );
      else
      File.writeFileSync( o.pathFile, o.data );
    }
    con.give();

  }
  else
  {

    var handleEnd = function( err )
    {
      if( err && !o.silentError )
      _.errLog( '+ writing',_.toStr( o.data,{ levels : 0 } ),'to',o.pathFile,'\n',err );
      con._giveWithError( err,null );
    }

    if( o.append )
    File.appendFile( o.pathFile, o.data, handleEnd );
    else
    File.writeFile( o.pathFile, o.data, handleEnd );

  }

  /* */

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


  /**
   * Writes data as json string to a file. `data` can be a any primitive type, object, array, array like. Method can
      accept options similar to fileWrite method, and have similar behavior.
   * Returns wConsequence instance.
   * By default method writes data synchronously, with replacing file if exists, and if parent dir hierarchy doesn't
   exist, it's created. Method can accept two parameters: string `pathFile` and string\buffer `data`, or single
   argument: options object, with required 'pathFile' and 'data' parameters.
   * @example
   *  var fs = require('fs');
   var data = { a: 'hello', b: 'world' },
   var con = wTools.fileWriteJson( 'tmp/sample.json', data );
   // file content: {"a":"hello", "b":"world"}

   * @param {Object} options write options
   * @param {string} options.pathFile path to file is written.
   * @param {string|Buffer} [options.data=''] data to write
   * @param {boolean} [options.append=false] if this options sets to true, method appends passed data to existing data
   in a file
   * @param {boolean} [options.sync=true] if this parameter sets to false, method writes file asynchronously.
   * @param {boolean} [options.force=true] if it's set to false, method throws exception if parents dir in `pathFile`
   path is not exists
   * @param {boolean} [options.silentError=false] if it's set to true, method will catch error, that occurs during
   file writes.
   * @param {boolean} [options.usingLogging=false] if sets to true, method logs write process.
   * @param {boolean} [options.clean=false] if sets to true, method removes file if exists before writing
   * @param {string} [options.pretty=''] determines data stringify method.
   * @returns {wConsequence}
   * @throws {Error} If arguments are missed
   * @throws {Error} If passed more then 2 arguments.
   * @throws {Error} If `pathFile` argument or options.PathFile is not string.
   * @throws {Error} If options has unexpected property.
   * @method fileWriteJson
   * @memberof wTools
   */

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
  options.data = _.stringify( options.data );
  else
  options.data = JSON.stringify( options.data );

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

  /**
   * Reads the entire content of a file.
   * Can accepts `pathFile` as first parameters and options as second
   * Returns wConsequence instance. If `o` sync parameter is set to true (by default) and returnRead is set to true,
      method returns encoded content of a file.
   * There are several way to get read content: as argument for function passed to wConsequence.got(), as second argument
      for `o.onEnd` callback, and as direct method returns, if `o.returnRead` is set to true.
   *
   * @example
   * // content of tmp/json1.json: {"a":1,"b":"s","c":[1,3,4]}
     var fileReadOptions =
     {
       sync : 0,
       pathFile : 'tmp/json1.json',
       encoding : 'json',

       onEnd : function( err, result )
       {
         console.log(result); // { a: 1, b: 's', c: [ 1, 3, 4 ] }
       }
     };

     var con = wTools.fileRead( fileReadOptions );

     // or
     fileReadOptions.onEnd = null;
     var con2 = wTools.fileRead( fileReadOptions );

     con2.got(function( err, result )
     {
       console.log(result); // { a: 1, b: 's', c: [ 1, 3, 4 ] }
     });

   * @example
     fileRead({ pathFile : file.absolute, encoding : 'buffer' })

   * @param {Object} o read options
   * @param {string} o.pathFile path to read file
   * @param {boolean} [o.sync=true] determines in which way will be read file. If this set to false, file will be read
      asynchronously, else synchronously
   * Note: if even o.sync sets to true, but o.returnRead if false, method will resolve read content through wConsequence
      anyway.
   * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
      into object with key 'options' and options as value.
   * @param {boolean} [o.returnRead=false] If sets to true, method will return encoded file content directly. Has effect
      only if o.sync is set to true.
   * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
      pass into o.onEnd as first parameter. Note: if sync is set to false, error will caught anyway.
   * @param {string} [o.name=null]
   * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are:
   *    'utf8': default value, file content will be read as string.
   *    'json': file content will be parsed as JSON.
   *    'arrayBuffer': the file content will be return as raw ArrayBuffer.
   * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
   * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
   * @param {Function} [o.onError=null] @see [@link fileRead~onError]
   * @param {*} [o.advanced=null]
   * @returns {wConsequence|ArrayBuffer|string|Array|Object}
   * @throws {Error} if missed arguments
   * @throws {Error} if `o` has extra parameters
   * @method fileRead
   * @memberof wTools
   */

  /**
   * This callback is run before fileRead starts read the file. Accepts error as first parameter.
   * If in fileRead passed 'o.wrap' that is set to true, callback accepts as second parameter object with key 'options'
      and value that is reference to options object passed into fileRead method, and user has ability to configure that
      before start reading file.
   * @callback fileRead~onBegin
   * @param {Error} err
   * @param {Object|*} options options argument passed into fileRead.
   */

  /**
   * This callback invoked after file has been read, and accepts encoded file content data (by depend from
      options.encoding value), string by default ('utf8' encoding).
   * @callback fileRead~onEnd
   * @param {Error} err Error occurred during file read. If read success it's sets to null.
   * @param {ArrayBuffer|Object|Array|String} result Encoded content of read file.
   */

  /**
   * Callback invoke if error occurred during file read.
   * @callback fileRead~onError
   * @param {Error} error
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

  var handleBegin = function(err, data)
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

  /**
   * Reads the entire content of a file synchronously.
   * Method returns encoded content of a file.
   * Can accepts `pathFile` as first parameters and options as second
   *
   * @example
   * // content of tmp/json1.json: {"a":1,"b":"s","c":[1,3,4]}
   var fileReadOptions =
   {
     pathFile : 'tmp/json1.json',
     encoding : 'json',

     onEnd : function( err, result )
     {
       console.log(result); // { a: 1, b: 's', c: [ 1, 3, 4 ] }
     }
   };

   var res = wTools.fileReadSync( fileReadOptions );
   // { a: 1, b: 's', c: [ 1, 3, 4 ] }

   * @param {Object} o read options
   * @param {string} o.pathFile path to read file
   * @param {boolean} [o.wrap=false] If this parameter sets to true, o.onBegin callback will get `o` options, wrapped
   into object with key 'options' and options as value.
   * @param {boolean} [o.silent=false] If set to true, method will caught errors occurred during read file process, and
   pass into o.onEnd as first parameter. Note: if sync is set to false, error will caught anyway.
   * @param {string} [o.name=null]
   * @param {string} [o.encoding='utf8'] Determines encoding processor. The possible values are:
   *    'utf8': default value, file content will be read as string.
   *    'json': file content will be parsed as JSON.
   *    'arrayBuffer': the file content will be return as raw ArrayBuffer.
   * @param {fileRead~onBegin} [o.onBegin=null] @see [@link fileRead~onBegin]
   * @param {Function} [o.onEnd=null] @see [@link fileRead~onEnd]
   * @param {Function} [o.onError=null] @see [@link fileRead~onError]
   * @param {*} [o.advanced=null]
   * @returns {wConsequence|ArrayBuffer|string|Array|Object}
   * @throws {Error} if missed arguments
   * @throws {Error} if `o` has extra parameters
   * @method fileReadSync
   * @memberof wTools
   */

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

  /**
   * Reads a JSON file and then parses it into an object.
   *
   * @example
   * // content of tmp/json1.json: {"a":1,"b":"s","c":[1,3,4]}
   *
   * var res = wTools.fileReadJson( 'tmp/json1.json' );
   * // { a: 1, b: 's', c: [ 1, 3, 4 ] }
   * @param {string} pathFile file path
   * @returns {*}
   * @throws {Error} If missed arguments, or passed more then one argument.
   * @method fileReadJson
   * @memberof wTools
   */


var fileReadJson = function( pathFile )
{
  var result = null;
  var pathFile = _.pathGet( pathFile );

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

  /**
   * Check if two paths, file stats or FileRecords are associated with the same file or files with same content.
   * @example
   * var path1 = 'tmp/sample/file1',
       path2 = 'tmp/sample/file2',
       usingTime = true,
       buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

     wTools.fileWrite( { pathFile : path1, data: buffer } );
     setTimeout( function()
     {
       wTools.fileWrite( { pathFile : path2, data: buffer } );

       var sameWithoutTime = wTools.filesSame( path1, path2 ); // true

       var sameWithTime = wTools.filesSame( path1, path2, usingTime ); // false
     }, 100);
   * @param {string|wFileRecord} ins1 first file to compare
   * @param {string|wFileRecord} ins2 second file to compare
   * @param {boolean} usingTime if this argument sets to true method will additionally check modified time of files, and
      if they are different, method returns false.
   * @returns {boolean}
   * @method filesSame
   * @memberof wTools
   */

var filesSame = function( o )
{

  if( arguments.length === 2 || arguments.length === 3 )
  {
    o =
    {
      ins1 : arguments[ 0 ],
      ins2 : arguments[ 1 ],
      usingTime : arguments[ 2 ],
    }
  }

  _.assert( arguments.length === 1 || arguments.length === 2 || arguments.length === 3 );
  _.assertMapOnly( o,filesSame.defaults );
  _.mapSupplement( o,filesSame.defaults );

  o.ins1 = FileRecord( o.ins1 );
  o.ins2 = FileRecord( o.ins2 );

  if( !o.ins1.stat || !o.ins2.stat )
  return false;

  /* symlink */

  if( o.usingSymlink )
  if( o.ins1.stat.isSymbolicLink() || o.ins2.stat.isSymbolicLink() )
  {

    return false;
  // return false;

    debugger;
    console.warn( 'not tested' );

    var target1 = o.ins1.stat.isSymbolicLink() ? File.readlinkSync( o.ins1.absolute ) : o.ins1.absolute;
    var target2 = o.ins2.stat.isSymbolicLink() ? File.readlinkSync( o.ins2.absolute ) : o.ins2.absolute;

    if( target2 === target1 )
    return true;

    o.ins1 = FileRecord( target1 );
    o.ins2 = FileRecord( target2 );
    o.ins1 = FileRecord( target1 );
    o.ins2 = FileRecord( target2 );

  }

  /* false for empty files */

  if( !o.ins1.stat.size || !o.ins2.stat.size )
  return false;

  /* size */

  if( o.ins1.stat.size !== o.ins2.stat.size )
  return false;

  /**/

  if( o.usingTime )
  if( o.ins1.stat.mtime.getTime() !== o.ins2.stat.mtime.getTime() )
  return false;

  if( !o.ins1.hash ) o.ins1.hash = _.fileHash( o.ins1.absolute );
  if( !o.ins2.hash ) o.ins2.hash = _.fileHash( o.ins2.absolute );

  if( ( _.numberIs( o.ins1.hash ) && isNaN( o.ins1.hash ) ) || ( _.numberIs( o.ins2.hash ) && isNaN( o.ins2.hash ) ) )
  return false;

  return o.ins1.hash === o.ins2.hash;
}

filesSame.defaults =
{
  ins1 : null,
  ins2 : null,
  usingTime : false,
  usingSymlink : true,
}

//

  /**
   * Check if one of paths is hard link to other.
   * @example
     var fs = require('fs');

     var path1 = '/home/tmp/sample/file1',
     path2 = '/home/tmp/sample/file2',
     buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

     wTools.fileWrite( { pathFile : path1, data: buffer } );
     fs.symlinkSync( path1, path2 );

     var linked = wTools.filesLinked( path1, path2 ); // true

// +++ not really string, FileRecord also

   * @param {string|wFileRecord} ins1 path string/file record instance
   * @param {string|wFileRecord} ins2 path string/file record instance

   * @returns {boolean}
   * @throws {Error} if missed one of arguments or pass more then 2 arguments.
   * @method filesLinked
   * @memberof wTools
   */

var filesLinked = function( param )
{

  if (arguments.length === 2)
  {
    _.assert( _.strIs( arguments[ 0 ] ) || arguments[ 0 ] instanceof FileRecord );
    _.assert( _.strIs( arguments[ 1 ] ) || arguments[ 1 ] instanceof FileRecord );
    param =
    {
      ins1: FileRecord( arguments[ 0 ] ),
      ins2: FileRecord( arguments[ 1 ] )
    }
  }
  else
  {
    _.assert( arguments.length === 1 );
    _.assertMapOnly( param, filesSame.defaults );
  }


/*
  if( _.strIs( ins1 ) )
  {
    // +++ if file not exists return false
    if( !File.existsSync( ins1) ) return false;
    ins1 = { absolute : ins1, stat : File.lstatSync( ins1 ) };
  }

  if( _.strIs( ins2 ) )
  {
    // +++ if file not exists return false
    if( !File.existsSync( ins2) ) return false;
    ins2 = { absolute : ins2, stat : File.lstatSync( ins2 ) };
  }
*/

  if( param.ins1.stat.isSymbolicLink() || param.ins2.stat.isSymbolicLink() )
  {

    // +++ check links targets
    // +++ use case needed, solution will go into FileRecord, probably
    return false;
    debugger;
    throw _.err( 'not tested' );

/*
    var target1 = ins1.stat.isSymbolicLink() ? File.readlinkSync( ins1.absolute ) : Path.resolve( ins1.absolute ),
      target2 =  ins2.stat.isSymbolicLink() ? File.readlinkSync( ins2.absolute ) : Path.resolve( ins2.absolute );
    return target2 === target1;
*/

  }

  /* ino comparison reliable test if ino present */
  if( param.ins1.stat.ino !== param.ins2.stat.ino ) return false;

  if( param.ins1.stat.ino !== -1 && param.ins1.stat.ino !== 0 )
  return param.ins1.stat.ino === param.ins2.stat.ino;

  /* try to guess otherwise */
  if( param.ins1.stat.nlink !== param.ins2.stat.nlink ) return false;
  if( param.ins1.stat.mode !== param.ins2.stat.mode ) return false;
  if( param.ins1.stat.mtime.getTime() !== param.ins2.stat.mtime.getTime() ) return false;
  if( param.ins1.stat.ctime.getTime() !== param.ins2.stat.ctime.getTime() ) return false;

  return true;
}

filesLinked.defaults =
{
  ins1 : null,
  ins2 : null,
};

//

  /**
   * Creates new name (hard link) for existing file. If pathSrc is not file or not exists method returns false.
      This method also can be invoked in next form: wTools.filesLink( pathDst, pathSrc ). If `o.pathDst` is already
      exists and creating link finish successfully, method rewrite it, otherwise the file is kept intact.
      In success method returns true, otherwise - false.
   * @example
   * var path = 'tmp/filesLink/data.txt',
     link = 'tmp/filesLink/h_link_for_data.txt',
     textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData1 = ' Aenean non feugiat mauris';


     wTools.fileWrite( { pathFile : path, data: textData } );
     wTools.filesLink( link, path );

     var content = wTools.fileReadSync(link); // Lorem ipsum dolor sit amet, consectetur adipiscing elit.
     console.log(content);
     wTools.fileWrite( { pathFile : path, data: textData1, append: 1 } );

     wTools.fileDelete( path ); // delete original name

     content = wTools.fileReadSync(link);
     console.log(content);
     // Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non feugiat mauris
     // but file is still exists)
   * @param {Object} o options parameter
   * @param {string} o.pathDst link path
   * @param {string} o.pathSrc file path
   * @param {boolean} [o.usingLogging=false] enable logging.
   * @returns {boolean}
   * @throws {Error} if missed one of arguments or pass more then 2 arguments.
   * @throws {Error} if one of arguments is not string.
   * @throws {Error} if file `o.pathDst` is not exist.
   * @method filesLink
   * @memberof wTools
   */

var filesLink = function( o )
{

  if( arguments.length === 2 )
  {
    o =
    {
      pathDst : arguments[ 0 ],
      pathSrc : arguments[ 1 ],
    }
  }

  _.assert( arguments.length === 1 || arguments.length === 2 );
  _.assertMapOnly( o,filesLink.defaults );

  o.pathDst = _.pathGet( o.pathDst );
  o.pathSrc = _.pathGet( o.pathSrc );

  if( o.usingLogging )
  logger.log( 'filesLink : ', o.pathDst + ' <- ' + o.pathSrc );

  if( o.pathDst === o.pathSrc )
  return true;

  if( !File.existsSync( o.pathSrc ) )
  return false;

  var temp;
  try
  {
    if( File.existsSync( o.pathDst ) )
    {
      temp = o.pathDst + '-' + _.idGenerateGuid();
      File.renameSync( o.pathDst,temp );
    }
    File.linkSync( o.pathSrc,o.pathDst );
    if( temp )
    File.unlinkSync( temp );
    return true;
  }
  catch( err )
  {
    if( temp )
    File.renameSync( temp,o.pathDst );
    return false;
  }

}

filesLink.defaults =
{
  pathDst : null,
  pathSrc : null,
  usingLogging : false,
}

//

  /**
   * Creates new name (hard link) for existing file. If pathSrc is not file or not exists method throws error.
      This method also can be invoked in next form: wTools.fileHardlink(pathDst, pathSrc).
   * @example
   * var path = 'tmp/fileHardlink/data.txt',
     link = 'tmp/fileHardlink/h_link_for_data.txt',
     textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData1 = ' Aenean non feugiat mauris';


     wTools.fileWrite( { pathFile : path, data: textData } );
     wTools.fileHardlink( link, path );

     var content = wTools.fileReadSync(link); // Lorem ipsum dolor sit amet, consectetur adipiscing elit.
     console.log(content);
     wTools.fileWrite( { pathFile : path, data: textData1, append: 1 } );

     wTools.fileDelete( path ); // delete original name

     content = wTools.fileReadSync(link);
     console.log(content);
    // Lorem ipsum dolor sit amet, consectetur adipiscing elit. Aenean non feugiat mauris
    // but file is still exists)
   *
   * @param {Object} options options object
   * @param {string} options.pathDst new name for file.
   * @param {string} options.pathSrc path to existing file
   * @returns {wConsequence}
   * @throws {Error} If missed argument, or pass more than 2 arguments.
   * @throws {Error} If pathDst or pathSrc is not string.
   * @throws {Error} If options object has unexpected property.
   * @throws {Error} If pathSrc is not exists, or is not file.
   * @method fileHardlink
   * @memberof wTools
   */
/*
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

  if( _.files.usingReadOnly )
  return con.give();

  // not safe, not complete !!!

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
*/

//

  /**
   * Returns path/stats associated with file with newest modified time.
   * @example
   * var fs = require('fs');

     var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

     wTools.fileWrite( { pathFile : path1, data: buffer } );
     setTimeout( function()
     {
       wTools.fileWrite( { pathFile : path2, data: buffer } );


       var newer = wTools.filesNewer( path1, path2 );
       // 'tmp/sample/file2'
     }, 100);
   * @param {string|File.Stats} dst first file path/stat
   * @param {string|File.Stats} src second file path/stat
   * @returns {string|File.Stats}
   * @throws {Error} if type of one of arguments is not string/file.Stats
   * @method filesNewer
   * @memberof wTools
   */

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

  /**
   * Returns path/stats associated with file with older modified time.
   * @example
   * var fs = require('fs');

   var path1 = 'tmp/sample/file1',
   path2 = 'tmp/sample/file2',
   buffer = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] );

   wTools.fileWrite( { pathFile : path1, data: buffer } );
   setTimeout( function()
   {
     wTools.fileWrite( { pathFile : path2, data: buffer } );

     var newer = wTools.filesOlder( path1, path2 );
     // 'tmp/sample/file1'
   }, 100);
   * @param {string|File.Stats} dst first file path/stat
   * @param {string|File.Stats} src second file path/stat
   * @returns {string|File.Stats}
   * @throws {Error} if type of one of arguments is not string/file.Stats
   * @method filesOlder
   * @memberof wTools
   */

var filesOlder = function( dst,src )
{
  var result = filesNewer( dst,src );

  if( result === dst )
  return src;
  else if( result === src )
  return dst;
  else
  return null;

}

//

  /**
   * Returns spectre of file content.
   * @example
   * var path = '/home/tmp/sample/file1',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path, data: textData1 } );
     var spectre = wTools.filesSpectre( path );
     //{
     //   L : 1,
     //   o : 4,
     //   r : 3,
     //   e : 5,
     //   m : 3,
     //   ' ' : 7,
     //   i : 6,
     //   p : 2,
     //   s : 4,
     //   u : 2,
     //   d : 2,
     //   l : 2,
     //   t : 5,
     //   a : 2,
     //   ',' : 1,
     //   c : 3,
     //   n : 2,
     //   g : 1,
     //   '.' : 1,
     //   length : 56
     // }
   * @param {string|wFileRecord} src absolute path or FileRecord instance
   * @returns {Object}
   * @throws {Error} If count of arguments are different from one.
   * @throws {Error} If `src` is not absolute path or FileRecord.
   * @method filesSpectre
   * @memberof wTools
   */

var filesSpectre = function( src )
{

  _.assert( arguments.length === 1, 'filesSpectre:','expect single argument' );

  src = FileRecord( src );
  var read = src.read;

  if( !read )
  read = _.fileRead
  ({
    pathFile: src.absolute,
    silent: 1,
    returnRead: 1,
  });

  return _.strLattersSpectre( read );
}

//

  /**
   * Compares specters of two files. Returns the rational number between 0 and 1. For the same specters returns 1. If
      specters do not have the same letters, method returns 0.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.';

     wTools.fileWrite( { pathFile : path1, data: textData1 } );
     wTools.fileWrite( { pathFile : path2, data: textData1 } );
     var similarity = wTools.filesSimilarity( path1, path2 ); // 1
   * @param {string} src1 path string 1
   * @param {string} src2 path string 2
   * @param {Object} [options]
   * @param {Function} [onReady]
   * @returns {number}
   * @method filesSimilarity
   * @memberof wTools
   */

var filesSimilarity = function( src1,src2,options,onReady )
{

  if( onReady ) return _.timeOut( 0, function()
  {
    onReady( filesSimilarity.call( this,options ) );
  });

  var options = options || { latters : 1 };

  //if( _.strIs( src1 ) || _.strIs( src2 ) ) throw _.err( 'filesSimilarity:','require file records' );

  src1 = FileRecord( src1 );
  src2 = FileRecord( src2 );

  //console.log( 'filesFindSame : ' + src1.relative + ' ' + src2.relative );

  if( !src1.latters ) src1.latters = _.filesSpectre( src1 );
  if( !src2.latters ) src2.latters = _.filesSpectre( src2 );

  var result = _.lattersSpectreComparison( src1.latters,src2.latters );

  return result;
}

//

  /**
   * Returns sum of sizes of files in `paths`.
   * @example
   * var path1 = 'tmp/sample/file1',
     path2 = 'tmp/sample/file2',
     textData1 = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     textData2 = 'Aenean non feugiat mauris';

     wTools.fileWrite( { pathFile : path1, data: textData1 } );
     wTools.fileWrite( { pathFile : path2, data: textData2 } );
     var size = wTools.filesSize( [ path1, path2 ] );
     console.log(size); // 81
   * @param {string|string[]} paths path to file or array of paths
   * @param {Object} [options] additional options
   * @param {Function} [options.onBegin] callback that invokes before calculation size.
   * @param {Function} [options.onEnd] callback.
   * @returns {number} size in bytes
   * @method filesSize
   * @memberof wTools
   */

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

  /**
   * Return file size in bytes. For symbolic links return false. If onEnd callback is defined, method returns instance
      of wConsequence.
   * @example
   * var path = 'tmp/fileSize/data4',
       bufferData1 = new Buffer( [ 0x01, 0x02, 0x03, 0x04 ] ), // size 4
       bufferData2 = new Buffer( [ 0x07, 0x06, 0x05 ] ); // size 3

     wTools.fileWrite( { pathFile : path, data: bufferData1 } );

     var size1 = wTools.fileSize( path );
     console.log(size1); // 4

     var con = wTools.fileSize( {
       pathFile: path,
       onEnd: function( size )
       {
         console.log( size ); // 7
       }
     } );

     wTools.fileWrite( { pathFile : path, data: bufferData2, append: 1 } );

   * @param {string|Object} options options object or path string
   * @param {string} options.pathFile path to file
   * @param {Function} [options.onBegin] callback that invokes before calculation size.
   * @param {Function} options.onEnd this callback invoked in end of current js event loop and accepts file size as
      argument.
   * @returns {number|boolean|wConsequence}
   * @throws {Error} If passed less or more than one argument.
   * @throws {Error} If passed unexpected parameter in options.
   * @throws {Error} If pathFile is not string.
   * @method fileSize
   * @memberof wTools
   */

var fileSize = function( options )
{
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

  /**
   * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
   * @example
   * var fs = require('fs');

     var path = 'tmp/fileSize/data',
     textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
     delOptions = {
       pathFile: path,
       sync: 0
     };

     wTools.fileWrite( { pathFile : path, data: textData } ); // create test file

     console.log( fs.existsSync( path ) ); // true (file exists)
     var con = wTools.fileDelete( delOptions );

     con.got( function(err)
     {
       console.log( fs.existsSync( path ) ); // false (file does not exist)
     } );
   * @param {string|Object} options options object.
   * @param {string} options.pathFile path to file/directory for deleting.
   * @param {boolean} [options.force=false] if sets to true, method remove file, or directory, even if directory has
      content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
   * @param {boolean} [options.sync=true] If set to false, method will remove file/directory asynchronously.
   * @returns {wConsequence}
   * @throws {Error} If missed argument, or pass more than 1.
   * @throws {Error} If pathFile is not string.
   * @throws {Error} If options object has unexpected property.
   * @method fileDelete
   * @memberof wTools
   */

var fileDelete = function( options )
{
  var con = new wConsequence();

  if( _.strIs( options ) )
  options = { pathFile : options };

  _.assert( arguments.length === 1 );
  _.assertMapOnly( options,fileDelete.defaults );
  _.mapComplement( options,fileDelete.defaults );
  _.assert( _.strIs( options.pathFile ) );

  if( _.files.usingReadOnly )
  return con.give();

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
      return con.error( _.err( 'cant read ' + options.pathFile ) );
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
      return con.error( _.err( 'cant read ' + options.pathFile ) );
      if( stat.isSymbolicLink() )
      throw _.err( 'not tested' );
      if( stat.isDirectory() )
      File.rmdir( options.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
      else
      File.unlink( options.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
    }
    else
    {
      File.remove( options.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
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

  /**
   * Returns array of files names if `pathFile` is directory, or array with one pathFile element if `pathFile` is not
   * directory, but exists. Otherwise returns empty array.
   * @example
   * wTools.filesList('sample/tmp');
   * @param {string} pathFile path string
   * @returns {string[]}
   * @method filesList
   * @memberof wTools
   */

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
      // +++ proposal: unificate format of result for directory and single file
      // +++ good
      files = [ _.pathName( pathFile, { withExtension: true } ) ];
      // files = [ pathFile ];
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

  /**
   * Returns true if any file from o.dst is newer than other any from o.src.
   * @example:
   * wTools.filesList( {
   *   src: [ 'foo/file1.txt', 'foo/file2.txt' ],
   *   dst: [ 'bar/file1.txt', 'bar/file2.txt' ]
   * } );
   * @param {Object} o
   * @param {string[]} o.src array of paths
   * @param {Object} [o.srcOptions]
   * @param {string[]} o.dst array of paths
   * @param {Object} [o.dstOptions]
   * @param {boolean} [o.usingLogging=true] turns on/off logging
   * @returns {boolean}
   * @throws {Error} If passed object has unexpected parameter.
   * @method filesIsUpToDate
   * @memberof wTools
   */

var filesIsUpToDate = function( o )
{

  _.assert( !o.newer || _.dateIs( o.newer ) );
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

  var srcFiles = FileRecord.prototype.fileRecordsFiltered( o.src,o.srcOptions );

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
    logger.log( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.entityMax( srcFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  var dstFiles = FileRecord.prototype.fileRecordsFiltered( o.dst,o.dstOptions );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.entityMin( dstFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /**/

  if( o.newer )
  {
    debugger;
    if( !( o.newer.getTime() <= dstOldest.stat.mtime.getTime() ) )
    return false;
  }

  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.usingLogging )
    logger.log( 'Up to date' );
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
  newer : null,
}

//

var fileHash = function( filename,onReady )
{

  var result;
  var crypto = require( 'crypto' );
  var md5sum = crypto.createHash( 'md5' );

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
// path
// --

  /**
   * Returns absolute path to file. Accepts file record object. If as argument passed string, method returns it.
   * @example
   * var pathStr = 'foo/bar/baz',
      fileRecord = FileRecord( pathStr );
     var path = wTools.pathGet( fileRecord ); // '/home/user/foo/bar/baz';
   * @param {string|wFileRecord} src file record or path string
   * @returns {string}
   * @throws {Error} If missed argument, or passed more then one.
   * @throws {Error} If type of argument is not string or wFileRecord.
   * @method pathGet
   * @memberof wTools
   */

var pathGet = function( src )
{

  _.assert( arguments.length === 1 );

  if( _.strIs( src ) )
  return src;
  else if( src instanceof wFileRecord )
  return src.absolute;
  else throw _.err( 'pathGet : unexpected type of argument : ' + _.strTypeOf( src ) );

}

//


  /**
   * Generate path string for copy of existing file passed into `o.srcPath`. If file with generated path is exists now,
   * method try to generate new path by adding numeric index into tail of path, before extension.
   * @example
   * var pathStr = 'foo/bar/baz.txt',
     var path = wTools.pathCopy( {srcPath: pathStr } ); // 'foo/bar/baz-copy.txt'
   * @param {Object} o options argument
   * @param {string} o.srcPath Path to file for create name for copy.
   * @param {string} [o.postfix='copy'] postfix for mark file copy.
   * @returns {string} path for copy.
   * @throws {Error} If missed argument, or passed more then one.
   * @throws {Error} If passed object has unexpected property.
   * @throws {Error} If file for `o.srcPath` is not exists.
   * @method pathCopy
   * @memberof wTools
   */

var pathCopy = function( o )
{

  if( !_.mapIs( o ) )
  o = { srcPath : o };

  _.assert( arguments.length === 1 );
  _.assertMapOnly( o,pathCopy.defaults );
  _.mapSupplement( o,pathCopy.defaults );

  o.srcPath = wFileRecord( o.srcPath );

  if( !File.existsSync( o.srcPath.absolute ) )
  throw _.err( 'pathCopy : original does not exit : ' + o.srcPath.absolute );

  var parts = _.strSplit({ src : o.srcPath.name, splitter : '-' });
  if( parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );

  // !!! this condition (first if below) is not necessary, because if it fulfilled then previous fulfiled too, and has the
  // same effect as previous
  if( parts.length > 1 && parts[ parts.length-1 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-1 ).join( '-' );
  else if( parts.length > 2 && parts[ parts.length-2 ] === o.postfix )
  o.srcPath.name = parts.slice( 0,parts.length-2 ).join( '-' );

  /*o.srcPath.absolute =  o.srcPath.dir + '/' + o.srcPath.name + o.srcPath.extWithDot;*/

  var path = o.srcPath.dir + '/' + o.srcPath.name + '-' + o.postfix + o.srcPath.extWithDot;
  if( !File.existsSync( path ) )
  return path;

  var attempts = 1 << 13;
  var index = 1;

  // while( attempts > 0 )
  while( attempts-- )
  {

    var path = o.srcPath.dir + '/' + o.srcPath.name + '-' + o.postfix + '-' + index + o.srcPath.extWithDot;

    if( !File.existsSync( path ) )
    return path;

    // attempts -= 1;
    index += 1;

  }

  throw _.err( 'pathCopy : cant make copy path for : ' + o.srcPath.absolute );
}

pathCopy.defaults =
{
  postfix : 'copy',
  srcPath : null,
}

//

  /**
   * Normalize a path by collapsing redundant separators and  resolving '..' and '.' segments, so A//B, A/./B and
      A/foo/../B all become A/B. This string manipulation may change the meaning of a path that contains symbolic links.
      On Windows, it converts forward slashes to backward slashes. If the path is an empty string, method returns '.'
      representing the current working directory.
   * @example
     var path = '/foo/bar//baz1/baz2//some/..'
     path = wTools.pathNormalize( path ); // /foo/bar/baz1/baz2
   * @param {string} src path for normalization
   * @returns {string}
   * @method pathNormalize
   * @memberof wTools
   */

  var pathNormalize = function( src )
{
  var result = Path.normalize( src ).replace( /\\/g,'/' );
  return result;
}

//

  /**
   * Returns a relative path to `path` from an `relative` path. This is a path computation: the filesystem is not
     accessed to confirm the existence or nature of path or start. As second argument method can accept array of paths,
     in this case method returns array of appropriate relative paths. If `relative` and `path` each resolve to the same
     path method returns '.'.
   * @example
   * var pathFrom = '/foo/bar/baz',
     pathsTo =
     [
       '/foo/bar',
       '/foo/bar/baz/dir1',
     ],
     relatives = wTools.pathRelative( pathFrom, pathsTo ); //  [ '..', 'dir1' ]
   * @param {string|wFileRecord} relative start path
   * @param {string|string[]} path path to.
   * @returns {string|string[]}
   * @method pathRelative
   * @memberof wTools
   */

var pathRelative = function( relative,path )
{

  var relative = _.pathGet( relative );

  _.assert( arguments.length === 2 );
  _.assert( _.strIs( relative ) );
  _.assert( _.strIs( path ) || _.arrayIs( path ) );

  if( _.arrayIs( path ) )
  {
    var result = [];
    for( var p = 0 ; p < path.length ; p++ )
    result[ p ] = _.pathRelative( relative,path [p ] );
    return result;
  }

  var result = Path.relative( relative,path );
  result = _.pathNormalize( result );

  return result;
}

//

  /**
   * Method resolves a sequence of paths or path segments into an absolute path.
   * The given sequence of paths is processed from right to left, with each subsequent path prepended until an absolute
   * path is constructed. If after processing all given path segments an absolute path has not yet been generated,
   * the current working directory is used.
   * @example
   * var absPath = wTools.pathResolve('work/wFiles'); // '/home/user/work/wFiles';
   * @param [...string] paths A sequence of paths or path segments
   * @returns {string}
   * @method pathResolve
   * @memberof wTools
   */

var pathResolve = function()
{

  var result = Path.resolve.apply( this,arguments );
  result = _.pathNormalize( result );

  return result;
}

//

  /**
   * Checks if string is correct possible for current OS path and represent file/directory that is safe for modification
   * (not hidden for example).
   * @param pathFile
   * @returns {boolean}
   * @method pathIsSafe
   * @memberof wTools
   */

var pathIsSafe = function( pathFile )
{
  var safe = true;

  _.assert( _.strIs( pathFile ) );

  // +++ bad idea :)
  safe = safe && !/(^|\/)\.(?!$|\/)/.test( pathFile );

/*
  // +++ in UNIX file system the path that contain '/.*' is valid
  if ( Os.type() === 'Linux' || Os.type() === 'Darwin' )
  {
    safe = safe && /^(\/[^/ ]*)+\/?$/.test( pathFile );
  }
  else
  {
    safe = safe && !/(^|\/)\.(?!$|\/)/.test( pathFile );
  }
*/

  if( safe )
  safe = pathFile.length > 8 || ( pathFile[ 0 ] !== '/' && pathFile[ 1 ] !== ':' );

  return safe;
}

//

  /**
   * Creates RegexpObject based on passed path, array of paths, or RegexpObject.
     Paths turns into regexps and adds to 'includeAny' property of result Object.
     Methods adds to 'excludeAny' property the next paths by default:
     'node_modules',
     '.unique',
     '.git',
     '.svn',
     /(^|\/)\.(?!$|\/)/, // any hidden paths
     /(^|\/)-(?!$|\/)/,
   * @example:
   * var paths =
      {
        includeAny: [ 'foo/bar', 'foo2/bar2/baz', 'some.txt' ],
        includeAll: [ 'index.js' ],
        excludeAny: [ 'Gruntfile.js', 'gulpfile.js' ],
        excludeAll: [ 'package.json', 'bower.json' ]
      };
     var regObj = pathRegexpSafeShrink( paths );
   //  {
   //    includeAny:
   //      [
   //        /foo\/bar/,
   //        /foo2\/bar2\/baz/,
   //        /some\.txt/
   //      ],
   //    includeAll:
   //      [
   //        /index\.js/
   //      ],
   //    excludeAny:
   //      [
   //        /Gruntfile\.js/,
   //        /gulpfile\.js/,
   //        /node_modules/,
   //        /\.unique/,
   //        /\.git/,
   //        /\.svn/,
   //        /(^|\/)\.(?!$|\/)/,
   //        /(^|\/)-(?!$|\/)/
   //      ],
   //    excludeAll: [ /package\.json/, /bower\.json/ ]
   //  }
   * @param {string|string[]|RegexpObject} [maskAnyFile]
   * @returns {RegexpObject}
   * @throws {Error} if passed more than one argument.
   * @see {@link wTools~RegexpObject} RegexpObject
   * @method pathRegexpSafeShrink
   * @memberof wTools
   */

var pathRegexpSafeShrink = function( maskAnyFile )
{

  _.assert( arguments.length === 0 || arguments.length === 1 );

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
      /(^|\/)-(?!$|\/)/,
      // /\.\/file($|\/)/,
    ],
  });

  maskAnyFile = _.regexpObjectShrink( maskAnyFile,excludeMask );

  return maskAnyFile;
}

//


  /**
   * Returns path for main module (module that running directly by node).
   * @returns {string}
   * @method pathMainFile
   * @memberof wTool
   */

var _pathMainFile;
var pathMainFile = function()
{
  if( _pathMainFile ) return _pathMainFile;
  _pathMainFile = _.pathNormalize( require.main.filename );
  return _pathMainFile;
}

//

  /**
   * Returns path dir name for main module (module that running directly by node).
   * @returns {string}
   * @method pathMainDir
   * @memberof wTool
   */

var _pathMainDir;
var pathMainDir = function()
{
  if( _pathMainDir ) return _pathMainDir;
  _pathMainDir = _.pathNormalize( Path.dirname( require.main.filename ) );
  return _pathMainDir;
}

//

  /**
   * Returns absolute path for file running directly by node
   * @returns {string}
   * @throws {Error} If passed any argument.
   * @method pathBaseFile
   * @memberof wTool
   */

var pathBaseFile = function pathBaseFile()
{

  var result = '';

  return function pathBaseFile()
  {
    _.assert( arguments.length === 0 );

    if( result )
    return result;

    if( process.argv[ 1 ] )
    result = _.pathNormalize( Path.resolve( process.argv[ 1 ] ) );

    if( !File.existsSync( result ) )
    {
      throw _.err( 'not tested' );
      result = _.pathMainFile();
    }

    return result;
  }

}();

//

  /**
   * Returns path dirname for file running directly by node
   * @returns {string}
   * @throws {Error} If passed any argument.
   * @method pathBaseFile
   * @memberof wTool
   */

var pathBaseDir = function()
{
  _.assert( arguments.length === 0 );

  var result = _.pathDir( pathBaseFile() );

  return result;
}

//

  /**
   * Returns the current working directory of the Node.js process. If as argument passed path to existing directory,
     method sets current working directory to it. If passed path is an existing file, method set its parent directory
     as current working directory.
   * @param {string} [path] path to set current working directory.
   * @returns {string}
   * @throws {Error} If passed more than one argument.
   * @throws {Error} If passed path to not exist directory.
   * @method pathCurrent
   * @memberof wTool
   */

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


  /**
   * Returns `home` directory. On depend from OS it's will be value of 'HOME' for posix systems or 'USERPROFILE'
   * for windows environment variables.
   * @returns {string}
   * @method pathHome
   * @memberof wTool
   */

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

  // find

  _filesOptions: _filesOptions,
  _filesMaskAdjust: _filesMaskAdjust,

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
  /*fileHardlink: fileHardlink,*/

  filesNewer: filesNewer,
  filesOlder: filesOlder,

  filesSpectre: filesSpectre,
  filesSimilarity: filesSimilarity,

  filesSize: filesSize,
  fileSize: fileSize,

  fileDelete: fileDelete,

  filesList: filesList,
  filesIsUpToDate: filesIsUpToDate,

  fileHash: fileHash,
  filesShadow: filesShadow,


  // path

  pathGet: pathGet,
  pathCopy: pathCopy,

  /*urlNormalize: urlNormalize,*/

  pathNormalize: pathNormalize,
  pathRelative: pathRelative,
  pathResolve: pathResolve,

  pathIsSafe: pathIsSafe,
  pathRegexpSafeShrink: pathRegexpSafeShrink,

  pathMainFile: pathMainFile,
  pathMainDir: pathMainDir,

  pathBaseFile: pathBaseFile,
  pathBaseDir: pathBaseDir,

  pathCurrent: pathCurrent,
  pathHome: pathHome,

}

_.mapExtend( Self,Proto );

Self.fileProvider = _.mapExtend( Self.fileProvider || {},fileProvider );
Self.files = _.mapExtend( Self.files || {},Proto );
Self.files.usingReadOnly = 0;

//

_.pathBaseFile();

//

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

})();
