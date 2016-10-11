( function _AdvancedMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( './FileBase.s' );
  if( !wTools.FileRecord )
  require( './FileRecord.s' );
  require( './Abstract.s' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var DefaultsFor = _.FileProvider.Abstract.DefaultsFor;

//

var mixin = function( constructor )
{

  var dst = constructor.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( constructor ) );

  _.mixin
  ({
    dst : dst,
    mixin : Self,
  });

}

// --
// find
// --

var _filesOptions = function _filesOptions( pathFile,maskTerminal,options )
{

  _.assert( arguments.length === 3 );

  if( _.objectIs( pathFile ) )
  {
    options = pathFile;
    pathFile = options.pathFile;
    maskTerminal = options.maskTerminal;
  }

  options = options || {};
  options.maskTerminal = maskTerminal;
  options.pathFile = pathFile;

  return options;
}

//

var _filesMaskAdjust = function _filesMaskAdjust( options )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( options ) );
  /*_.assertMapHasOnly( _filesMaskAdjust.defaults );*/

  options.maskAll = _.regexpMakeObject( options.maskAll || {},'includeAny' );
  options.maskTerminal = _.regexpMakeObject( options.maskTerminal || {},'includeAny' );
  options.maskDir = _.regexpMakeObject( options.maskDir || {},'includeAny' );

/*
  if( options.hasExtension )
  {
    // /(^|\/)\.(?!$|\/)/,
    _.assert( _.strIs( options.hasExtension ) );
    options.hasExtension = new RegExp( '^' + _.regexpEscape( options.hasExtension ) ); xxx
    _.RegexpObject.shrink( options.maskTerminal,{ includeAll : options.hasExtension } );
    delete options.hasExtension;
  }
*/

  if( options.begins )
  {
    _.assert( _.strIs( options.begins ) );
    options.begins = new RegExp( '^' + _.regexpEscape( options.begins ) );
    options.maskTerminal = _.RegexpObject.shrink( options.maskTerminal,{ includeAll : options.begins } );
    delete options.begins;
  }

  if( options.ends )
  {
    _.assert( _.strIs( options.ends ) );
    options.ends = new RegExp( _.regexpEscape( options.ends ) + '$' );
    options.maskTerminal = _.RegexpObject.shrink( options.maskTerminal,{ includeAll : options.ends } );
    delete options.ends;
  }

  if( options.glob )
  {
    _.assert( _.strIs( options.glob ) );
    var globRegexp = _.regexpForGlob( options.glob );
    options.maskTerminal = _.RegexpObject.shrink( options.maskTerminal,{ includeAll : globRegexp } );
    delete options.glob;
  }

  return options;
}

_filesMaskAdjust.defaults =
{

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  begins : null,
  ends : null,
  glob : null,

}

//

var filesFind = function()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  // if( arguments[ 3 ] ) return _.timeOut( 0, function()
  // {
  //   arguments[ 3 ]( filesFind( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  // });

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _.assertMapHasOnly( o,filesFind.defaults );
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
  var orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );

  //

  // logger.log( 'filesFind' );
  // logger.log( _.toStr( o,{ levels : 4 } ) );
  // debugger;

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

    var files = self.directoryRead( pathFile );

    if( self.fileIsTerminal( o.pathFile ) )
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

  var ordering = function( paths,o )
  {

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ),'expects string or array' );

    for( var p = 0 ; p < paths.length ; p++ )
    {
      var pathFile = paths[ p ];

      _.assert( _.strIs( pathFile ),'expects string got ' + _.strTypeOf( pathFile ) );

      if( pathFile[ pathFile.length-1 ] === '/' )
      pathFile = pathFile.substr( 0,pathFile.length-1 );

      o.pathFile = pathFile;

      if( relative === undefined || relative === null )
      o.relative = pathFile;

      if( o.ignoreNonexistent )
      if( !self.fileStat( pathFile ) )
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
    var maskTerminal = o.maskTerminal;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      o.maskTerminal = _.RegexpObject.shrink( {},maskTerminal,orderingExclusion[ e ] );
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

  if( o.usingTiming )
  logger.log( _.timeSpent( 'Spent to find at ' + o.pathFile + ' found ' + result.length,time ) );

  /**/
/*
  logger.log( 'filesFind result.length : ' + result.length );

  if( Config.debug && 1 )
  _.assert( _.arrayCountSame( result,function( e ){ return e.absolute } ) === 0,'filesFind result should not have duplicates' );

  logger.log( 'filesFind result.length : ' + result.length );
*/

  /**/

  //logger.log( 'filesFind done' );

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

var filesFindDifference = function( dst,src,o,onReady )
{

  // if( onReady ) return _.timeOut( 0, function()
  // {
  //   onReady( filesFindDifference.call( this,dst,src,o ) );
  // });

  /* options */

  if( _.objectIs( dst ) )
  {
    o = dst;
    dst = o.dst;
    src = o.src;
  }

  var self = this;
  var o = ( o || {} );
  o.dst = dst;
  o.src = src;

  _.assert( arguments.length === 1 || arguments.length === 3 );
  _.assertMapHasOnly( o,filesFindDifference.defaults );
  _.mapComplement( o,filesFindDifference.defaults );
  _filesMaskAdjust( o );
  _.strIs( o.dst );
  _.strIs( o.src );

  var ext = o.ext;
  var result = o.result = o.result || [];

  if( o.read !== undefined || o.hash !== undefined || o.latters !== undefined )
  throw _.err( 'filesFind :','o are deprecated',_.toStr( o ) );

  /* */

  var _filesAddResultFor = function( o )
  {
    var addResult;

    if( o.outputFormat === 'absolute' )
    addResult = function( record )
    {
      o.result.push([ record.src.absolute,record.dst.absolute ]);
    }
    else if( o.outputFormat === 'relative' )
    addResult = function( record )
    {
      o.result.push([ record.src.relative,record.dst.relative ]);
    }
    else if( o.outputFormat === 'record' )
    addResult = function( record )
    {
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    addResult = function( record )
    {
    }
    else throw _.err( 'unexpected output format :',o.outputFormat );

    return addResult;
  }

  var addResult = _filesAddResultFor( o );

  /* safety */

  o.dst = _.pathNormalize( o.dst );
  o.src = _.pathNormalize( o.src );

  if( o.src !== o.dst && _.strBegins( o.src,o.dst ) )
  {
    debugger;
    throw _.err( 'overwrite of itself','\nsrc :',o.src,'\ndst :',o.dst )
  }

  if( o.src !== o.dst && _.strBegins( o.dst,o.src ) )
  {
    var exclude = '^' + o.dst.substr( o.src.length+1 ) + '($|\/)';
    _.RegexpObject.shrink( o.maskAll,{ excludeAny : new RegExp( exclude ) } );
  }

  /* dst */

  var dstOptions = _.mapScreen( wFileRecord.prototype._fileRecord.defaults,o );
  dstOptions.dir = dst;
  dstOptions.relative = dst;

  /* src */

  var srcOptions = _.mapScreen( wFileRecord.prototype._fileRecord.defaults,o );
  srcOptions.dir = src;
  srcOptions.relative = src;

  /* diagnostic */

  // logger.log( 'filesFindDifference' );
  // logger.log( _.toStr( o,{ levels : 4 } ) );
  // debugger;

  /* src file */

  var srcFile = function srcFile( dstOptions,srcOptions,file )
  {

    var srcRecord = FileRecord( file,_.mapScreen( wFileRecord.prototype._fileRecord.defaults,srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    var dstRecord = FileRecord( file,_.mapScreen( wFileRecord.prototype._fileRecord.defaults,dstOptions ) );
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
      if( srcRecord.stat.size > o.maxSize )
      srcRecord.hash = NaN;

      if( dstRecord.hash === undefined )
      if( dstRecord.stat.size > o.maxSize )
      dstRecord.hash = NaN;

      if( !dstRecord.isDirectory )
      {
        record.same = self.filesSame( dstRecord, srcRecord, o.usingTiming );
        record.link = self.filesLinked( dstRecord, srcRecord );
      }
      else
      {
        record.same = false;
        record.link = false;
      }

      record.newer = _.filesNewer( dstRecord, srcRecord );
      record.older = _.filesOlder( dstRecord, srcRecord );

    }

    _.routinesCall( o,o.onUp,[ record ] );
    addResult( record );
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* src directory */

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

    /**/

    if( o.includeDirectories )
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

      _.routinesCall( o,o.onUp,[ record ] );
      addResult( record );

    }

    if( o.recursive && recursive )
    {
      var dstOptionsSub = _.mapExtend( {},dstOptions );
      dstOptionsSub.dir = dstRecord.absolute;
      var srcOptionsSub = _.mapExtend( {},srcOptions );
      srcOptionsSub.dir = srcRecord.absolute;
      filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
    }

    if( o.includeDirectories )
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* dst file */

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

    _.routinesCall( o,o.onUp,[ record ] );
    addResult( record );
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* dst directory */

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

    if( o.includeDirectories && ( !srcRecord.inclusion || !srcRecord.stat ) )
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

      _.routinesCall( o,o.onUp,[ record ] );
      addResult( record );

    }

    if( o.recursive && recursive )
    {

      var found = self.filesFind
      ({
        includeDirectories : o.includeDirectories,
        includeFiles : o.includeFiles,
        pathFile : dstRecord.absolute,
        outputFormat : o.outputFormat,
        recursive : 1,
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
        _.routinesCall( o,o.onUp,[ rec ] );
        addResult( rec );
      }

      if( o.onDown.length )
      for( var fo = found.length-1 ; fo >= 0 ; fo-- )
      {
        _.routinesCall( o,o.onDown,[ found[ fo ] ] );
      }

    }

    if( record )
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* act */

  var filesFindDifferenceAct = function filesFindDifferenceAct( dstOptions,srcOptions )
  {

    /* dst */

    var dstRecord = FileRecord( dstOptions.dir,dstOptions );
    if( o.investigateDestination )
    if( dstRecord.stat && dstRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( dstRecord.real );

      if( o.includeFiles )
      for( var f = 0 ; f < files.length ; f++ )
      dstFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      dstDir( dstOptions,srcOptions,files[ f ],1 );

    }

    /* src */

    var srcRecord = FileRecord( srcOptions.dir,srcOptions );
    if( srcRecord.stat && srcRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( srcRecord.real );

      if( o.includeFiles )
      for( var f = 0 ; f < files.length ; f++ )
      srcFile( dstOptions,srcOptions,files[ f ] );

      for( var f = 0 ; f < files.length ; f++ )
      srcDir( dstOptions,srcOptions,files[ f ],1 );

    }

  }

  /* launch */

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
  usingResolvingLink : 0,
  usingResolvingTextLink : 0,

  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

filesFindDifference.defaults.__proto__ = _filesMaskAdjust.defaults

//

var filesFindSame = function filesFindSame()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  // if( arguments[ 3 ] ) return _.timeOut( 0, function()
  // {
  //   arguments[ 3 ]( filesFindSame( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  // });

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _filesMaskAdjust( o );

  _.routineOptions( filesFindSame,o );

  if( !o.pathFile )
  throw _.err( 'filesFindSame :','expects "pathFile"' );

  /* output format */

  o.outputFormat = 'record';

  /* result */

  var result = o.result;
  _.assert( _.objectIs( result ) );

  if( !result.sameContent && o.usingContentComparing ) result.sameContent = [];
  if( !result.sameName && o.usingSameNameCollecting ) result.sameName = [];
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
  result.unique = self.filesFind( findOptions );

  /* adjust found */

  for( var f1 = 0 ; f1 < result.unique.length ; f1++ )
  {

    var file1 = result.unique[ f1 ];

    if( !file1.stat )
    {
      console.warn( 'WARN : cant read : ' + file1.absolute );
      continue;
    }

    if( o.usingContentComparing )
    if( file1.hash === undefined )
    {
      if( file1.stat.size > o.maxSize )
      file1.hash = NaN;
    }

  }

  /* link */

  var checkLink = function()
  {

    if( self.filesLinked( file1,file2 ) )
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

    // if( file1.absolute.indexOf( 'NameTools.s' ) !== -1 && file2.absolute.indexOf( 'NameTools.s' ) !== -1 )
    // debugger;

    var same = false;
    if( o.usingContentComparing )
    same = self.filesSame( file1,file2,o.usingTiming );
    if( same )
    {

      if( o.usingTakingNameIntoAccountComparingContent && file1.file !== file2.file )
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
      var similarity = _.filesSimilarity({ src1 : file1, src2 : file2 });
      if( similarity >= o.similarity )
      {
        /*var similarity = _.filesSimilarity({ src1 : file1, src2 : file2 });*/
        result.similar.push({ files : [ file1,file2 ], similarity : similarity });
        return true;
      }
    }

    return false;
  }

  /* name */

  var checkName = function()
  {

    if( o.usingSameNameCollecting )
    if( file1.file === file2.file && !file2._haveSameName )
    {
      file2._haveSameName = 1;
      sameNameRecord.push( file2 );
      return true;
    }

    return false;
  }

  /* compare */

  var sameNameRecord, sameContentRecord, linkedRecord;
  for( var f1 = 0 ; f1 < result.unique.length ; f1++ )
  {

    var file1 = result.unique[ f1 ];

    if( !file1.stat )
    continue;

    sameNameRecord = [ file1 ];
    sameContentRecord = [ file1 ];
    linkedRecord = [ file1 ];

    for( var f2 = f1 + 1 ; f2 < result.unique.length ; f2++ )
    {

      var file2 = result.unique[ f2 ];

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
      if( !o.usingFast )
      _.assert( _.arrayCountSame( linkedRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in linkedRecord' );
      result.linked.push( linkedRecord );
    }

    if( sameContentRecord && sameContentRecord.length > 1  )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountSame( sameContentRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameContentRecord' );
      result.sameContent.push( sameContentRecord );
    }

    if( sameNameRecord && sameNameRecord.length > 1 )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountSame( sameNameRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameNameRecord' );
      result.sameName.push( sameNameRecord );
    }

  }

  /* output format */

  if( o.outputFormat !== 'record' )
  throw _.err( 'not tested' );

  if( o.outputFormat !== 'record' )
  for( var r in result )
  {
    if( r === 'unique' )
    result[ r ] = _.entitySelect( result[ r ],'*.' + o.outputFormat );
    else
    result[ r ] = _.entitySelect( result[ r ],'*.*.' + o.outputFormat );
  }

  /* validation */

  _.accessorForbid( result,{ same : 'same' } );

  /* timing */

  if( o.usingTiming )
  logger.log( _.timeSpent( 'Spent to find same at ' + o.pathFile,time ) );

  return result;
}

filesFindSame.defaults =
{

  maxSize : 1 << 22,
  lattersFileSizeLimit : 1048576,
  similarity : 0,

  usingFast : 1,
  usingContentComparing : 1,
  usingTakingNameIntoAccountComparingContent : 1,
  usingLinkedCollecting : 0,
  usingSameNameCollecting : 0,

  usingTiming : 0,

  result : {},

}

filesFindSame.defaults.__proto__ = filesFind.defaults;

//

var filesGlob = function( o )
{
  var self = this;

  if( o.glob === undefined )
  o.glob = '*';

  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.glob ) );

  if( o.pathFile === undefined )
  {
    var i = o.glob.search( /[^\\\/]*?(\*\*|\?|\*)[^\\\/]*/ );
    if( i === -1 )
    o.pathFile = o.glob;
    else o.pathFile = o.glob.substr( 0,i );
    if( !o.pathFile )
    o.pathFile = _.pathMainDir();
  }

  if( o.relative === undefined )
  o.relative = o.pathFile;

  var relative = _.strAppendOnce( o.relative,'/' );
  if( _.strBegins( o.glob,relative ) )
  o.glob = o.glob.substr( relative.length,o.glob.length );
  else
  {
    debugger;
    logger.log( 'strBegins :', _.strBegins( o.glob,relative ) );
    throw _.err( 'not tested' );
  }

  if( o.outputFormat === undefined )
  o.outputFormat = 'absolute';

  if( o.recursive === undefined )
  o.recursive = 1;

  var result = self.filesFind( o );

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

var filesCopy = function( options )
{
  var self = this;

  _.assert( arguments.length === 1 );

  // if( onReady ) return _.timeOut( 0, function()
  // {
  //   onReady( filesCopy.call( this,options ) );
  // });

  var options = options || {};

  if( !options.allowDelete && options.investigateDestination === undefined )
  options.investigateDestination = 0;

  if( options.allowRewrite && options.allowWrite === undefined )
  options.allowWrite = 1;

  if( options.allowRewrite && options.allowRewriteFileByDir === undefined  )
  options.allowRewriteFileByDir = true;

  //if( options.allowRewrite )
  //_.assert( options.allowWrite,'allowRewrite without allowWrite is useless' );

  _.assertMapHasOnly( options,filesCopy.defaults );
  _.mapComplement( options,filesCopy.defaults );

  var includeDirectories = options.includeDirectories !== undefined ? options.includeDirectories : 1;
  var onUp = _.arrayAs( options.onUp );
  var onDown = _.arrayAs( options.onDown );
  var directories = {};

  // safe

  if( options.safe )
  if( options.removeSource && ( !options.allowWrite || !options.allowRewrite ) )
  throw _.err( 'not safe removeSource :1 with allowWrite :0 or allowRewrite :0' );

  // make dir

  var dirname = _.pathDir( options.dst );

  if( options.safe )
  if( !_.pathIsSafe( dirname ) )
  throw _.err( dirname,'Unsafe to use :',dirname );

  var recordDir = new wFileRecord( dirname );
  //var rewriteDir = !_.directoryIs( dirname ) && File.existsSync( dirname );
  var rewriteDir = recordDir.stat && !recordDir.stat.isDirectory();
  if( rewriteDir )
  if( options.allowRewrite )
  {

    debugger;
    throw _.err( 'not tested' );
    if( options.usingLogging )
    logger.log( '- rewritten file by directory :',dirname );
    self.fileDelete({ pathFile : pathFile, force : 0 });
    self.directoryMake({ pathFile : dirname, force : 1 });

  }
  else
  {
    throw _.err( 'cant rewrite',dirname );
  }

  // on up

  var handleUp = function( record )
  {

    //

    if( /include($|\/)/.test( record.src.absolute ) )
    debugger

    // same

    if( options.tryingPreserve )
    if( record.same && record.link == options.usingLinking )
    {
      record.action = 'same';
      record.allowed = true;
    }

    // delete redundant

    if( record.del )
    {

      if( record.dst && record.dst.stat )
      {
        if( options.allowDelete )
        {
          record.action = 'deleted';
          record.allowed = true;

        }
        else
        {
          record.action = 'deleted';
          record.allowed = false;

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
        directories[ record.dst.absolute ] = true;
        record.action = 'directory preserved';
        record.allowed = true;
        if( options.preserveTime )
        self.fileTimeSet( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
      }

    }

    // rewrite

    if( !record.action )
    {

      var rewriteFile = !!record.dst.stat;

      if( rewriteFile )
      {

        if( !options.allowRewriteFileByDir && record.src.stat && record.src.stat.isDirectory() )
        rewriteFile = false;

        if( rewriteFile && options.allowRewrite && options.allowWrite )
        {
          rewriteFile = record.dst.absolute + '.' + _.idGenerateDate() + '.back' ;
          self.fileRenameAct( rewriteFile,record.dst.absolute );
          delete record.dst.stat;
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

      directories[ record.dst.absolute ] = true;
      record.action = 'directory new';
      record.allowed = false;
      if( options.allowWrite )
      {
        self.directoryMake({ pathFile : record.dst.absolute, force : 1 });
        if( options.preserveTime )
        self.fileTimeSet( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        record.allowed = true;
      }

    }

    // unknown

    if( !record.action && record.src.stat && !record.src.stat.isFile() )
    {
      //debugger;
      throw _.err( 'unknown kind of source : it is unsafe to proceed :\n' + _.fileReport( record.src ) + '\n' );
    }

    // is write possible

    if( !record.action )
    {

      if( !directories[ record.dst.dir ] )
      {
        record.action = 'cant rewrite';
        record.allowed = false;
        return;
      }

    }

    // write

    if( !record.action )
    {

      if( options.usingLinking )
      {

        record.action = 'linked';
        record.allowed = false;

        if( options.allowWrite )
        {
          record.allowed = true;
          if( options.usingLogging )
          logger.log( '+ ' + record.action + ' :',record.dst.absolute );
          self.linkHardAct( record.dst.absolute,record.src.real );
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
          //File.copySync( record.src.real,record.dst.absolute ); xxx
          self.fileCopyAct( record.dst.absolute,record.src.real );
          if( options.preserveTime )
          self.fileTimeSet( record.dst.absolute, record.src.stat.atime, record.src.stat.mtime );
        }

      }

    }

    // rewrite

    if( rewriteFile && options.allowRewrite )
    {
      self.fileDelete
      ({
        pathFile : rewriteFile,
        force : 1,
      });
    }

    // callback

    if( !includeDirectories && record.src.stat && record.src.stat.isDirectory() )
    return false;

    _.routinesCall( options,onUp,[ record ] );

  }

  // on down

  var handleDown = function( record )
  {

    if( record.action === 'linked' && record.del )
    throw _.err( 'unexpected' );

    // delete redundant

    if( record.action === 'deleted' )
    {
      if( record.allowed )
      {
        if( options.usingLogging )
        logger.log( '- deleted :',record.dst.absolute );
        self.fileDelete({ pathFile : record.dst.absolute, force : 1 });
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
      logger.log( '- removed-source :',record.src.real );
      self.fileDelete( record.src.real );
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
    var records = self.filesFindDifference( options.dst,options.src,findOptions );

    if( options.usingLogging )
    if( !records.length && options.outputFormat !== 'nothing' )
    logger.log( '? copy :', 'nothing was copied :',options.dst,'<-',options.src );

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
  usingResolvingLink : 0,
  usingResolvingTextLink : 0,

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
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  // if( arguments[ 3 ] ) return _.timeOut( 0, function()
  // {
  //   arguments[ 3 ]( filesFindSame( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] ) );
  // });

  var options = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

  //

  options.outputFormat = 'absolute';

  _.mapComplement( options,filesDelete.defaults );

  //

  var o = _.mapBut( options,filesDelete.defaults );
  var files = self.filesFind( o );

  for( var f = 0 ; f < files.length ; f++ ) try
  {
    if( options.usingLogging )
    logger.log( '- deleted :',files[ f ] )
    //File.removeSync( files[ f ] );
    self.fileDelete({ pathFile : files[ f ], force : 1 });

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
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var options = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

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
        logger.log( '- deleted :',record.absolute )
        //File.removeSync( record.absolute );
        self.fileDelete({ pathFile : record.absolute, force : 1 });
      }
    }
    catch( err )
    {
      if( !options.silent )
      throw _.err( err );
    }

  });

  var files = self.filesFind( o );

  return new wConsequence().give();
}

filesDeleteEmptyDirs.defaults =
{
  silent : false,
  usingLogging : false,
}

//

var filesResolve = function( options )
{
  var self = this;
  var result = [];

  _.assertMapHasOnly( options,filesResolve.defaults );
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

  var globOptions = _.mapScreen( self.filesGlob.defaults,options );
  globOptions.glob = glob;
  globOptions.relative = options.pathOutputRoot;
  globOptions.outputFormat = options.outputFormat;

  _.assert( self );
  var result = self.filesGlob( globOptions );

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
// tree
// --

var filesTreeWrite = function( o )
{
  var self = this;

  _.routineOptions( filesTreeWrite,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

  if( o.usingLogging )
  logger.log( 'filesTreeWrite to ' + o.pathFile );

  //

  var stat = null;
  var handleWritten = function( pathFile )
  {
    if( !o.allowWrite )
    return;
    if( !o.sameTime )
    return;
    if( !stat )
    stat = self.fileStat( pathFile );
    else
    self.fileTimeSet( pathFile, stat.atime, stat.mtime );
  }

  //

  var write = function( pathFile,tree )
  {

    _.assert( _.strIs( pathFile ) );
    _.assert( _.strIs( tree ) || _.objectIs( tree ) || _.arrayIs( tree ) );

    //var exists = File.existsSync( pathFile );
    var exists = self.fileStat( pathFile );
    if( o.allowDelete && exists )
    {
      self.fileDelete({ pathFile : pathFile, force : 1 });
      //File.removeSync( pathFile );
      exists = false;
    }

    if( _.strIs( tree ) )
    {
      if( o.allowWrite && !exists )
      self.fileWrite( pathFile,tree );
      handleWritten( pathFile );
    }
    else if( _.objectIs( tree ) )
    {
      if( o.allowWrite && !exists )
      self.directoryMake({ pathFile : pathFile, force : 1 });
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
        if( o.absolutePathForLink || tree.absolute )
        if( !tree.relative )
        pathTarget = _.pathResolve( _.pathJoin( pathFile,'..',tree.softlink ) );
        self.linkSoftAct( pathFile,pathTarget );
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
  usingLogging : 0,
}

//

/** usage

    var treeWriten = _.filesTreeRead
    ({
      pathFile : dir,
      readTerminals : 0,
    });

    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );

*/

var filesTreeRead = function( o )
{
  var self = this;
  var result = {};

  if( _.strIs( o ) )
  o = { pathFile : o };

  _.routineOptions( filesTreeRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.pathFile ) );

  o.outputFormat = 'record';

  if( o.usingLogging )
  logger.log( 'filesTreeRead from ' + o.pathFile );

  /* */

  o.onUp = _.arrayPrependMerging( _.arrayAs( o.onUp ), function( record )
  {
    var data = {};

    if( !record.stat.isDirectory() )
    if( o.readTerminals )
    data = self.fileReadSync( record.absolute );
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

  /* */

  var found = self.filesFind( _.mapScreen( self.filesFind.defaults,o ) );

  return result;
}

filesTreeRead.defaults =
{
  readTerminals : 1,
  recursive : 1,
  includeFiles : 1,
  includeDirectories : 1,
  safe : 0,
  outputFormat : 'nothing',
  usingLogging : 0,
}

filesTreeRead.defaults.__proto__ = filesFind.defaults;

//

/**
 * Reads a JSON file and then parses it into an object.
 *
 * @example
 * // content of tmp/json1.json : {"a" :1,"b" :"s","c" :[1,3,4]}
 *
 * var res = wTools.fileReadJson( 'tmp/json1.json' );
 * // { a : 1, b : 's', c : [ 1, 3, 4 ] }
 * @param {string} pathFile file path
 * @returns {*}
 * @throws {Error} If missed arguments, or passed more then one argument.
 * @method fileReadJson
 * @memberof wTools
 */

var fileReadJson = function( pathFile )
{
  var self = this;
  var result = null;
  var pathFile = _.pathGet( pathFile );

  _.assert( arguments.length === 1 ); //debugger; xxx

  //if( File.existsSync( pathFile ) )
  if( self.fileStat( pathFile ) )
  {

    try
    {
      var str = self.fileRead
      ({
        pathFile : pathFile,
        encoding : 'utf8',
        sync : 1,
        returnRead : 1,
      });
      result = JSON.parse( str );
    }
    catch( err )
    {
      throw _.err( 'cant read json from',pathFile,'\n',err );
    }

  }

  return result;
}

//

//
//
// /**
//  * Delete file of directory. Accepts path string or options object. Returns wConsequence instance.
//  * @example
//  * var fs = require('fs');
//
//    var path = 'tmp/fileSize/data',
//    textData = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
//    delOptions = {
//      pathFile : path,
//      sync : 0
//    };
//
//    wTools.fileWrite( { pathFile : path, data : textData } ); // create test file
//
//    console.log( fs.existsSync( path ) ); // true (file exists)
//    var con = wTools.fileDelete( delOptions );
//
//    con.got( function(err)
//    {
//      console.log( fs.existsSync( path ) ); // false (file does not exist)
//    } );
//  * @param {string|Object} o - options object.
//  * @param {string} o.pathFile path to file/directory for deleting.
//  * @param {boolean} [o.force=false] if sets to true, method remove file, or directory, even if directory has
//     content. Else when directory to remove is not empty, wConsequence returned by method, will rejected with error.
//  * @param {boolean} [o.sync=true] If set to false, method will remove file/directory asynchronously.
//  * @returns {wConsequence}
//  * @throws {Error} If missed argument, or pass more than 1.
//  * @throws {Error} If pathFile is not string.
//  * @throws {Error} If options object has unexpected property.
//  * @method fileDelete_
//  * @memberof wTools
//  */
//
// var fileDelete_ = function( o )
// {
//   var con = new wConsequence();
//
//   if( _.strIs( o ) )
//   o = { pathFile : o };
//
//   var o = _.routineOptions( fileDelete_,o );
//   _.assert( arguments.length === 1 );
//   _.assert( _.strIs( o.pathFile ) );
//
//   // if( _.files.usingReadOnly )
//   // return con.give();
//
//   var optionsDelete = _.mapScreen(  );
//   var stat;
//   if( o.sync )
//   {
//
//     if( !o.force )
//     {
//       self._fileDelete( o.pathFile );
//     }
//     else
//     {
//       self._fileDelete( o.pathFile );
//     }
//
//     con.give();
//
//   }
//   else
//   {
//
//     if( !o.force )
//     {
//       try
//       {
//         stat = File.lstatSync( o.pathFile );
//       }
//       catch( err ){};
//       if( !stat )
//       return con.error( _.err( 'cant read ' + o.pathFile ) );
//       if( stat.isSymbolicLink() )
//       throw _.err( 'not tested' );
//       if( stat.isDirectory() )
//       File.rmdir( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//       else
//       File.unlink( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//     }
//     else
//     {
//       File.remove( o.pathFile,function( err,data ){ con._giveWithError( err,data ) } );
//     }
//
//   }
//
//   return con;
// }
//
// fileDelete_.defaults =
// {
//
//   pathFile : null,
//   force : 1,
//   sync : 1,
//   throwing : 1,
//
// }

// --
// relationship
// --

var Composes =
{
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

// --
// prototype
// --

var Supplement =
{

  // find

  _filesOptions : _filesOptions,
  _filesMaskAdjust : _filesMaskAdjust,

  filesFind : filesFind,
  filesFindDifference : filesFindDifference,
  filesFindSame : filesFindSame,

  filesGlob : filesGlob,
  filesCopy : filesCopy,
  filesDelete : filesDelete,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,

  filesResolve : filesResolve,
  _filesResolveMakeGlob : _filesResolveMakeGlob,



  // tree

  filesTreeWrite : filesTreeWrite,
  filesTreeRead : filesTreeRead,


  // read

  fileReadJson : fileReadJson,


  // write

  //fileDelete_ : fileDelete_,


  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

var Self =
{

  Supplement : Supplement,

  name : 'FilePorviderAdvancedMixin',
  mixin : mixin,

}

//

Object.setPrototypeOf( Self, Supplement );

_.FileProvider = _.FileProvider || {};
_.FileProvider.AdvancedMixin = Self;

if( typeof module !== 'undefined' )
{
  module[ 'exports' ] = Self;
}

return Self;

})();
