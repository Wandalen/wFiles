( function _AdvancedMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  require( '../FileBase.s' );
  if( !wTools.FileRecord )
  require( '../FileRecord.s' );

  if( !wTools.FileProvider.Abstract )
  require( './Abstract.s' );

}

var _ = wTools;
var FileRecord = _.FileRecord;
var Abstract = _.FileProvider.Abstract;

// if( wTools.FileProvider.AdvancedMixin )
// return;

//

function _mixin( cls )
{

  var dstProto = cls.prototype;

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( cls ) );

  _.mixinApply
  ({
    dstProto : dstProto,
    descriptor : Self,
  });

}

// --
// find
// --

function _filesOptions( filePath,maskTerminal,o )
{

  _.assert( arguments.length === 1 || arguments.length === 3 );

  if( _.objectIs( filePath ) )
  {
    o = filePath;
    filePath = o.filePath;
    maskTerminal = o.maskTerminal;
  }

  o = o || Object.create( null );
  o.maskTerminal = maskTerminal;
  o.filePath = filePath;

  if( o.maskAll === undefined && o.maskTerminal === undefined && o.maskDir === undefined )
  o.maskAll = _.pathRegexpMakeSafe();

  return o;
}

//

function _filesMaskAdjust( o )
{

  _.assert( arguments.length === 1 );
  _.assert( _.mapIs( o ) );

  o.maskAll = _.regexpMakeObject( o.maskAll || Object.create( null ),'includeAny' );
  o.maskTerminal = _.regexpMakeObject( o.maskTerminal || Object.create( null ),'includeAny' );
  o.maskDir = _.regexpMakeObject( o.maskDir || Object.create( null ),'includeAny' );

/*
  if( o.hasExtension )
  {
    // /(^|\/)\.(?!$|\/|\.)/,
    _.assert( _.strIs( o.hasExtension ) );
    o.hasExtension = new RegExp( '^' + _.regexpEscape( o.hasExtension ) ); xxx
    _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.hasExtension } );
    delete o.hasExtension;
  }
*/

  if( o.begins )
  {
    _.assert( _.strIs( o.begins ) );
    o.begins = new RegExp( '^' + _.regexpEscape( o.begins ) );
    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.begins } );
    delete o.begins;
  }

  if( o.ends )
  {
    _.assert( _.strIs( o.ends ) || _.arrayIs( o.ends ) );

    if( _.strIs( o.ends ) )
    o.ends = new RegExp( _.regexpEscape( o.ends ) + '$' );
    else
    o.ends = new RegExp( '(' + _.regexpEscape( o.ends ).join( '|' ) + ')$' );

    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : o.ends } );
    delete o.ends;
  }

  if( o.glob )
  {
    _.assert( _.strIs( o.glob ) );
    var globRegexp = _.regexpForGlob( o.glob );
    o.maskTerminal = _.RegexpObject.shrink( o.maskTerminal,{ includeAll : globRegexp } );
    delete o.glob;
  }

  /* */

  if( o.notOlder )
  _.assert( _.numberIs( o.notOlder ) );

  if( o.notNewer )
  _.assert( _.numberIs( o.notNewer ) );

  return o;
}

_filesMaskAdjust.defaults =
{

  maskAll : null,
  maskTerminal : null,
  maskDir : null,

  begins : null,
  ends : null,
  glob : null,

  notOlder : null,
  notNewer : null,
  notOlderAge : null,
  notNewerAge : null,

}

//

function filesFind()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var o = self._filesOptions.apply( self,arguments );
  _.routineOptions( filesFind,o );
  self._filesMaskAdjust( o );

  if( !o.filePath )
  throw _.err( 'filesFind :','expects "filePath"' );

  var time;
  if( o.verbosity )
  time = _.timeNow();

  if( o.verbosity >= 2 )
  logger.log( 'filesFind',_.toStr( o,{ levels : 2 } ) );

  o.filePath = _.arrayAs( o.filePath );

  var result = o.result = o.result || [];
  var relative = o.relative;
  var orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );

  /* add result */

  function _filesAddResultFor( o )
  {
    var addResult;

    if( o.outputFormat === 'absolute' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( o.result,record.absolute ) >= 0 )
      {
        debugger;
        return;
      }
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( o.result,record.relative ) >= 0 )
      {
        debugger;
        return;
      }
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    addResult = function( record )
    {
      if( _.arrayLeftIndexOf( o.result,record.absolute,function( e ){ return e.absolute; } ) >= 0 )
      {
        return;
      }
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    addResult = function( record )
    {
    }
    else _.assert( 0,'unexpected output format :',o.outputFormat );

    return addResult;
  }

  var addResult = _filesAddResultFor( o );

  /* each file */

  function eachFile( filePath,o )
  {

    var files = self.directoryRead( filePath ) || [];

    if( self.fileIsTerminal( filePath ) )
    {
      filePath = _.pathDir( filePath );
    }

    var recordOptions = _.FileRecordOptions.tollerantMake( o,{ fileProvider : self, dir : filePath } );

    /* records */

    files = self.fileRecords( files,recordOptions );

    /* terminals */

    if( o.includeFiles )
    for( var f = 0 ; f < files.length ; f++ )
    {

      var record = files[ f ];

      if( record.isDirectory ) continue;
      if( !record.inclusion ) continue;

      _.routinesCall( o,o.onUp,[ record ] );
      addResult( record );
      _.routinesCall( o,o.onDown,[ record ] );

    }

    /* dirs */

    for( var f = 0 ; f < files.length ; f++ )
    {

      var record = files[ f ];

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

  /* ordering */

  function ordering( paths,o )
  {
    // debugger;

    if( _.strIs( paths ) )
    paths = [ paths ];
    paths = _.arrayUnique( paths );

    _.assert( _.arrayIs( paths ),'expects string or array' );

    for( var p = 0 ; p < paths.length ; p++ )
    {
      var filePath = paths[ p ];

      _.assert( _.strIs( filePath ),'expects string got ' + _.strTypeOf( filePath ) );

      filePath = _.pathRefine( filePath );

      if( relative === undefined || relative === null )
      {
        o = Object.assign( Object.create( null ),o );
        o.relative = filePath;
      }

      if( o.ignoreNonexistent )
      if( !self.fileStat( filePath ) )
      continue;

      eachFile( filePath,Object.freeze( o ) );

    }

  }

  /* ordering */

  if( !orderingExclusion.length )
  {
    ordering( o.filePath,_.mapExtend( null,o ) );
  }
  else
  {
    var maskTerminal = o.maskTerminal;
    for( var e = 0 ; e < orderingExclusion.length ; e++ )
    {
      o.maskTerminal = _.RegexpObject.shrink( Object.create( null ),maskTerminal,orderingExclusion[ e ] );
      ordering( o.filePath,_.mapExtend( null,o ) );
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

  if( o.verbosity )
  logger.log( _.timeSpent( 'At ' + o.filePath + ' found ' + result.length + ' in',time ) );

  return result;
}

filesFind.defaults =
{

  filePath : null,
  relative : null,

  safe : 1,
  recursive : 0,
  ignoreNonexistent : 0,
  includeFiles : 1,
  includeDirectories : 0,
  outputFormat : 'record',
  strict : 1,

  result : [],
  orderingExclusion : [],
  sortWithArray : null,

  verbosity : 0,

  onRecord : [],
  onUp : [],
  onDown : [],

}

filesFind.defaults.__proto__ = _filesMaskAdjust.defaults;

//

function filesFindDifference( dst,src,o )
{

  /* options */

  if( _.objectIs( dst ) )
  {
    o = dst;
    dst = o.dst;
    src = o.src;
  }

  var self = this;
  var o = ( o || Object.create( null ) );
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

  function _filesAddResultFor( o )
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

  o.dst = _.pathRegularize( o.dst );
  o.src = _.pathRegularize( o.src );

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

  // throw _.err( 'not tested' );

  /* dst */

  var dstOptions =
  {
    dir : dst,
    relative : dst,
    fileProvider : self,
    strict : 0,
  }
  dstOptions = _.FileRecordOptions.tollerantMake( o,dstOptions );
  // var dstOptions = _.mapScreen( FileRecord.prototype._fileRecord.defaults,o );
  // dstOptions.dir = dst;
  // dstOptions.relative = dst;
  // dstOptions.fileProvider = self;

  /* src */

  // var srcOptions = _.mapScreen( FileRecord.prototype._fileRecord.defaults,o );

  var srcOptions =
  {
    dir : src,
    relative : src,
    fileProvider : self,
    strict : 0,
  }
  srcOptions = _.FileRecordOptions.tollerantMake( o,srcOptions );
  // srcOptions.dir = src;
  // srcOptions.relative = src;
  // srcOptions.fileProvider = self;

  /* diagnostic */

  // logger.log( 'filesFindDifference' );
  // logger.log( _.toStr( o,{ levels : 4 } ) );
  // debugger;

  /* src file */

  function srcFile( dstOptions,srcOptions,file )
  {

    // var srcRecord = FileRecord( file,_.FileRecordOptions.tollerantMake( srcOptions ) );
    var srcRecord = FileRecord( file,_.FileRecordOptions( srcOptions ) );
    srcRecord.side = 'src';

    if( srcRecord.isDirectory )
    return;
    if( !srcRecord.inclusion )
    return;

    // var dstRecord = FileRecord( file,_.FileRecordOptions.tollerantMake( dstOptions ) );
    var dstRecord = FileRecord( file,_.FileRecordOptions( dstOptions ) );
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

    _.assert( srcRecord.stat,'cant get stat of',srcRecord.absolute );

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

  function srcDir( dstOptions,srcOptions,file,recursive )
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

      _.assert( dstOptions instanceof _.FileRecordOptions );
      _.assert( srcOptions instanceof _.FileRecordOptions );

      var dstOptionsSub = _.FileRecordOptions.tollerantMake( dstOptions,{ dir : dstRecord.absolute } );
      var srcOptionsSub = _.FileRecordOptions.tollerantMake( srcOptions,{ dir : srcRecord.absolute } );

      filesFindDifferenceAct( dstOptionsSub,srcOptionsSub );
    }

    if( o.includeDirectories )
    _.routinesCall( o,o.onDown,[ record ] );

  }

  /* dst file */

  function dstFile( dstOptions,srcOptions,file )
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

  function dstDir( dstOptions,srcOptions,file,recursive )
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
        filePath : dstRecord.absolute,
        outputFormat : o.outputFormat,
        recursive : 1,
        safe : 0,
      })

      // debugger;
      _.assert( srcOptions instanceof _.FileRecordOptions );
      // srcOptions = _.mapExtend( null,srcOptions );
      // srcOptions = srcOptions.cloneData();
      // delete srcOptions.dir;
      var srcOptions = _.FileRecordOptions.tollerantMake( srcOptions,{ dir : null } );

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

  function filesFindDifferenceAct( dstOptions,srcOptions )
  {

    /* dst */

    var dstRecord = FileRecord( dstOptions.dir,dstOptions );
    if( o.investigateDestination )
    if( dstRecord.stat && dstRecord.stat.isDirectory() )
    {

      var files = self.directoryRead( dstRecord.real );
      if( !files )
      debugger;

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
      if( !files )
      debugger;

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
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

filesFindDifference.defaults.__proto__ = _filesMaskAdjust.defaults

//

function filesFindSame()
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

  if( !o.filePath )
  throw _.err( 'filesFindSame :','expects "filePath"' );

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
  findOptions.strict = 0;
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

  function checkLink()
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

  function checkContent()
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

  function checkSimilarity()
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

  function checkName()
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
      _.assert( _.arrayCountUnique( linkedRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in linkedRecord' );
      result.linked.push( linkedRecord );
    }

    if( sameContentRecord && sameContentRecord.length > 1  )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountUnique( sameContentRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameContentRecord' );
      result.sameContent.push( sameContentRecord );
    }

    if( sameNameRecord && sameNameRecord.length > 1 )
    {
      if( !o.usingFast )
      _.assert( _.arrayCountUnique( sameNameRecord,function( e ){ return e.absolute } ) === 0,'should not have duplicates in sameNameRecord' );
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
  logger.log( _.timeSpent( 'Spent to find same at ' + o.filePath,time ) );

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

function filesGlob( o )
{
  var self = this;

  if( o.glob === undefined )
  o.glob = '*';

  _.assert( _.objectIs( o ) );
  _.assert( _.strIs( o.glob ) );

  if( o.filePath === undefined )
  {
    var i = o.glob.search( /[^\\\/]*?(\*\*|\?|\*)[^\\\/]*/ );
    if( i === -1 )
    o.filePath = o.glob;
    else o.filePath = o.glob.substr( 0,i );
    if( !o.filePath )
    o.filePath = _.pathRealMainDir();
  }

  if( o.relative === undefined )
  o.relative = o.filePath;

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
    cwd : options.filePath,
    nosort : false,
  }

  var result = Glob.sync( options.pattern,globOptions );
*/

  return result;
}

filesGlob.defaults = {};
filesGlob.defaults.__proto__ = filesFind.defaults;

//

function filesCopy( options )
{
  var self = this;

  _.assert( arguments.length === 1 );

  // if( onReady ) return _.timeOut( 0, function()
  // {
  //   onReady( filesCopy.call( this,options ) );
  // });

  var options = options || Object.create( null );

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
  var directories = Object.create( null );

  // safe

  if( options.safe )
  if( options.removeSource && ( !options.allowWrite || !options.allowRewrite ) )
  throw _.err( 'not safe removeSource :1 with allowWrite :0 or allowRewrite :0' );

  // make dir

  var dirname = _.pathDir( options.dst );

  if( options.safe )
  if( !_.pathIsSafe( dirname ) )
  throw _.err( dirname,'Unsafe to use :',dirname );

  var recordDir = new _.FileRecord( dirname,_.FileRecordOptions({ fileProvider : self }) );
  var rewriteDir = recordDir.stat && !recordDir.stat.isDirectory();
  if( rewriteDir )
  if( options.allowRewrite )
  {

    debugger;
    throw _.err( 'not tested' );
    if( options.verbosity )
    logger.log( '- rewritten file by directory :',dirname );
    self.fileDelete({ filePath : filePath, force : 0 });
    self.directoryMake({ filePath : dirname, force : 1 });

  }
  else
  {
    throw _.err( 'cant rewrite',dirname );
  }

  // on up

  function handleUp( record )
  {

    /* */

    // if( /include($|\/)/.test( record.src.absolute ) )
    // debugger

    /* same */

    if( options.tryingPreserve )
    if( record.same && record.link == options.usingLinking )
    {
      record.action = 'same';
      record.allowed = true;
    }

    /* delete redundant */

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

    /* preserve directory */

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

    /* rewrite */

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
          self.fileRename
          ({
            pathDst : rewriteFile,
            pathSrc : record.dst.absolute,
            verbosity : 0,
          });
          delete record.dst.stat;
        }
        else
        {
          rewriteFile = false;
          record.action = 'cant rewrite';
          record.allowed = false;
          if( options.verbosity )
          logger.log( '? cant rewrite :',record.dst.absolute );
        }

      }

    }

    /* new directory */

    if( !record.action && record.src.stat && record.src.stat.isDirectory() )
    {

      directories[ record.dst.absolute ] = true;
      record.action = 'directory new';
      record.allowed = false;
      if( options.allowWrite )
      {
        self.directoryMake({ filePath : record.dst.absolute, force : 1 });
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
          //if( options.verbosity )
          //logger.log( '+ ' + record.action + ' :',record.dst.absolute );
          //self.linkHard( record.dst.absolute,record.src.real );
          self.linkHard({ pathDst : record.dst.absolute, pathSrc : record.src.real, sync : 1, verbosity : options.verbosity });
        }

      }
      else
      {

        record.action = 'copied';
        record.allowed = false;

        if( options.allowWrite )
        {
          record.allowed = true;
          if( options.verbosity )
          logger.log( '+ ' + record.action + ' :',record.dst.absolute );
          self.fileCopy( record.dst.absolute,record.src.real );
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
        filePath : rewriteFile,
        force : 1,
      });
    }

    // callback

    if( !includeDirectories && record.src.stat && record.src.stat.isDirectory() )
    return false;

    _.routinesCall( options,onUp,[ record ] );

  }

  // on down

  function handleDown( record )
  {

    if( record.action === 'linked' && record.del )
    throw _.err( 'unexpected' );

    // delete redundant

    if( record.action === 'deleted' )
    {
      if( record.allowed )
      {
        if( options.verbosity )
        logger.log( '- deleted :',record.dst.absolute );
        self.fileDelete({ filePath : record.dst.absolute, force : 1 });
        delete record.dst.stat;

        // !!! error here. attempt to delete redundant dir with files.

      }
      else
      {
        if( options.verbosity && !options.silentPreserve )
        logger.log( '? not deleted :',record.dst.absolute );
      }
    }

    // remove source

    var removeSource = false;
    removeSource = removeSource || options.removeSource;
    removeSource = removeSource || ( options.removeSourceFiles && !record.src.isDirectory );

    if( removeSource && record.src.stat && record.src.inclusion )
    {
      if( options.verbosity )
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

    if( options.verbosity )
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
    debugger;
    throw _.err( 'filesCopy( ',_.toStr( options ),' )','\n',err );
  }

  return records;
}

filesCopy.defaults =
{

  verbosity : 1,
  usingLinking : 0,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

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

function filesDelete()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  o.outputFormat = 'absolute';

  _.mapComplement( o,filesDelete.defaults );

  // logger.log( 'filesDelete',o );

  /* */

  var optionsForFind = _.mapBut( o,filesDelete.defaults );
  var files = self.filesFind( optionsForFind );

  /* */

  for( var f = 0 ; f < files.length ; f++ ) try
  {

    if( o.verbosity )
    logger.log( '- deleted :',files[ f ] )
    self.fileDelete({ filePath : files[ f ], force : 1 });

  }
  catch( err )
  {
    if( !o.silent )
    throw _.err( err );
  }

  return new wConsequence().give();
}

filesDelete.defaults =
{
  silent : false,
  verbosity : false,
}

// filesDelete.defaults.__proto__ = filesFind.defaults;

//

function filesDeleteFiles( o )
{
  var self = this;

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _.mapComplement( o,filesDeleteFiles.defaults );

  return self.filesDelete( o );
}

filesDeleteFiles.defaults =
{
  recursive : 1,
  includeDirectories : 0,
  includeFiles : 1,
}

//

function filesDeleteDirs( o )
{
  var self = this;

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );
  _.mapComplement( o,filesDeleteDirs.defaults );

  return self.filesDelete( o );
}

filesDeleteDirs.defaults =
{
  recursive : 1,
  includeDirectories : 1,
  includeFiles : 1,
}

// filesDeleteDirs.defaults.__proto__ = filesDelete.defaults;

//

function filesDeleteEmptyDirs()
{
  var self = this;

  _.assert( arguments.length === 1 || arguments.length === 3 );

  var o = self._filesOptions( arguments[ 0 ],arguments[ 1 ],arguments[ 2 ] );

  /* */

  o.outputFormat = 'absolute';
  o.includeFiles = 0;
  o.includeDirectories = 1;
  if( o.recursive === undefined )
  o.recursive = 1;

  _.mapComplement( o,filesDeleteEmptyDirs.defaults );

  /* */

  var o = _.mapBut( o,filesDeleteEmptyDirs.defaults );
  debugger;
  o.onDown = _.__arrayAppend( _.arrayAs( o.onDown ), function( record )
  {

    try
    {

      var sub = self.directoryRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
        logger.log( '- deleted :',record.absolute );
        self.fileDelete({ filePath : record.absolute, force : 1 });
      }
    }
    catch( err )
    {
      if( !o.silent )
      throw _.err( err );
    }

  });

  var files = self.filesFind( o );

  return new wConsequence().give();
}

filesDeleteEmptyDirs.defaults =
{
  silent : false,
  verbosity : false,
}

//

function filesResolve( options )
{
  var self = this;
  var result = [];

  _.assertMapHasOnly( options,filesResolve.defaults );
  _.assert( _.objectIs( options ) );
  _.assert( _.strIs( options.pathLookRoot ) );

  options.pathLookRoot = _.pathRegularize( options.pathLookRoot );

  if( !options.pathOutputRoot )
  options.pathOutputRoot = options.pathLookRoot;
  else
  options.pathOutputRoot = _.pathRegularize( options.pathOutputRoot );

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

function _filesResolveMakeGlob( options )
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
// filesTree
// --

function filesTreeWrite( o )
{
  var self = this;

  _.routineOptions( filesTreeWrite,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  if( o.verbosity )
  logger.log( 'filesTreeWrite to ' + o.filePath );

  //

  var stat = null;
  function handleWritten( filePath )
  {
    if( !o.allowWrite )
    return;
    if( !o.sameTime )
    return;
    if( !stat )
    stat = self.fileStat( filePath );
    else
    self.fileTimeSet( filePath, stat.atime, stat.mtime );
  }

  //

  function write( filePath,filesTree )
  {

    _.assert( _.strIs( filePath ) );
    _.assert( _.strIs( filesTree ) || _.objectIs( filesTree ) || _.arrayIs( filesTree ) );

    //var exists = File.existsSync( filePath );
    var exists = self.fileStat( filePath );
    if( o.allowDelete && exists )
    {
      self.fileDelete({ filePath : filePath, force : 1 });
      //File.removeSync( filePath );
      exists = false;
    }

    if( _.strIs( filesTree ) )
    {
      if( o.allowWrite && !exists )
      self.fileWrite( filePath,filesTree );
      handleWritten( filePath );
    }
    else if( _.objectIs( filesTree ) )
    {
      if( o.allowWrite && !exists )
      self.directoryMake({ filePath : filePath, force : 1 });
      handleWritten( filePath );
      for( var t in filesTree )
      {
        write( _.pathJoin( filePath,t ),filesTree[ t ] );
      }
    }
    else if( _.arrayIs( filesTree ) )
    {
      _.assert( filesTree.length === 1 );
      filesTree = filesTree[ 0 ];

      _.assert( _.strIs( filesTree.softlink ) );
      if( o.allowWrite && !exists )
      {
        var pathTarget = filesTree.softlink;
        if( o.absolutePathForLink || filesTree.absolute )
        if( !filesTree.relative )
        pathTarget = _.pathResolve( _.pathJoin( filePath,'..',filesTree.softlink ) );
        self.linkSoft( filePath,pathTarget );
      }
      handleWritten( filePath );
    }

  }

  write( o.filePath,o.filesTree );

}

filesTreeWrite.defaults =
{
  filesTree : null,
  filePath : null,
  sameTime : 0,
  absolutePathForLink : 0,
  allowWrite : 1,
  allowDelete : 0,
  verbosity : 0,
}

//

/** usage

    var treeWriten = _.filesTreeRead
    ({
      filePath : dir,
      readTerminals : 0,
    });

    logger.log( 'treeWriten :',_.toStr( treeWriten,{ levels : 99 } ) );

*/

function filesTreeRead( o )
{
  var self = this;
  var result = Object.create( null );

  if( _.strIs( o ) )
  o = { filePath : o };

  _.routineOptions( filesTreeRead,o );
  _.assert( arguments.length === 1 );
  _.assert( _.strIs( o.filePath ) );

  o.outputFormat = 'record';

  if( o.verbosity )
  logger.log( 'filesTreeRead from ' + o.filePath );

  /* */

  debugger;
  o.onUp = _.__arrayPrepend( _.arrayAs( o.onUp ), function( record )
  {
    var data = Object.create( null );

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
      delimeter : o.delimeter,
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
  verbosity : 0,
  delimeter : '/',
}

filesTreeRead.defaults.__proto__ = filesFind.defaults;

// --
// etc
// --

function filesAreUpToDate( dst,src )
{
  var self = this;
  var odst = dst;
  var osrc = src;

  _.assert( arguments.length === 2 );

  // if( src.indexOf( 'Private.cpp' ) !== -1 )
  // console.log( 'src :',src );
  //
  // if( src.indexOf( 'Private.cpp' ) !== -1 )
  // debugger;

  /* */

  function _from( file )
  {
    if( _.fileStatIs( file ) )
    return  { stat : file };
    else if( _.strIs( file ) )
    return { stat : self.fileStat( file ) };
    else if( !_.objectIs( file ) )
    throw _.err( 'unknown descriptor of file' );
  }

  /* */

  function from( file )
  {
    if( _.arrayIs( file ) )
    {
      var result = [];
      for( var i = 0 ; i < file.length ; i++ )
      result[ i ] = _from( file[ i ] );
      return result;
    }
    return [ _from( file ) ];
  }

  /* */

  dst = from( dst );
  src = from( src );

  // logger.log( 'dst',dst[ 0 ] );
  // logger.log( 'src',src[ 0 ] );

  var dstMax = _.entityMax( dst, function( e ){ return e.stat ? e.stat.mtime : Infinity; } );
  var srcMax = _.entityMax( src, function( e ){ return e.stat ? e.stat.mtime : Infinity; } );

  // logger.log( 'dstMax.element.stat.mtime',dstMax.element.stat.mtime );
  // logger.log( 'srcMax.element.stat.mtime',srcMax.element.stat.mtime );

  if( !dstMax.element.stat )
  return false;

  if( !srcMax.element.stat )
  return false;

  if( dstMax.element.stat.mtime >= srcMax.element.stat.mtime )
  return true;
  else
  return false;

}

//

/**
 * Returns true if any file from o.dst is newer than other any from o.src.
 * @example :
 * wTools.filesAreUpToDate2
 * ({
 *   src : [ 'foo/file1.txt', 'foo/file2.txt' ],
 *   dst : [ 'bar/file1.txt', 'bar/file2.txt' ],
 * });
 * @param {Object} o
 * @param {string[]} o.src array of paths
 * @param {Object} [o.srcOptions]
 * @param {string[]} o.dst array of paths
 * @param {Object} [o.dstOptions]
 * @param {boolean} [o.verbosity=true] turns on/off logging
 * @returns {boolean}
 * @throws {Error} If passed object has unexpected parameter.
 * @method filesAreUpToDate2
 * @memberof wTools
 */

function filesAreUpToDate2( o )
{
  var self = this;

  _.assert( arguments.length === 1 );
  _.assert( !o.newer || _.dateIs( o.newer ) );
  _.routineOptions( filesAreUpToDate2,o );

  // throw _.err( 'not tested' );
  // var srcFiles = FileRecord.prototype.fileRecordsFiltered( o.src,o.srcOptions );

  debugger;
  var srcFiles = self.fileRecordsFiltered( o.src );

  if( !srcFiles.length )
  {
    if( o.verbosity )
    logger.log( 'Nothing to parse' );
    return true;
  }

  var srcNewest = _.entityMax( srcFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /* */

  var dstFiles = self.fileRecordsFiltered( o.dst );

  if( !dstFiles.length )
  {
    return false;
  }

  var dstOldest = _.entityMin( dstFiles,function( file ){ return file.stat.mtime.getTime() } ).element;

  /* */

  if( o.notOlder )
  {
    if( !( o.notOlder.getTime() <= dstOldest.stat.mtime.getTime() ) )
    return false;
  }

  if( srcNewest.stat.mtime.getTime() <= dstOldest.stat.mtime.getTime() )
  {

    if( o.verbosity )
    logger.log( 'Up to date' );
    return true;

  }

  return false;
}

filesAreUpToDate2.defaults =
{
  src : null,
  dst : null,
  verbosity : 1,
  notOlder : null,
}

// --
// config
// --

function fileConfigRead( o )
{

  var self = this;
  var o = o || Object.create( null );

  if( _.strIs( o ) )
  {
    o = { name : o };
  }

  if( o.pathDir === undefined )
  o.pathDir = _.pathRegularize( _.pathEffectiveMainDir() );

  if( o.result === undefined )
  o.result = Object.create( null );

  _.routineOptions( fileConfigRead,o );

  if( !o.name )
  {
    o.name = 'config';
    self._fileConfigRead( o );
    o.name = 'public';
    self._fileConfigRead( o );
    o.name = 'private';
    self._fileConfigRead( o );
  }
  else
  {
    self._fileConfigRead( o );
  }

  return o.result;
}

fileConfigRead.defaults =
{
  name : null,
  pathDir : null,
  result : null,
}

//

function _fileConfigRead( o )
{

  var self = this;
  var read;

  if( o.name === undefined )
  o.name = 'config';

  var pathTerminal = _.pathJoin( o.pathDir,o.name );

  /**/

  if( typeof Coffee !== 'undefined' )
  {
    var fileName = pathTerminal + '.coffee';
    if( self.fileStat( fileName ) )
    {

      read = self.fileReadSync( fileName );
      read = Coffee.eval( read,
      {
        filename : fileName,
      });
      _.mapExtend( o.result,read );

    }
  }

  /**/

  var fileName = pathTerminal + '.json';
  if( self.fileStat( fileName ) )
  {

    read = self.fileReadSync( fileName );
    read = JSON.parse( read );
    _.mapExtend( o.result,read );

  }

  /**/

  var fileName = pathTerminal + '.s';
  if( self.fileStat( fileName ) )
  {

    debugger;
    read = self.fileReadSync( fileName );
    read = _.exec( read );
    _.mapExtend( o.result,read );

  }

  return o.result;
}

_fileConfigRead.defaults = fileConfigRead.defaults;

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
  filesDeleteFiles : filesDeleteFiles,
  filesDeleteDirs : filesDeleteDirs,
  filesDeleteEmptyDirs : filesDeleteEmptyDirs,

  filesResolve : filesResolve,
  _filesResolveMakeGlob : _filesResolveMakeGlob,


  // filesTree

  filesTreeWrite : filesTreeWrite,
  filesTreeRead : filesTreeRead,


  // etc

  filesAreUpToDate : filesAreUpToDate,
  filesAreUpToDate2 : filesAreUpToDate2,


  // config

  fileConfigRead : fileConfigRead,
  _fileConfigRead : _fileConfigRead,


  //

  Composes : Composes,
  Aggregates : Aggregates,
  Associates : Associates,
  Restricts : Restricts,

}

//

var Self =
{

  supplement : Supplement,

  name : 'FilePorviderAdvancedMixin',
  _mixin : _mixin,

}

//

// Object.setPrototypeOf( Self, Supplement );

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider.AdvancedMixin = Self;

if( typeof module !== 'undefined' )
module[ 'exports' ] = Self;
_global_[ Self.name ] = wTools[ Self.nameShort ] = _.mixinMake( Self );

})();
