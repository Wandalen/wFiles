( function _FindMixin_s_() {

'use strict';

if( typeof module !== 'undefined' )
{

  let _ = _global_.wTools;
  if( !_.FileProvider )
  require( '../UseMid.s' );

}

let _global = _global_;
let _ = _global_.wTools;
let FileRecord = _.FileRecord;

//

let Parent = null;
let Self = function wFileProviderFind( o )
{
  return _.instanceConstructor( Self, this, arguments );
}

Self.shortName = 'Find';

// let debugPath = '/dir';

// --
// etc
// --

function recordsOrder( records, orderingExclusion )
{

  _.assert( _.arrayIs( records ) );
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  if( !orderingExclusion.length )
  return records;

  orderingExclusion = _.RegexpObject.order( orderingExclusion || [] );

  let removed = [];
  let result = [];
  let e = 0;
  for( ; e < orderingExclusion.length ; e++ )
  result[ e ] = [];

  for( let r = 0 ; r < records.length ; r++ )
  {
    let record = records[ r ];
    for( let e = 0 ; e < orderingExclusion.length ; e++ )
    {
      let mask = orderingExclusion[ e ];
      let match = mask.test( record.relative );
      if( match )
      {
        result[ e ].push( record );
        break;
      }
    }
    if( e === orderingExclusion.length )
    removed.push( record );
  }

  return _.arrayAppendArrays( [], result );
}

//

function _filesFilterMasksSupplement( dst, src )
{
  _.assert( arguments.length === 2, 'Expects exactly two arguments' );

  _.mapSupplement( dst, src );

  dst.maskDirectory = _.RegexpObject.And( null, dst.maskDirectory || Object.create( null ), src.maskDirectory || Object.create( null ) );
  dst.maskTerminal = _.RegexpObject.And( null, dst.maskTerminal || Object.create( null ), src.maskTerminal || Object.create( null ) );
  dst.maskAll = _.RegexpObject.And( null, dst.maskAll || Object.create( null ), src.maskAll || Object.create( null ) );

  return dst;
}

// --
// files find
// --

function filesFindLike_pre( args )
{
  let o;

  _.assert( arguments.length === 1 );
  _.assert( 1 === args.length );

  if( args.length === 1 && _.routineIs( args[ 0 ] ) )
  {

    o = o || Object.create( null );
    o.onUp = args[ 0 ];

  }
  else
  {

    if( _.objectIs( args[ 0 ] ) )
    {
      o = args[ 0 ];
    }
    else
    {
      o = { filePath : args[ 0 ] };
    }

    // if( args[ 1 ] !== undefined && o.maskTerminal === undefined )
    // o.maskTerminal = args[ 1 ];

  }

  // if( o.maskPreset )
  // {
  //   _.assert( o.maskPreset === 'default.exclude', 'Not supported preset', o.maskPreset );
  //   o.filter = o.filter || Object.create( null );
  //   if( Object.keys( o.filter ).length === 0 )
  //   o.filter.maskAll = _.files.regexpMakeSafe();
  // }

  return o;
}

//

function filesFind_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = self.filesFindLike_pre( args );

  _.routineOptions( routine, o );

  if( o.maskPreset )
  {
    _.assert( o.maskPreset === 'default.exclude', 'Not supported preset', o.maskPreset );
    o.filter = o.filter || Object.create( null );
    if( !o.filter.formed || o.filter.formed < 5 )
    o.filter.maskAll = _.files.regexpMakeSafe( o.filter.maskAll || null );
  }

  if( Config.debug )
  {

    _.assert( arguments.length === 2 );
    _.assert( 1 <= args.length && args.length <= 3 );
    _.assert( o.basePath === undefined );
    _.assert( o.prefixPath === undefined );
    _.assert( o.postfixPath === undefined );
    _.assert( o.recursive === 0 || o.recursive === 1 || o.recursive === 2, () => 'Incorrect value of recursive option', _.strQuote( o.recursive ), ', should be 0, 1 or 2' );

  }

  self._filesFilterForm( o );

  o.filter.effectiveFileProvider._providerDefaults( o );

  return o;
}

//

function _filesFilterForm( o )
{
  let self = this;
  let path = self.path;

  _.assert( !o.filter || !o.filter.formed <= 3, 'Filter is already formed, but should not be!' )
  _.assert( arguments.length === 1, 'Expects single argument' );

  o.filter = self.recordFilter( o.filter || {} );

  if( o.filePath instanceof _.FileRecordFilter )
  {
    // debugger;
    o.filter.pathsExtend( o.filePath ).and( o.filePath );
    o.filePath = null;
  }

  if( o.maskPreset && !o.filter.formed )
  {
    _.assert( o.maskPreset === 'default.exclude', 'Not supported preset', o.maskPreset );
    let filter2 = { maskAll : _.files.regexpMakeSafe() };
    o.filter.and( filter2 );
  }

  _.assert
  (
    o.filter.filePath === null || o.filePath === null || o.filter.filePath === o.filePath || o.filter.filePath === '.',
    '{- o.filePath -} and {- o.filter.filePath -} should be exactly same or null'
  );

  if( !o.filter.formed || o.filter.formed < 5 )
  {

    if( o.filePath !== null )
    o.filter.filePath = o.filePath;
    o.filter.form();

  }

  o.filePath = null;
  _.assert( !self.hub || o.filter.hubFileProvider === self.hub );
  _.assert( !!o.filter.effectiveFileProvider );
  _.assert( path.s.allAreNormalized( o.filter.filePath ) );

  return o;
}

_.assert( _.objectIs( _.FileRecordFilter.prototype.Composes ) );
_filesFilterForm.defaults = Object.create( _.FileRecordFilter.prototype.Composes );

//

function filesFindSingle_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = self.filesFind_pre( routine, args );
  return o;
}

//

function filesFindSingle_body( o )
{
  let self = this;
  let path = self.path;

  o.filter.effectiveFileProvider._providerDefaults( o ); /* xxx */
  // o.filter.effectiveFileProvider.assertProviderDefaults( o );

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( filesFindSingle_body, o );
  _.assert( _.routineIs( o.onUp ) || _.arrayIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) || _.arrayIs( o.onDown ) );
  _.assert( path.isNormalized( o.filePath ), 'Expects normalized path {-o.filePath-}' );
  _.assert( path.isAbsolute( o.filePath ), 'Expects absolute path {-o.filePath-}' );

  _.assert( o.filter.formed === 5, 'Expects formed filter' );
  _.assert( _.objectIs( o.filter.effectiveFileProvider ) );
  _.assert( _.mapIs( o.filter.formedBasePath ), 'Expects base path' );
  _.assert( o.filter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  // _.assert( o.filter.hubFileProvider === o.filter.effectiveFileProvider || o.filter.hubFileProvider instanceof _.FileProvider.Hub );
  // _.assert( o.filter.hubFileProvider === null || o.filter.hubFileProvider instanceof _.FileProvider.Hub );
  _.assert( o.filter.defaultFileProvider instanceof _.FileProvider.Abstract );

  /* handler */

  if( _.arrayIs( o.onUp ) )
  if( o.onUp.length === 0 )
  o.onUp = function( record ){ return record };
  else
  o.onUp = _.routinesComposeAllReturningLast( o.onUp );

  if( _.arrayIs( o.onDown ) )
  o.onDown = _.routinesCompose( o.onDown );

  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );

  /* */

  let recordAdd = recordAdd_functor( o );
  o.result = o.result || [];
  Object.freeze( o );

  let o2 =
  {
    stemPath : o.filePath,
    basePath : o.filter.formedBasePath[ o.filePath ],
  };

  _.assert( _.strDefined( o2.basePath ), 'No base path for', o.filePath );

  let recordFactory = _.FileRecordFactory.TollerantFrom( o, o2 ).form();
  let stemRecord = recordFactory.record( o.filePath );

  _.assert( recordFactory.basePath === o.filter.formedBasePath[ o.filePath ] );
  _.assert( recordFactory.dirPath === null );
  _.assert( stemRecord.isStem === true );
  _.assert( recordFactory.effectiveFileProvider === o.filter.effectiveFileProvider );
  _.assert( recordFactory.hubFileProvider === o.filter.hubFileProvider || o.filter.hubFileProvider === null );
  _.assert( recordFactory.defaultFileProvider === o.filter.defaultFileProvider );

  if( !stemRecord.stat )
  {
    if( o.allowingMissed )
    {
      // recordAdd( stemRecord );
      return o.result;
    }
    debugger;
    throw _.err( 'Stem file does not exist', _.strQuote( stemRecord.absolute ) );
  }

  forStem( stemRecord, o );

  return o.result;

  /* */

  function forStem( record, o )
  {
    // debugger;
    forDirectory( record, o )
    forTerminal( record, o )
  }

  /* */

  function forDirectory( r, o )
  {

    if( !r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let isTransient = r.isTransient;
    let includingTransient = ( o.includingTransient && r.isTransient && o.includingDirs );
    let includingActual = ( o.includingActual && r.isActual && o.includingDirs );
    // let including = !!r.stat;
    let including = true;
    including = including && ( includingTransient || includingActual );
    including = including && ( o.includingStem || !r.isStem );

    /* up */

    if( including )
    {
      r = handleUp( r, o );
      if( r === false || r === _.dont )
      return false;
      recordAdd( r );
    }

    /* read */

    if( isTransient && o.recursive )
    if( o.recursive === 2 || or.isStem )
    {
      /* Vova : real path should be used for soft/text link to a dir for two reasons:
      - files from linked directory should be taken into account
      - usage of or.absolute path for a link will lead to recursion on next forDirectory( file, o ), because dirRead will return same path( or.absolute )
      outputFormat : relative is used because absolute path should contain path to a link in head
      */
      // let files = o.filter.effectiveFileProvider.dirRead({ filePath : or.absolute, outputFormat : 'absolute' });
      let files = o.filter.effectiveFileProvider.dirRead({ filePath : /* or.absolute */or.real, outputFormat : /* 'absolute' */'relative' });

      if( files === null )
      {
        if( o.allowingMissed )
        {
          files = [];
        }
        else
        {
          debugger;
          throw _.err( 'Failed to read directory', _.strQuote( or.absolute ) );
        }
      }

      files = self.path.s.join( or.absolute, files );

      files = or.factory.records( files );

      // if( Config.debug )
      // for( let f = 0 ; f < files.length ; f++ )
      // {
      //   let file = files[ f ];
      //   if( file.absolute === or.absolute )
      //   {
      //     debugger;
      //     let files = o.filter.effectiveFileProvider.dirRead({ filePath : or.absolute, outputFormat : 'absolute' });
      //     _.assert( file.absolute !== or.absolute, 'Something wrong with {- dirRead -}' );
      //   }
      // }

      /* terminals */

      if( o.includingTerminals )
      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forTerminal( file, o );
      }

      /* dirs */

      for( let f = 0 ; f < files.length ; f++ )
      {
        let file = files[ f ];
        forDirectory( file, o );
      }

    }

    /* down */

    if( including )
    handleDown( r, o );

  }

  /* */

  function forTerminal( r, o )
  {

    if( r.isDir )
    return;
    if( !r.isTransient && !r.isActual )
    return;

    let or = r;
    let includingTransient = ( o.includingTransient && r.isTransient && o.includingTerminals );
    let includingActual = ( o.includingActual && r.isActual && o.includingTerminals );
    // let including = !!r.stat;
    let including = true;
    including = including && ( includingTransient || includingActual );
    including = including && ( o.includingStem || !or.isStem );

    if( !including )
    return;

    r = handleUp( r, o );
    if( r === false || r === _.dont )
    return false;
    recordAdd( r );

    handleDown( r, o );
  }

  /* - */

  function handleUp( record, op )
  {
    _.assert( arguments.length === 2 );
    let result = op.onUp.call( self, record, op );
    _.assert( result === false || result === _.dont || result === record, 'onUp should return original record or _.dont, but got', _.toStrShort( result ) );
    return result;
  }

  /* - */

  function handleDown( record, op )
  {
    _.assert( arguments.length === 2 );
    let result = op.onDown.call( self, record, op );
    // _.assert( result === undefined || result === record, 'onDown should return original record or undefined, but got', _.toStrShort( result ) );
    return result;
  }

  /* - */

  function recordAdd_functor( o )
  {
    let recordAdd;

    if( o.outputFormat === 'absolute' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record.absolute );
    }
    else if( o.outputFormat === 'relative' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record.relative );
    }
    else if( o.outputFormat === 'record' )
    recordAdd = function( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    recordAdd = function( record )
    {
    }
    else _.assert( 0, 'unexpected output format :', o.outputFormat );

    return recordAdd;
  }

}

filesFindSingle_body.defaults =
{

  filePath : null,
  filter : null,

  includingTerminals : 1,
  includingDirs : 0,
  includingStem : 1,
  includingActual : 1,
  includingTransient : 0,

  allowingMissed : 0,
  allowingCycled : 0,
  recursive : 1,

  // resolving : 1,
  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  maskPreset : 'default.exclude',
  outputFormat : 'record',
  result : [],
  onUp : [],
  onDown : [],

  safe : null

}

var having = filesFindSingle_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesFindSingle = _.routineFromPreAndBody( filesFindSingle_pre, filesFindSingle_body );

//

function filesFind_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( !!o.filePath, 'filesFind expects {-o.filePath-} or {-o.glob-}' );
  _.assert( !o.filePath );
  _.assert( o.filter.formed === 5 );

  let time;
  if( o.verbosity >= 1 )
  time = _.timeNow();

  if( o.verbosity >= 3 )
  self.logger.log( 'filesFind', _.toStr( o, { levels : 2 } ) );

  // debugger;
  // if( _.strEnds( o.filter.filePathSimplest(), '/dst/dst' ) )
  // debugger;

  o.filePath = [];
  // debugger;
  for( let src in o.filter.formedFilePath )
  {
    let dst = o.filter.formedFilePath[ src ];
    if( !_.boolLike( dst ) || dst )
    o.filePath.push( src );
  }
  // debugger;
  // o.filePath = _.mapKeys( o.filter.formedFilePath );
  // o.filePath = _.arrayAs( o.filePath );
  o.result = o.result || [];

  _.assert( _.strsAreAll( o.filePath ) );
  // _.assert( _.arraySetIdentical( _.mapKeys( o.filter.filePath ), o.filePath ) );
  _.assert( !o.orderingExclusion.length || o.orderingExclusion.length === 0 || o.outputFormat === 'record' );

  forPaths( o.filePath, _.mapExtend( null, o ) );

  return end();

  /* */

  function end()
  {
    /* order */

    o.result = self.recordsOrder( o.result, o.orderingExclusion );

    // let orderingExclusion = _.RegexpObject.order( o.orderingExclusion || [] );
    // if( !orderingExclusion.length )
    // {
    //   forPaths( o.filePath, _.mapExtend( null, o ) );
    // }
    // else
    // {
    //   let maskTerminal = o.maskTerminal;
    //   for( let e = 0 ; e < orderingExclusion.length ; e++ )
    //   {
    //     o.maskTerminal = _.RegexpObject.And( Object.create( null ), maskTerminal, orderingExclusion[ e ] );
    //     forPaths( o.filePath, _.mapExtend( null, o ) );
    //   }
    // }

    /* sort */

    if( o.sortingWithArray )
    {

      _.assert( _.arrayIs( o.sortingWithArray ) );

      if( o.outputFormat === 'record' )
      o.result.sort( function( a, b )
      {
        return _.regexpArrayIndex( o.sortingWithArray, a.relative ) - _.regexpArrayIndex( o.sortingWithArray, b.relative );
      })
      else
      o.result.sort( function( a, b )
      {
        return _.regexpArrayIndex( o.sortingWithArray, a ) - _.regexpArrayIndex( o.sortingWithArray, b );
      });

    }

    /* mandatory */

    if( o.mandatory )
    if( !o.result.length )
    {
      debugger;
      throw _.err( 'No file found at ' + path.commonReport( o.filter.filePath || o.filePath ) );
    }

    /* timing */

    if( o.verbosity >= 1 )
    self.logger.log( ' . Found ' + o.result.length + ' files at ' + o.filePath + ' in ', _.timeSpent( time ) );

    if( !o.sync )
    return new _.Consequence().take( o.result );

    return o.result;
  }

  /* find for several paths */

  function forPaths( filePaths, o )
  {

    if( _.strIs( filePaths ) )
    filePaths = [ filePaths ];
    filePaths = _.arrayUnique( filePaths );
    _.strsSort( filePaths );

    _.assert( _.arrayIs( filePaths ), 'Expects path or array of paths' );

    for( let p = 0 ; p < filePaths.length ; p++ )
    {
      let filePath = filePaths[ p ];
      let options = Object.assign( Object.create( null ), o );

      delete options.mandatory;
      delete options.orderingExclusion;
      delete options.sortingWithArray;
      delete options.verbosity;
      delete options.sync;
      options.filePath = filePath;

      self.filesFindSingle.body.call( self, options );

    }

  }

}

_.routineExtend( filesFind_body, filesFindSingle.body );

var defaults = filesFind_body.defaults;
defaults.sync = 1;
defaults.orderingExclusion = [];
defaults.sortingWithArray = null;
defaults.verbosity = null;
defaults.mandatory = 0;

_.assert( defaults.maskAll === undefined );
_.assert( defaults.glob === undefined );

let filesFind = _.routineFromPreAndBody( filesFind_pre, filesFind_body );

filesFind.having.aspect = 'entry';

//

let filesFindRecursive = _.routineFromPreAndBody( filesFind_pre, filesFind_body );

var defaults = filesFindRecursive.defaults;
defaults.filePath = null;
defaults.recursive = 2;
defaults.includingTransient = 0;
defaults.includingDirs = 1;
defaults.includingTerminals = 1;
defaults.allowingMissed = 1;
defaults.allowingCycled = 1;

//

function filesGlob( o )
{
  let self = this;

  if( _.strIs( o ) )
  o = { filePath : o }

  if( o.recursive === undefined )
  o.recursive = 2;

  o.filter = o.filter || Object.create( null );

  // if( !o.filter.filePath )
  if( o.filePath )
  {
    // o.filter.filePath = o.filePath;
    // o.filePath = null;
  }
  else
  {
    o.filePath = o.recursive === 2 ? '**' : '*';
  }

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.objectIs( o ) );
  // _.assert( _.strIs( o.filter.filePath ) || _.arrayIs( o.filter.filePath ) || _.mapIs( o.filter.filePath ) );

  let result = self.filesFind( o );

  return result;
}

_.routineExtend( filesGlob, filesFind );

var defaults = filesGlob.defaults;
defaults.outputFormat = 'absolute';
defaults.recursive = 2;
defaults.includingTerminals = 1;
defaults.includingDirs = 1;
defaults.includingTransient = 0;

//

function filesFinder_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( finder, routine );
  return finder;

  function finder()
  {
    let self = this;
    let op0 = self.filesFindLike_pre( arguments );
    // let op0 = self.filesFind.pre.call( self, self.filesFind, arguments );
    _.assertMapHasOnly( op0, finder.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.recordFilter( o.filter );

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( !_.objectIs( op2 ) )
        op2 = { filePath : op2 }

        op2.filter = op2.filter || Object.create( null );
        if( op2.filter.filePath === undefined )
        op2.filter.filePath = '.';
        // if( op2.filter.basePath === undefined )
        // op2.filter.basePath = '.';

        o.filter.and( op2.filter );
        o.filter.pathsJoin( op2.filter );
        o.filePath = self.path.s.joinIfDefined( o.filePath, op2.filePath );

        op2.filter = o.filter;
        op2.filePath = o.filePath;

        _.mapExtend( o, op2 );

      }

      return routine.call( self, o );
    }

  }

}

let filesFinder = filesFinder_functor( filesFind );
let filesGlober = filesFinder_functor( filesGlob );

// --
// files find groups
// --

function filesFindGroups_pre( routine, args )
{
  let self = this;
  let o = self._preFileFilterWithProviderDefaults.apply( self, arguments );

  if( o.dst )
  {
    o.src.pairRefineLight();
    o.dst.form();
  }

  o./*fileFilter*/src.form();

  return o;
}

//

/*
qqq : filesFindGroups requires tests
*/

function filesFindGroups_body( o )
{
  let self = this;
  let path = self.path;
  let con = new _.Consequence();

  _.assert( o./*fileFilter*/src.formed === 5 );

  let r = Object.create( null );
  r.options = o;
  r.pathsGrouped = path.pathMapGroupByDst( o./*fileFilter*/src.filePath );
  r.filesGrouped = Object.create( null );
  r.srcFiles = Object.create( null );
  r.errors = [];

  /* */

  for( let dstPath in r.pathsGrouped ) ( function( dstPath )
  {
    let srcPath = r.pathsGrouped[ dstPath ];
    let o2 = _.mapOnly( o, self.filesFindSingle.body.defaults );

    con.finallyGive( 1 );

    o2.result = [];
    o2.filter = o./*fileFilter*/src.clone();
    o2.filter.filePathSelect( srcPath, dstPath );
    o2.filter.form();

    _.Consequence.From( self.filesFind( o2 ) )
    .finally( ( err, files ) =>
    {

      r.filesGrouped[ dstPath ] = files;
      files.forEach( ( file ) =>
      {
        if( _.strIs( file ) )
        r.srcFiles[ file ] = file;
        else
        r.srcFiles[ file.absolute ] = file;
      });

      if( err )
      {
        r.errors.push( err );
      }

      con.take( null );
      return null;
    });

  })( dstPath );

  /* */

  con.take( null );
  con.finally( () =>
  {
    if( r.errors.length )
    {
      debugger;
      if( o.throwing )
      throw r.errors[ 0 ];
    }
    return r;
  });

  return con.toResourceMaybe();
}

var defaults = filesFindGroups_body.defaults = _.mapExtend( null, filesFind.defaults );

delete defaults.filePath;
delete defaults.filter;

defaults./*fileFilter*/src = null;
defaults./*fileFilter*/dst = null;
defaults.sync = 1;
defaults.throwing = null;
defaults.recursive = 2;

//

let filesFindGroups = _.routineFromPreAndBody( filesFindGroups_pre, filesFindGroups_body );

// function filesRead_pre( routine, args )
// {
//   let self = this;
//   let o = self._preFileFilterWithProviderDefaults.apply( self, arguments );
//
//   o./*fileFilter*/src.form();
//
//   return o;
// }

//

/*
qqq : new filesRead requires tests
*/

function filesRead_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( o./*fileFilter*/src.formed === 5 );

  let con = self.filesFindGroups( o );
  let r;

  /* */

  con = _.Consequence.From( con );

  con.then( ( result ) =>
  {
    r = result;
    r.dataMap = Object.create( null );
    r.grouped = Object.create( null );

    for( let dstPath in r.filesGrouped )
    {
      let files = r.filesGrouped[ dstPath ];
      for( let f = 0 ; f < files.length ; f++ )
      fileRead( files[ f ], dstPath );
    }

    return r;
  });

  return con.toResourceMaybe();

  /* */

  function fileRead( record, dstPath )
  {

    let descriptor = r.grouped[ dstPath ];

    if( !descriptor )
    {
      descriptor = r.grouped[ dstPath ] = Object.create( null );
      descriptor.dstPath = dstPath;
      descriptor.pathsGrouped = r.pathsGrouped[ dstPath ];
      descriptor.filesGrouped = r.filesGrouped[ dstPath ];
      descriptor.dataMap = Object.create( null );
    }

    try
    {
      r.dataMap[ record.absolute ] = self.fileRead({ filePath : record.absolute, sync : o.sync });
      con.finallyGive( 1 );
      _.Consequence.From( r.dataMap[ record.absolute ] )
      .finally( ( err, data ) =>
      {
        if( err )
        {
          r.errors.push( err );
          return null;
        }
        r.dataMap[ record.absolute ] = data;
        descriptor.dataMap[ record.absolute ] = data;
        return null;
      })
      .finally( con );
    }
    catch( err )
    {
      r.errors.push( err );
    }

  }

}

filesRead_body.defaults = Object.create( filesFindGroups.defaults );

let filesRead = _.routineFromPreAndBody( filesFindGroups.pre, filesRead_body );

// --
//
// --

//
// _.routineExtend( filesCopyOld, filesFindDifference );
//
// var defaults = filesCopyOld.defaults;
//
// defaults.verbosity = 1;
// defaults.linking = 0;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;
//
// defaults.removingSource = 0;
// defaults.removingSourceTerminals = 0;
//
// defaults.recursive = 2;
// defaults.allowDelete = 0;
// defaults.allowWrite = 0;
// defaults.allowRewrite = 1;
// defaults.allowRewriteFileByDir = 0;
//
// defaults.tryingPreserve = 1;
// defaults.silentPreserve = 1;
// defaults.preservingTime = 1;

//

function filesCopyWithAdapter( o )
{
  let self = this;

  if( arguments.length === 2 )
  o = { dst : arguments[ 0 ] , src : arguments[ 1 ] }

  _.assert( arguments.length === 1 || arguments.length === 2 );

  if( !o.allowDelete && o.investigateDestination === undefined )
  o.investigateDestination = 0;

  if( o.allowRewrite === undefined )
  o.allowRewrite = filesCopyWithAdapter.defaults.allowRewrite;

  if( o.allowRewrite && o.allowWrite === undefined )
  o.allowWrite = 1;

  if( o.allowRewrite && o.allowRewriteFileByDir === undefined  )
  o.allowRewriteFileByDir = true;

  _.routineOptions( filesCopyWithAdapter, o );
  self._providerDefaults( o );

  /* safe */

  // if( self.safe )
  // if( o.removingSource && ( !o.allowWrite || !o.allowRewrite ) )
  // throw _.err( 'not safe removingSource:1 with allowWrite:0 or allowRewrite:0' );

  o.src = self.path.normalize( o.src );
  o.dst = self.path.normalize( o.dst );

  let options = Object.create( null );
  _.mapExtend( options, _.mapOnly( o, filesReflect.defaults ) );

  /*
    'investigateDestination',
    'verbosity',
    'silentPreserve?',
    'resolvingSoftLink',
    'resolvingTextLink',
    'allowDelete',
    'allowWrite',
    'allowRewrite',
    'allowRewriteFileByDir',
    'removingSourceTerminals',
    'removingSource',
    'tryingPreserve',
    'ext?',
    'maxSize?',
    'usingExtraStat?',
  */

  options.linking = options.linking ? 'hardLink' : 'fileCopy';
  options.srcDeleting = o.removingSource || o.removingSourceTerminals; // check it
  options.dstDeleting = o.allowDelete;
  options.writing = o.allowWrite;
  options.dstRewriting = o.allowRewrite;
  options.dstRewritingByDistinct = o.allowRewriteFileByDir; // check it
  options.preservingTime = o.preservingTime;
  options.preservingSame = o.tryingPreserve; // check it
  options.includingDst = o.investigateDestination;

  /*
  zzz : wrong! resolving*Link and resolvingSoftLink are not related, as well as resolvingTextLink
  Vova : low priority
  */
  options.resolvingSrcSoftLink = o.resolvingSoftLink;
  options.resolvingDstSoftLink = o.resolvingSoftLink;
  options.resolvingSrcTextLink = o.resolvingTextLink;
  options.resolvingDstTextLink = o.resolvingTextLink;

  options.onWriteDstUp = o.onUp;
  options.onWriteDstDown = o.onDown;

  delete options.onUp;
  delete options.onDown;

  options.reflectMap = Object.create( null );
  options.reflectMap[ o.src ] = o.dst;

  // options.srcProvider = self;
  // options.dstProvider = self;

  if( !options.filter )
  options.filter = Object.create( null );

  if( options.filter instanceof _.FileRecordFilter )
  {
    options.srcFilter = options.filter.clone();
    // options.dstFilter = options.filter.clone();
  }
  else
  {
    options.srcFilter = self.recordFilter( options.filter );
    // options.dstFilter = self.recordFilter( options.filter );
  }

  options.filter = null;

  options.srcFilter.effectiveFileProvider = self;
  // options.dstFilter.effectiveFileProvider = self;

  if( o.ext )
  {
    _.assert( _.strIs( o.ext ) );
    _.assert( !o.onDstName, 'o.ext is not compatible with o.onDstName' );
    let ext = o.ext;
    options.onDstName = function( relative, dstRecordFactory, op, o, srcRecord )
    {
      if( !srcRecord.isDir )
      return self.path.changeExt( relative, ext );
      return relative;
    }
  }

  let result = self.filesReflect( options );

  result.forEach( ( r ) =>
  {

    if( !r.relative )
    r.relative = r.effective.relative;

    if( r.action === 'dirMake' )
    if( r.preserve )
    r.action = 'directory preserved';
    else
    r.action = 'directory new';

    if( r.action === 'fileCopy' )
    if( r.preserve )
    r.action = 'same';
    else
    r.action = 'copied'

  })

  return result;
}

filesCopyWithAdapter.defaults =
{
  outputFormat : 'record',
  ext : null,
  investigateDestination : 1,

  maxSize : 1 << 21,
  usingExtraStat : 1,
  recursive : 0,

  includingTerminals : 1,
  includingDirs : 1,

  resolvingSoftLink : 0,
  resolvingTextLink : 0,

  filter : null,
  result : null,
  src : null,
  dst : null,

  onUp : [],
  onDown : [],
}

// filesCopyWithAdapter.defaults.__proto__ = filesFindMasksAdjust.defaults
// var paths = filesCopyWithAdapter.paths = Object.create( null );
// paths.src = null;
// paths.dst = null;

var having = filesCopyWithAdapter.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

// _.routineExtend( filesCopyWithAdapter, filesFindDifference );

var defaults = filesCopyWithAdapter.defaults;

defaults.verbosity = 1;
defaults.linking = 0;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;

defaults.removingSource = 0;
defaults.removingSourceTerminals = 0;

defaults.recursive = 2;
defaults.allowDelete = 0;
defaults.allowWrite = 0;
defaults.allowRewrite = 1;
defaults.allowRewriteFileByDir = 0;

defaults.tryingPreserve = 1;
defaults.silentPreserve = 1;
defaults.preservingTime = 1;


//

function _filesPrepareFilters( routine, o )
{
  let self = this;
  // let hub = self.hub || self;

  _.assert( arguments.length === 2 );

  /* */

  // o.srcFilter = hub.recordFilter( o.srcFilter );
  // o.dstFilter = hub.recordFilter( o.dstFilter );

  o.srcFilter = self.recordFilter( o.srcFilter );
  o.dstFilter = self.recordFilter( o.dstFilter );

  if( o.filter )
  {
    o.srcFilter.and( o.filter ).pathsJoinWithoutNull( o.filter );
    o.dstFilter.and( o.filter ).pathsJoinWithoutNull( o.filter );
  }

  /* */

  _.assert( _.objectIs( o.srcFilter ) );
  _.assert( _.objectIs( o.dstFilter ) );

  _.assert( o.srcFilter.formed <= 1 );
  _.assert( o.dstFilter.formed <= 1 );

  _.assert( _.objectIs( o.srcFilter.defaultFileProvider ) );
  _.assert( _.objectIs( o.dstFilter.defaultFileProvider ) );

  _.assert( !( o.srcFilter.effectiveFileProvider instanceof _.FileProvider.Hub ) );
  _.assert( !( o.dstFilter.effectiveFileProvider instanceof _.FileProvider.Hub ) );

  _.assert( o.srcProvider === undefined );
  _.assert( o.dstProvider === undefined );

}

//

function filesReflectEvaluate_pre( routine, args )
{
  let self = this;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { dstPath : args[ 0 ] , srcPath : args[ 1 ] }

  _.routineOptions( routine, o );
  self._providerDefaults( o );

  o.onUp = _.routinesComposeAll( o.onUp );
  o.onDown = _.routinesCompose( o.onDown );

  if( o.result === null )
  o.result = [];

  if( o.includingDst === null || o.includingDst === undefined )
  o.includingDst = o.dstDeleting;

  self._filesPrepareFilters( routine, o );

  return o;
}

//

function filesReflectEvaluate_body( o )
{
  let self = this;
  let actionMap = Object.create( null );
  let touchMap = Object.create( null );
  let dstDeleteMap = Object.create( null );
  let recordAdd = recordAdd_functor( o );
  let recordRemove = recordRemove_functor( o );

  _.assert( _.strIs( o.dstPath ) );
  _.assert( _.boolLike( o.includingDst ) );
  _.assert( _.boolLike( o.dstDeleting ) );
  _.assert( !o.dstDeleting || o.includingDst );
  _.assert( o.onDstName === null || _.routineIs( o.onDstName ) );
  _.assert( _.arrayIs( o.result ) );
  _.assert( _.arrayHas( [ 'fileCopy', 'hardLink', 'hardLinkMaybe', 'softLink', 'softLinkMaybe', 'nop' ], o.linking ), 'unknown kind of linking', o.linking );
  _.assert( o.outputFormat === 'record', 'not implemented' );
  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assert( _.arrayIs( o.result ) );
  _.assert( _.routineIs( o.onUp ) );
  _.assert( _.routineIs( o.onDown ) );
  _.assertRoutineOptions( filesReflectEvaluate_body, o );

  let srcOptions = srcOptionsForm();
  let dstOptions = dstOptionsForm();
  let dstRecordFactory = dstFactoryForm();
  let dst = o.dstFilter.effectiveFileProvider;
  let src = o.srcFilter.effectiveFileProvider;

  _.assert( o.dstFilter.hubFileProvider.hasProvider( o.dstFilter.effectiveFileProvider ), 'Hub should have destination and source file providers' );
  _.assert( o.srcFilter.hubFileProvider.hasProvider( o.srcFilter.effectiveFileProvider ), 'Hub should have destination and source file providers' );
  _.assert( o.dstFilter.hubFileProvider === o.srcFilter.hubFileProvider, 'Hub should have the same destination and source hub' );
  _.assert( o.dstFilter.effectiveFileProvider === dstRecordFactory.effectiveFileProvider );
  _.assert( o.dstFilter.defaultFileProvider === dstRecordFactory.defaultFileProvider );
  _.assert( o.dstFilter.hubFileProvider === dstRecordFactory.hubFileProvider || o.dstFilter.hubFileProvider === null );
  _.assert( !!o.dstFilter.effectiveFileProvider );
  _.assert( !!o.dstFilter.defaultFileProvider );
  _.assert( !!o.srcFilter.effectiveFileProvider );
  _.assert( !!o.srcFilter.defaultFileProvider );
  _.assert( o.dstFilter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  // _.assert( o.dstFilter.hubFileProvider === o.dstFilter.effectiveFileProvider || o.dstFilter.hubFileProvider instanceof _.FileProvider.Hub );
  // _.assert( o.dstFilter.hubFileProvider === null || o.dstFilter.hubFileProvider instanceof _.FileProvider.Hub );
  _.assert( o.srcFilter.effectiveFileProvider instanceof _.FileProvider.Abstract );
  // _.assert( o.srcFilter.hubFileProvider === o.srcFilter.effectiveFileProvider || o.srcFilter.hubFileProvider instanceof _.FileProvider.Hub );
  // _.assert( o.srcFilter.hubFileProvider === null || o.srcFilter.hubFileProvider instanceof _.FileProvider.Hub );
  _.assert( src.path.s.allAreNormalized( o.srcPath ) );
  _.assert( dst.path.isNormalized( o.dstPath ) );

  /* find */

  // debugger;
  let found = self.filesFind( srcOptions );
  // debugger;

  _.assert( o.mandatory === undefined );

  return o.result;

  /* src options */

  function srcOptionsForm()
  {

    if( !o.srcFilter.formed || o.srcFilter.formed < 5 )
    {

      o.srcFilter.filePath = o.srcPath;
      o.srcFilter.hubFileProvider = o.srcFilter.hubFileProvider || self;

      o.srcFilter._formAssociations();
      o.srcFilter._formPaths();

      o.srcFilter.filePath = o.srcPath;
      o.srcFilter.form();
      o.srcPath = o.srcFilter.filePath;

    }

    _.assert( o.srcPath === o.srcFilter.filePath );

    let srcOptions = _.mapOnly( o, self.filesFindSingle.defaults );
    srcOptions.includingStem = 1;
    srcOptions.includingTransient = 1;
    srcOptions.allowingMissed = 1;
    srcOptions.allowingCycled = 1;
    srcOptions.verbosity = 0;
    srcOptions.maskPreset = 0;
    srcOptions.filter = o.srcFilter;
    srcOptions.filePath = o.srcPath;
    srcOptions.result = null;
    srcOptions.onUp = [ handleSrcUp ];
    srcOptions.onDown = [ handleSrcDown ];
    // srcOptions.resolvingSoftLink = 0;

    _.mapSupplement( srcOptions, self.filesFindSingle.defaults );

    return srcOptions;
  }

  /* dst options */

  function dstOptionsForm()
  {

    if( o.dstFilter.formed < 5 )
    {
      o.dstFilter.hubFileProvider = o.dstFilter.hubFileProvider || self;
      o.dstFilter.filePath = o.dstPath;
      o.dstFilter.form();
      // o.dstPath = o.dstFilter.filePath;
      // debugger;
      o.dstPath = o.dstFilter.filePathSimplest();
    }

    if( _.arrayIs( o.dstPath ) && o.dstPath.length === 1 )
    o.dstPath = o.dstPath[ 0 ];

    // _.assert( o.dstPath === o.dstFilter.filePath );
    _.assert( _.strIs( o.dstPath ) );
    _.assert( _.objectIs( o.dstFilter.basePath ) );
    // _.assert( o.dstFilter.filePath === o.dstPath );
    _.assert( !!o.dstFilter.effectiveFileProvider );
    _.assert( !!o.dstFilter.defaultFileProvider );

    let dstOptions = _.mapExtend( null, srcOptions );
    dstOptions.filter = o.dstFilter;
    dstOptions.filePath = o.dstPath;
    dstOptions.includingStem = 1;
    dstOptions.recursive = 2;
    dstOptions.maskPreset = 0;
    dstOptions.verbosity = 0;
    dstOptions.result = null;
    dstOptions.onUp = [];
    dstOptions.onDown = [ handleDstDown ];
    // dstOptions.resolvingSoftLink = 0;

    return dstOptions;
  }

  /* dst factory */

  function dstFactoryForm()
  {

    // debugger;
    let dstOp =
    {
      basePath : o.dstFilter.basePath[ o.dstPath ],
      stemPath : o.dstPath,
      filter : o.dstFilter,
      allowingMissed : 1,
      allowingCycled : 1,
    }

    if( _.arrayIs( dstOp.stemPath ) && dstOp.stemPath.length === 1 )
    dstOp.stemPath = dstOp.stemPath[ 0 ];

    let dstRecordFactory = _.FileRecordFactory.TollerantFrom( o, dstOp ).form();

    _.assert( _.strIs( dstOp.basePath ) );
    _.assert( dstRecordFactory.basePath === _.uri.parse( o.dstFilter.basePath[ o.dstPath ] ).longPath );

    return dstRecordFactory;
  }

  /* add record to result array */

  function recordAdd_functor( o )
  {
    let routine;

    if( o.outputFormat === 'src.absolute' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
      o.result.push( record );
    }
    else if( o.outputFormat === 'nothing' )
    routine = function add( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.assert( record.include === true );
    }
    else _.assert( 0, 'unexpected output format :', o.outputFormat );

    return routine;
  }

  /* remove record from result array */

  function recordRemove_functor( o )
  {
    let routine;

    if( o.outputFormat === 'src.absolute' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.src.absolute );
    }
    else if( o.outputFormat === 'src.relative' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.src.relative );
    }
    else if( o.outputFormat === 'dst.absolute' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.dst.absolute );
    }
    else if( o.outputFormat === 'dst.relative' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record.dst.relative );
    }
    else if( o.outputFormat === 'record' )
    routine = function remove( record )
    {
      _.assert( arguments.length === 1, 'Expects single argument' );
      _.arrayRemoveElementOnceStrictly( o.result, record );
    }
    else if( o.outputFormat === 'nothing' )
    routine = function remove( record )
    {
    }
    else _.assert( 0, 'unexpected output format :', o.outputFormat );

    return routine;
  }

  /* */

  function recordMake( dstRecord, srcRecord, effectiveRecord )
  {
    _.assert( dstRecord === effectiveRecord || srcRecord === effectiveRecord );
    let record = Object.create( null );
    record.dst = dstRecord;
    record.src = srcRecord;
    record.effective = effectiveRecord;
    record.goingUp = true;
    record.upToDate = false;
    record.srcAction = null;
    record.srcAllow = true;
    record.reason = null;
    record.action = null;
    record.allow = true;
    record.preserve = false;
    record.deleteFirst = false;
    record.touch = false;
    record.include = true;

    dstRecord.associated = record;
    srcRecord.associated = record;

    return record;
  }

  /* */

  function handleUp( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    _.sure( !_.strBegins( record.dst.absolute, '/../' ), () => 'Destination path ' + _.strQuote( record.dst.absolute ) + ' leads out of file system.' );

    if( !record.src.isActual && !record.dst.isActual )
    {
      if( !record.src.isDir && !record.dst.isDir )
      return end( false );
    }

    if( !o.includingDst && record.reason === 'dstDeleting' )
    return end( record );

    if( !o.includingDirs && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    _.assert( _.routineIs( o.onUp ) );
    _.assert( arguments.length === 2 );

    handleUp2.call( self, record, o );

    let result = true;
    let r = o.onUp.call( self, record, o );
    if( r === _.dont )
    return end( false );

    return end( record );

    function end( result )
    {
      if( result && record.include && ( o.includingNonAllowed || record.allow ) )
      {
        recordAdd( record );
      }
      else
      {
        record.include = false;
      }
      return result;
    }

  }

  /* */

  function handleUp2( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    let a = actionMap[ record.dst.absolute ];
    let t = touchMap[ record.dst.absolute ];

    if( !o.writing )
    record.allow = false;

    if( record.reason !== 'srcLooking' && a )
    {
      record.include = false;
      return record
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );

    if( !record.src.stat )
    {
      /* src does not exist or is not actual */

      if( record.reason === 'dstDeleting' && !record.dst.isActual )
      {
      }
      else if( record.reason === 'srcLooking' && record.dst.isActual && record.dst.isDir && !record.src.isActual && record.src.stat )
      {
        record.include = false;
      }
      else if( ( !record.dst.stat && !record.src.isDir ) || ( record.dst.isTerminal && !record.dst.isActual ) )
      {
        debugger;
        record.include = false;
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( record.reason === 'srcLooking' && record.dst.isActual && !record.src.isActual && !record.src.isTransient )
        {
          debugger;
          record.include = false;
          dstDelete( record, op );
        }

      }
      else
      {
        /* src is dir, dst is terminal */

        if( !record.dst.isActual )
        record.include = false;

        if( !record.src.isActual && record.dst.isActual )
        {
        }
        else if( !record.dst.isActual )
        {
          record.goingUp = false;
          ignore( record );
        }
        else if( !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          record.goingUp = false;
          record.allow = false;
          dirMake( record );
          preserve( record );
          forbid( record ); // zzz
        }
        else
        {
          record.deleteFirst = true;
          dirMake( record );
        }

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal, dst does not exist */
        link( record );

      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !record.src.isActual && record.reason !== 'dstDeleting' )
        {
          record.include = false;
        }
        else if( record.src.isActual )
        {
          record.deleteFirst = true;
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( record.src.isActual )
        {

          if( shouldPreserve( record ) )
          record.preserve = true;

          if( !o.writing )
          record.allow = false;

          if( !o.dstRewriting )
          {
            forbid( record );
          }

          link( record );

        }
        else
        {

          if( record.reason !== 'srcLooking' && o.dstDeleting )
          fileDelete( record );
          else
          record.include = false;

          // if( o.dstDeleting ) // yyy
          // fileDelete( record );
          // else
          // record.include = false;

        }

      }

    }

    return record;
  }

  /* */

  function handleDown( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( touchMap[ record.dst.absolute ] )
    touch( record, touchMap[ record.dst.absolute ] );
    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    let srcExists = !!record.src.stat;
    let dstExists = !!record.dst.stat;

    _.assert( !!record.dst && !!record.src );
    _.assert( arguments.length === 2 );

    if( !record.include )
    return end( false );

    if( !record.src.isActual && !record.src.isDir && record.reason === 'srcLooking' ) // yyy
    return end( false );

    // if( !record.dst.isActual && record.reason === 'dstDeleting' ) // yyy
    // return end( false );

    if( !o.includingDst && record.reason === 'dstDeleting' )
    return end( record );

    if( !o.includingDirs && record.effective.isDir )
    return end( record );

    if( !o.includingTerminals && !record.effective.isDir )
    return end( record );

    handleDown2.call( self, record, o );
    let r = o.onDown.call( self, record, o );
    _.assert( r !== _.dont );

    _.assert( record.action !== 'exclude' || record.touch === false, () => 'Attempt to exclude touched ' + record.dst.absolute );

    if( record.action === 'exclude' )
    return end( false );

    _.assert( touchMap[ record.dst.absolute ] === record.touch || !record.touch );

    if( !srcExists && record.reason === 'srcLooking' )
    return end( false );

    if( !record.src.isActual && !record.dst.isActual && !record.touch )
    return end( false );

    if( !o.includingNonAllowed && !record.allow )
    return end( false );

    return end( record.touch );

    function end( result )
    {
      if( result === false )
      {
        if( record.include )
        recordRemove( record );
        record.include = false;
      }
      return result;
    }
  }

  /* */

  function handleDown2( record, op )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 2 );
    _.assert( !!record.touch === !!touchMap[ record.dst.absolute ] );

    if( record.reason === 'srcLooking' )
    {
      if( !record.src.stat )
      debugger;
      if( ( !record.src.isActual || !record.src.stat ) && !record.touch )
      {
        // debugger;
        // ignore( record );
        action( record, 'exclude' );
        // record.include = false;
        return;
      }
    }

    // if( !record.src.stat || ( !record.src.isActual && record.touch !== 'constructive' && !record.action ) )
    if( !record.src.stat )
    {
      /* src does not exist */

      if( record.reason === 'dstRewriting' )
      {
        /* if dst rewriting and src is included */
        if( !o.dstRewriting && record.src.isActual )
        {
          // debugger;
          forbid( record );
        }
      }
      else if( record.reason === 'dstDeleting' )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting ) /* zzz */
        {
          // debugger;
          forbid( record );
        }
      }
      else if( !record.src.isActual )
      {
        /* if dst deleting or src is not included then treat as src does not exist */
        if( !o.dstDeleting )
        {
          debugger;
          forbid( record );
        }
      }

      _.assert( !record.action );
      _.assert( !record.srcAction );
      _.assert( !!record.reason );

      if( record.reason === 'dstDeleting' && !record.dst.isActual && !record.touch )
      {
        ignore( record );
      }
      else if( record.reason !== 'dstDeleting' && ( !record.dst.isActual || !record.dst.stat ) && !record.touch )
      {
        debugger;
        forbid( record );
        action( record, 'exclude' );
      }
      else
      {
        dirDeleteOrPreserve( record, 'ignore' );
      }

    }
    else if( record.src.isDir )
    {

      if( !record.dst.stat )
      {
        /* src is dir, dst does not exist */

        // if( record.reason === 'srcLooking' && touchMap[ record.dst.absolute ] )
        // {
        //
        // }

        if( !record.src.isActual )
        {
          if( record.touch === 'constructive' )
          dirMake( record );
          else
          action( record, 'exclude' );
        }
        else
        {
          dirMake( record );
        }

      }
      else if( record.dst.isDir )
      {
        /* both src and dst are dir */

        if( !record.src.isActual )
        {
          // action( record, 'ignore' );
          // record.include = false;

          if( record.reason === 'srcLooking' && record.dst.isStem )
          {
            dirMake( record );
            preserve( record );
          }
          else
          {
            dirDeleteOrPreserve( record );
          }

        }
        else
        {
          dirMake( record );
        }

      }
      else
      {
        /* src is dir, dst is terminal */

        if( o.dstRewritingPreserving )
        if( o.writing && o.dstRewriting && o.dstRewritingByDistinct )
        {
          debugger;
          throw _.err( 'Can\'t rewrite terminal file ' + record.dst.absolute + ' by directory ' + record.src.absolute + ', dstRewritingPreserving is enabled' );
        }

        if( !record.src.isActual && record.dst.isActual )
        if( record.touch === 'constructive' )
        {
          record.deleteFirst = true;
          dirMake( record );
        }
        else
        {
          // debugger;
          fileDelete( record );
        }

        _.assert( !record.src.isActual || !!record.touch );

      }

    }
    else
    {

      if( !record.dst.stat )
      {
        /* src is terminal file and dst does not exists */
        // _.assert( record.action === o.linking );
      }
      else if( record.dst.isDir )
      {
        /* src is terminal, dst is dir */

        if( !o.writing || !o.dstRewriting || !o.dstRewritingByDistinct )
        {
          // debugger;
          forbid( record );
        }
        else if( o.dstRewritingPreserving )
        {
          debugger;
          // console.log( dst );
          if( record.dst.factory.effectiveFileProvider.filesHasTerminal( record.dst.absolute ) ) // xxx
          throw _.err( 'Can\'t rewrite directory ' + _.strQuote( record.dst.absolute ) + ' by terminal ' + _.strQuote( record.src.absolute ) + ', directory has terminal(s)' );
        }

        if( record.touch === 'constructive' )
        {
          record.preserve = true;
          dirMake( record );
        }
        else
        {
          if( record.src.isActual )
          {
            record.deleteFirst = true;
            link( record );
          }
          else
          {
            _.assert( record.deleteFirst === false );
            if( !o.dstDeleting )
            {
              debugger;
              forbid( record );
            }
            if( !record.dst.isActual && record.touch !== 'destructive' )
            {
              debugger;
              forbid( record );
            }

            dirDeleteOrPreserve( record );
          }
        }

      }
      else
      {
        /* both src and dst are terminals */

        if( o.writing && o.dstRewriting && o.dstRewritingPreserving )
        if( !self.filesAreSame( record.src, record.dst, true ) )
        if( record.src.stat.size !== 0 || record.dst.stat.size !== 0 )
        {
          debugger;
          let same = self.filesAreSame( record.src, record.dst, true );
          debugger;
          throw _.err
          (
            'Can\'t rewrite' + ' ' + 'terminal file ' + _.strQuote( record.dst.absolute ) + '\n' +
            'by terminal file ' + _.strQuote( record.src.absolute ) + '\n' +
            'files have different content'
          );
        }
      }

    }

    _.assert( !!record.reason );
    _.assert( !record.srcAction );
    _.assert( _.strIs( record.action ), () => 'Action for record ' + _.strQuote( record.src.relative ) + ' was not defined' );

    srcDeleteMaybe( record );

    return record;
  }

  /* */

  function handleDstUp( srcContext, reason, dstFilter, dstRecord, op )
  {

    // debugger;
    // if( _.strEnds( dstRecord.absolute, debugPath ) )
    // debugger;

    _.assert( arguments.length === 5 );
    _.assert( _.strIs( reason ) );
    let srcRecord = srcContext.record( dstRecord.relative );
    let record = recordMake( dstRecord, srcRecord, dstRecord );
    record.reason = reason;

    if( handleUp( record, op ) === false )
    record.include = false;

    return dstRecord;
  }

  /* */

  function handleDstDown( dstRecord, op )
  {
    let record = dstRecord.associated;
    handleDown( record, op );
    return record;
  }

  /* */

  function handleSrcUp( srcRecord, op )
  {
    let relative = srcRecord.relative;
    if( o.onDstName )
    relative = o.onDstName.call( self, relative, dstRecordFactory, op, o, srcRecord );

    let dstRecord = dstRecordFactory.record( relative );
    let record = recordMake( dstRecord, srcRecord, srcRecord );
    record.reason = 'srcLooking';

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;
    let isSoftLink = record.dst.isSoftLink;

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      {
        o.filesGraph.dstPath = o.dstPath;
        o.filesGraph.srcPath = o.srcPath;
        o.filesGraph.actionBegin( o.dstPath + ' <- ' + o.srcPath );
      }
      if( !record.src.isDir )
      {
        o.filesGraph.filesUpdate( record.dst );
        o.filesGraph.filesUpdate( record.src );
        if( o.filesGraph.fileIsUpToDate( record.dst ) )
        record.upToDate = true;
      }
    }

    /* */

    handleUp( record, op );

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    // if( o.includingDst && record.include && record.src.isActual && record.src.stat )
    if( record.include && record.src.isActual && record.src.stat )
    if( record.dst.isDir && !record.src.isDir )
    {
      /* src is terminal, dst is dir */

      _.assert( _.strIs( record.dst.factory.basePath ) );
      let filter2 = self.recordFilter
      ({
        effectiveFileProvider : dstOptions.filter.effectiveFileProvider,
        hubFileProvider : dstOptions.filter.hubFileProvider,
      });
      filter2.filePath = null;
      filter2.basePath = record.dst.factory.basePath;

      let dstOptions2 = _.mapExtend( null, dstOptions );
      dstOptions2.filePath = record.dst.absolute;
      dstOptions2.filter = filter2;
      dstOptions2.filter.filePath = null;
      dstOptions2.includingStem = 0;
      dstOptions2.onUp = [ _.routineJoin( undefined, handleDstUp, [ srcRecord.factory, 'dstRewriting', filter2 ] ) ];

      let found = self.filesFind( dstOptions2 );

    }

    /* */

    if( record.include && record.goingUp )
    return srcRecord;
    else
    return _.dont;
  }

  /* */

  function handleSrcDown( srcRecord, op )
  {
    let record = srcRecord.associated;

    if( o.filesGraph && !record.src.isDir && !record.upToDate )
    {
      record.dst.reval();
      o.filesGraph.dependencyAdd( record.dst, record.src );
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    dstDelete( record, op );
    handleDown( record, op );

    if( o.filesGraph )
    {
      if( record.dst.absolute === o.dstPath )
      o.filesGraph.actionEnd();
    }

    return record;
  }

  function dstDelete( record, op )
  {

    if( !o.includingDst )
    return;
    if( !record.dst.isDir || !record.src.isDir )
    return;

    _.assert( _.strIs( record.dst.factory.basePath ) );
    _.assert( _.strIs( record.src.factory.basePath ) );

    let dstFiles = record.dst.factory.effectiveFileProvider.dirRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
    let dstRecords = record.dst.factory.records( dstFiles );
    let srcFiles = record.src.factory.effectiveFileProvider.dirRead({ filePath : record.src.absolute, outputFormat : 'absolute' });
    let srcRecords = record.src.factory.records( srcFiles );

    for( let f = dstRecords.length-1 ; f >= 0 ; f-- )
    {
      let dstRecord = dstRecords[ f ];
      let srcRecord = _.arrayLeft( srcRecords, dstRecord, ( r ) => r.relative ).element;
      if( !srcRecord )
      continue;
      if( !srcRecord.isActual )
      continue;
      dstRecords.splice( f, 1 );
    }

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    for( let f = 0 ; f < dstRecords.length ; f++ )
    {
      let dstRecord = dstRecords[ f ];

      if( dstDeleteMap[ dstRecord.absolute ] )
      continue;

      dstDeleteTouch( dstRecord );

      let dstOptions2 = _.mapExtend( null, dstOptions );
      dstOptions2.filePath = dst.path.join( record.dst.factory.basePath, dstRecord.absolute );
      dstOptions2.filter = dstOptions2.filter.clone();
      dstOptions2.filter.filePath = null;
      dstOptions2.filter.filePath = null;
      dstOptions2.filter.basePath = record.dst.factory.basePath;
      dstOptions2.onUp = [ _.routineJoin( null, handleDstUp, [ record.src.factory, 'dstDeleting', null ] ) ];

      let found = self.filesFind( dstOptions2 );

    }

  }

  /* */

  function dstDeleteTouch( record )
  {

    _.assert( _.strIs( o.dstPath ) );
    _.assert( _.strIs( record.absolute ) );
    _.assert( arguments.length === 1 );

    let absolutePath = record.absolute;
    dstDeleteMap[ absolutePath ] = 1;

    do
    {
      absolutePath = dst.path.dir( absolutePath );
      dstDeleteMap[ absolutePath ] = 1;
    }
    while( absolutePath !== o.dstPath && absolutePath !== '/' );

  }

  /* touch */

  function action( record, action )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    _.assert( _.strIs( o.dstPath ) );
    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'exclude', 'ignore', 'fileDelete', 'dirMake', 'fileCopy', 'softLink', 'hardLink', 'nop' ], action ), () => 'Unknown action ' + _.strQuote( action ) );

    let absolutePath = record.dst.absolute;
    let result = actionMap[ absolutePath ] === action;

    _.assert( record.action === null );
    record.action = action;

    if( action === 'exclude' || action === 'ignore' )
    {
      _.assert( actionMap[ absolutePath ] === undefined );
      return result;
    }

    actionMap[ absolutePath ] = action;

    return result
  }

  /* touch */

  function touch( record, kind )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    kind = kind || 'constructive';

    _.assert( _.strIs( o.dstPath ) );
    _.assert( arguments.length === 2 );
    _.assert( _.arrayHas( [ 'src', 'constructive', 'destructive' ], kind ) );

    let absolutePath = record.dst.absolute;
    kind = touchAct( absolutePath, kind );

    record.touch = kind;

    while( absolutePath !== o.dstPath && absolutePath !== '/' )
    {
      absolutePath = dst.path.dir( absolutePath );
      touchAct( absolutePath, kind );
    }

    if( kind === 'destructive' )
    {
      for( let m in touchMap )
      if( _.strBegins( m, absolutePath ) )
      touchMap[ m ] = 'destructive';
    }

/*
    if( Config.debug && kind === 'destructive' )
    {
      for( let m in touchMap )
      if( _.strBegins( m, absolutePath ) && touchMap[ m ] !== 'destructive' )
      {
        touchMap[ m ] = 'destructive';
      }
    }
*/

  }

  /* touchAct */

  function touchAct( absolutePath, kind )
  {

    if( kind === 'src' && touchMap[ absolutePath ] )
    return touchMap[ absolutePath ];

    if( kind === 'destructive' && touchMap[ absolutePath ] === 'constructive' )
    return touchMap[ absolutePath ];

    touchMap[ absolutePath ] = kind;

    return kind;
  }

  /* */

  function dirHaveFiles( record )
  {
    if( !record.dst.isDir )
    return false;
    if( touchMap[ record.dst.absolute ] === 'constructive' )
    return true;
    let files = record.dst.factory.effectiveFileProvider.dirRead({ filePath : record.dst.absolute, outputFormat : 'absolute' });
    files = files.filter( ( file ) => actionMap[ file ] !== 'fileDelete' );
    return !!files.length;
  }

  /* */

  function shouldPreserve( record )
  {

    if( !o.preservingSame )
    return false;

    if( record.upToDate )
    return true;

    if( o.linking === 'fileCopy' )
    {
      if( self.filesAreSame( record.dst, record.src, true ) )
      return true;
    }

    return false;
  }

  /* */

  function dirDeleteOrPreserve( record, preserveAction )
  {
    _.assert( !record.action );
    if( !preserveAction )
    preserveAction = 'dirMake';

    if( dirHaveFiles( record ) ) /* zzz */
    {
      /* preserve dir if it has filtered out files */
      if( preserveAction === 'dirMake' )
      {
        dirMake( record );
        _.assert( record.preserve === true );
      }
      else
      ignore( record );
    }
    else
    {
      if( !o.writing )
      record.allow = false;

      if( !o.dstDeletingCleanedDirs )
      if( record.dst.isDir && !record.dst.isActual )
      return ignore( record );

      fileDelete( record );
    }

    return record;
  }

  /* */

  function preserve( record )
  {
    _.assert( _.strIs( record.action ) );
    record.preserve = true;
    touch( record, 'constructive' );
    return record;
  }

  /* */

  function link( record )
  {
    _.assert( !record.action );
    _.assert( !record.upToDate );

    if( !record.src.isActual )
    {
      record.include = false;
      return;
    }

    let linking = o.linking;
    if( _.strHas( linking, 'Maybe' ) )
    {
      if( src === dst )
      linking = _.strRemoveEnd( linking, 'Maybe' );
      else
      linking = 'fileCopy';
    }

    action( record, linking );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function dirMake( record )
  {
    _.assert( !record.action );

    if( record.dst.isDir || actionMap[ record.dst.absolute ] === 'dirMake' )
    record.preserve = true;

    action( record, 'dirMake' );
    touch( record, 'constructive' );

    return record;
  }

  /* */

  function ignore( record )
  {
    _.assert( !record.action );
    touch( record, 'constructive' );
    action( record, 'ignore' );
    record.preserve = true;
    record.allow = false;
    return record;
  }

  /* */

  function forbid( record )
  {
    delete actionMap[ record.dst.absolute ];
    // delete touchMap[ record.dst.absolute ];
    record.allow = false;
    return record;
  }

  /* */

  function fileDelete( record )
  {
    _.assert( !record.action );

    // if( record.reason === 'dstDeleting' && !o.dstDeleting )
    // {
    //   debugger;
    //   forbid( record );
    // }

    action( record, 'fileDelete' );
    touch( record, 'destructive' );

    if( record.reason === 'dstDeleting' && !o.dstDeleting )
    {
      // debugger;
      forbid( record );
    }

  }

  /* */

  function srcDeleteMaybe( record )
  {

    if( !o.srcDeleting )
    return false;
    if( !record.src.isActual )
    return false;
    if( !record.allow )
    return false;
    if( !record.include )
    return false;

    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.allow )
    if( !record.src.stat )
    {
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'dirMake' || record.action === 'fileDelete' );
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }
    else
    {
      record.srcAction = 'fileDelete';
      record.srcAllow = !!o.writing;
      touch( record, 'src' )
    }

  }

}

let filesReflectSingleDefaults = Object.create( null );
var defaults = filesReflectSingleDefaults;

defaults.filesGraph = null;
defaults.filter = null;
defaults.srcFilter = null;
defaults.dstFilter = null;

defaults.result = null;
defaults.outputFormat = 'record';
defaults.verbosity = 0;

// defaults.mandatory = 0;

defaults.allowingMissed = 0;
defaults.allowingCycled = 0;
defaults.includingTerminals = 1;
defaults.includingDirs = 1;
defaults.includingNonAllowed = 1;
// defaults.includingTransient = 1;
// defaults.includingStem = 1;
defaults.includingDst = null;

defaults.recursive = 2;
// defaults.resolvingSoftLink = 0;
// defaults.resolvingTextLink = 0;

defaults.linking = 'fileCopy';
defaults.writing = 1;
defaults.srcDeleting = 0;
defaults.dstDeleting = 0;
defaults.dstDeletingCleanedDirs = 1;
defaults.dstRewriting = 1;
defaults.dstRewritingByDistinct = 1;
defaults.dstRewritingPreserving = 0;
defaults.preservingTime = 0;
defaults.preservingSame = 0;

defaults.extra = null;
defaults.onUp = null;
defaults.onDown = null;
defaults.onDstName = null;

var defaults = filesReflectEvaluate_body.defaults = Object.create( filesReflectSingleDefaults );
defaults.srcPath = null;
defaults.dstPath = null;

var having = filesReflectEvaluate_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectEvaluate = _.routineFromPreAndBody( filesReflectEvaluate_pre, filesReflectEvaluate_body );
filesReflectEvaluate.having.aspect = 'entry';

//

function filesReflectSingle_pre( routine, args )
{
  let self = this;

  // let o = args[ 0 ]
  // if( args.length === 2 )
  // o = { [ args[ 1 ] ] : args[ 0 ] }
  //
  // _.assert( arguments.length === 2 )
  // _.assert( args.length === 1 || args.length === 1 )
  // let o = self.filesReflectEvaluate.pre.call( self, routine, [ o ] );

  let o = self.filesReflectEvaluate.pre.call( self, routine, args );

  o.onWriteDstUp = _.routinesCompose( o.onWriteDstUp );
  o.onWriteDstDown = _.routinesCompose( o.onWriteDstDown );
  o.onWriteSrcUp = _.routinesCompose( o.onWriteSrcUp );
  o.onWriteSrcDown = _.routinesCompose( o.onWriteSrcDown );

  return o;
}

//

function filesReflectSingle_body( o )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 1, 'Expects single argument' );
  _.assertRoutineOptions( filesReflectSingle_body, o );
  _.assert( o.mandatory === undefined );

  _.assert( o.srcFilter.dstFilter === o.dstFilter );
  _.assert( o.dstFilter.srcFilter === o.srcFilter );

  let o2 = _.mapOnly( o, self.filesReflectEvaluate.body.defaults );
  o2.outputFormat = 'record';
  _.assert( _.arrayIs( o2.result ) );
  self.filesReflectEvaluate.body.call( self, o2 );
  _.assert( o2.result === o.result );

  let dirsMap = Object.create( null );
  let hub = self.hub || self;
  let src = o.srcFilter.effectiveFileProvider;
  let dst = o.dstFilter.effectiveFileProvider;

  /* */

  if( o.writing )
  forEach( writeDstUp1, writeDstDown1 );

  if( o.writing )
  forEach( writeDstUp2, writeDstDown2 );

  /* */

  if( o.writing && o.srcDeleting )
  forEach( writeSrcUp, writeSrcDown );

  /* */

  return o.result;

  /* - */

  function forEach( up, down )
  {
    let filesStack = [];

    for( let r = 0 ; r < o.result.length ; r++ )
    {
      let record = o.result[ r ];

      while( filesStack.length && !_.strBegins( record.dst.absolute, filesStack[ filesStack.length-1 ].dst.absolute ) )
      down( filesStack.pop() );
      filesStack.push( record );

      up( record );
    }

    while( filesStack.length )
    down( filesStack.pop() );

  }

  /*  */

  function writeDstUp1( record )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    // if( record.deleteFirst )
    // dstDelete( record );
    //
    // if( _.arrayHas( [ 'fileCopy', 'softLink', 'hardLink', 'nop' ], record.action ) )
    // link( record );
    // else if( record.action === 'fileDelete' )
    // {
    //   // dstDelete( record );
    // }
    // else if( record.action === 'dirMake' )
    // dstDirectoryMake( record );
    // else if( record.action === 'ignore' )
    // {}
    // else _.assert( 0, 'Not implemented action ' + record.action );

    return onr;
  }

  /* */

  function writeDstDown1( record )
  {

    if( record.deleteFirst )
    dstDelete( record );
    else if( record.action === 'fileDelete' )
    dstDelete( record );

    // if( record.deleteFirst )
    // dstDelete( record );
    //
    // if( _.arrayHas( [ 'fileCopy', 'softLink', 'hardLink', 'nop' ], record.action ) )
    // link( record );
    // else if( record.action === 'fileDelete' )
    // dstDelete( record );
    // else if( record.action === 'dirMake' )
    // dstDirectoryMake( record );
    // else if( record.action === 'ignore' )
    // {}
    // else _.assert( 0, 'Not implemented action ' + record.action );

    // let onr = o.onWriteDstDown.call( self, record, o );
    // _.assert( _.boolsAllAre( onr ) );
    // onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    // _.assert( _.boolIs( onr ) );
    // return onr;

  }

  /*  */

  function writeDstUp2( record )
  {

    // // if( _.strEnds( record.dst.absolute, debugPath ) )
    // // debugger;
    //
    // // let onr = o.onWriteDstUp.call( self, record, o );
    // // _.assert( _.boolsAllAre( onr ) );
    // // onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    // // _.assert( _.boolIs( onr ) );
    //
    // /* */
    //
    // if( !onr )
    // return onr;
    //
    // // if( record.deleteFirst )
    // // dstDelete( record );

    let linking = _.arrayHas( [ 'fileCopy', 'hardLink', 'softLink', 'textLink', 'nop' ], record.action );
    if( linking && record.allow && !path.isRoot( record.dst.absolute ) )
    {

      let dirPath = record.dst.dir;
      if( !dirsMap[ dirPath ] )
      {
        for( let d in dirsMap )
        if( _.strBegins( dirPath, d ) )
        {
          // debugger;
          dirsMap[ dirPath ] = true;
          break;
        }
        if( !dirsMap[ dirPath ] )
        {
          record.dst.factory.effectiveFileProvider.dirMake
          ({
            recursive : 1,
            rewritingTerminal : 0,
            filePath : dirPath,
          });
          dirsMap[ dirPath ] = true;
        }
      }

      // // do
      // {
      //   // dirsMap[ dirPath ] = true;
      //   // debugger;
      //   // if( dirsMap[ dirPath ] )
      //   // let dirPaths = path.chainToRoot( record.dst.absolute ); debugger; xxx
      //   // _.mapSet( dirsMap, dirPath, true );
      //   // dirsMap[ record.dst.absolute ] = true;
      //   // debugger;
      // }

    }

    if( linking )
    link( record );
    else if( record.action === 'fileDelete' )
    {
      // dstDelete( record );
    }
    else if( record.action === 'dirMake' )
    dstDirectoryMake( record );
    else if( record.action === 'ignore' )
    {}
    else _.assert( 0, 'Not implemented action ' + record.action );

    // return onr;
  }

  /* */

  function writeDstDown2( record )
  {

    // if( record.action === 'fileDelete' )
    // dstDelete( record );
    //
    // if( record.deleteFirst )
    // dstDelete( record );
    //
    // if( _.arrayHas( [ 'fileCopy', 'softLink', 'hardLink', 'nop' ], record.action ) )
    // link( record );
    // else if( record.action === 'fileDelete' )
    // dstDelete( record );
    // else if( record.action === 'dirMake' )
    // dstDirectoryMake( record );
    // else if( record.action === 'ignore' )
    // {}
    // else _.assert( 0, 'Not implemented action ' + record.action );

    let onr = o.onWriteDstDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  /* */

  function writeSrcUp( record )
  {

    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    let onr = o.onWriteDstUp.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );

    /* */

    if( !onr )
    return onr;

    return onr;
  }

  /* */

  function writeSrcDown( record )
  {
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    srcDeleteMaybe( record );

    let onr = o.onWriteSrcDown.call( self, record, o );
    _.assert( _.boolsAllAre( onr ) );
    onr = _.all( onr, ( e ) => e === _.dont ? false : e );
    _.assert( _.boolIs( onr ) );
    return onr;
  }

  /* */

  function dstDirectoryMake( record )
  {

    if( !record.allow )
    return;
    if( record.preserve )
    return;

    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual || !!record.touch );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    record.dst.factory.effectiveFileProvider.dirMake
    ({
      recursive : 1,
      rewritingTerminal : 0,
      filePath : record.dst.absolute,
    });

  }

  /* */

  function dstDelete( record )
  {
    if( !record.allow )
    return;
    if( record.dst.absolute === record.src.absolute )
    return;
    record.dst.factory.effectiveFileProvider.fileDelete( record.dst.absolute );
    // record.dst.factory.effectiveFileProvider.filesDelete( record.dst.absolute );
  }

  /* */

  function link( record )
  {

    _.assert( !record.upToDate );
    _.assert( !!record.src.isActual );
    _.assert( !!record.touch );
    _.assert( !!record.action );

    if( !record.allow || record.preserve )
    return;

    if( record.action === 'hardLink' )
    {
      /* zzz : should not change time of file if it is already linked */

      dst.hardLink
      ({
        dstPath : record.dst.absolute,
        srcPath : record.src.absolute,
        makingDirectory : 0,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });

    }
    else if( record.action === 'softLink' )
    {
      /* zzz : should not change time of file if it is already linked */

      hub.softLink
      ({
        dstPath : record.dst.absoluteGlobalMaybe,
        srcPath : record.src.absoluteGlobalMaybe,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( record.action === 'textLink' )
    {
      hub.textLink
      ({
        dstPath : record.dst.absoluteGlobalMaybe,
        srcPath : record.src.absoluteGlobalMaybe,
        makingDirectory : 0,
        allowingMissed : 1,
        allowingCycled : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( record.action === 'fileCopy' )
    {
      hub.fileCopy
      ({
        dstPath : record.dst.absoluteGlobalMaybe,
        srcPath : record.src.absoluteGlobalMaybe,
        makingDirectory : 0,
        allowingMissed : 1,
        resolvingSrcSoftLink : o.resolvingSrcSoftLink,
        resolvingSrcTextLink : o.resolvingSrcTextLink,
        resolvingDstSoftLink : o.resolvingDstSoftLink,
        resolvingDstTextLink : o.resolvingDstTextLink,
      });
    }
    else if( record.action === 'nop' )
    {
    }
    else _.assert( 0 );

  }

  /* */

  function srcDeleteMaybe( record )
  {
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( !record.srcAllow || !record.srcAction )
    return false;

    srcDelete( record );
  }

  /* delete src */

  function srcDelete( record )
  {

    /* record.dst.isActual could be false */

    _.assert( !!record.src.isActual );
    _.assert( !!record.include );
    _.assert( !!record.allow );
    _.assert( !!record.action );
    _.assert( !!o.srcDeleting );
    _.assert( record.srcAction === 'fileDelete' );

    // debugger;
    // if( _.strEnds( record.dst.absolute, debugPath ) )
    // debugger;

    if( record.allow )
    if( !record.src.stat || !record.src.isActual )
    {
      debugger;
      _.assert( 0, 'not tested' );
    }
    else if( record.src.isDir )
    {
      _.assert( record.action === 'dirMake' || record.action === 'fileDelete' );
      if( !record.src.factory.effectiveFileProvider.dirRead( record.src.absolute ).length )
      {
        record.src.factory.effectiveFileProvider.fileDelete( record.src.absolute );
      }
      else
      {
        record.srcAllow = false;
      }
    }
    else
    {
      _.assert( record.action === 'fileCopy' || record.action === 'hardLink' || record.action === 'softLink' || record.action === 'nop' );
      record.src.factory.effectiveFileProvider.fileDelete( record.src.absolute );
    }

  }

}

var defaults = filesReflectSingle_body.defaults = Object.create( filesReflectSingleDefaults );

defaults.srcPath = null;
defaults.dstPath = null;

defaults.onWriteDstUp = null;
defaults.onWriteDstDown = null;
defaults.onWriteSrcUp = null;
defaults.onWriteSrcDown = null;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;

var having = filesReflectSingle_body.having = Object.create( null );
having.writing = 0;
having.reading = 1;
having.driving = 0;

let filesReflectSingle = _.routineFromPreAndBody( filesReflectSingle_pre, filesReflectSingle_body );
filesReflectSingle.having.aspect = 'entry';

//

function filesReflect_pre( routine, args )
{
  let self = this;
  let path = self.path;

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 || args.length === 2 );

  let o = args[ 0 ]
  if( args.length === 2 )
  o = { reflectMap : { [ args[ 1 ] ] : args[ 0 ] } }

  self.filesReflectSingle.pre.call( self, routine, args );

  _.assert( o.dstFilter.filePath === null || o.dstFilter.filePath === '.' || o.reflectMap === null );
  _.assert( o.srcFilter.filePath === null || o.srcFilter.filePath === '.' || o.srcFilter.filePath === o.reflectMap || o.reflectMap === null );
  _.assert( o.filter === null || o.srcFilter.filePath === '.' || o.filter.filePath === null || o.filter.filePath === undefined );

  if( o.reflectMap )
  {
    if( Config.debug )
    if( o.srcFilter.filePath !== null && o.reflectMap !== null )
    if( o.srcFilter.filePath !== '.' && o.reflectMap !== '.' )
    if( o.srcFilter.filePath !== o.reflectMap )
    {
      let filePath1 = path.pathMapExtend( null, o.srcFilter.filePath );
      let filePath2 = path.pathMapExtend( null, o.reflectMap );
      _.assert( _.entityIdentical( filePath1, filePath2 ) );
    }
    o.srcFilter.filePath = o.reflectMap;
    o.reflectMap = null;
  }

  o.srcFilter.pairWithDst( o.dstFilter );
  o.srcFilter.pairRefine();
  o.dstFilter._formPaths();
  o.srcFilter._formPaths();

  _.assert( _.mapIs( o.srcFilter.filePath ), 'Cant deduce source filter' );
  _.assert( _.mapIs( o.dstFilter.filePath ), 'Cant deduce destination filter' );
  _.assert( o.srcFilter.filePath === o.dstFilter.filePath );

  // o.reflectMap = o.srcFilter.formedFilePath;
  // o.reflectMap = o.srcFilter.filePath;

  _.assert( o.filter === null || o.filter.filePath === null || o.filter.filePath === undefined );
  // _.assert( o.srcFilter.formedFilePath === o.reflectMap );
  // _.assert( o.dstFilter.formedFilePath === o.reflectMap );

  // debugger;
  // _.assert( _.mapIs( o.reflectMap ) || o.reflectMap === null, 'Expects reflect map' );
  // _.assert( _.mapIs( o.reflectMap ), 'Expects reflect map' );
  _.assert( o.reflectMap === null );
  _.assert( o.dstPath === undefined );
  _.assert( o.srcPath === undefined );

  // _.assert( _.all( o.reflectMap, ( e, k ) => path.is( k ) ) );
  // _.assert( _.all( o.reflectMap, ( e, k ) => e === false || path.is( e ) || path.s.allAre( e ) ) );
  _.assert( o.srcFilter.formed <= 3 );
  _.assert( o.dstFilter.formed <= 3 );

  // _.assert( o.reflectMap === null );

  return o;
}

//

function filesReflect_body( o )
{
  let self = this;
  let path = self.path;
  let cons = [];
  let time;

  if( o.verbosity >= 1 )
  time = _.timeNow();

  _.assertRoutineOptions( filesReflect_body, o );
  _.assert( arguments.length === 1, 'Expects single argument' );
  // _.assert( o.srcFilter.formed <= 3 );
  // _.assert( o.dstFilter.formed <= 3 );
  _.assert( o.srcFilter.formed === 3 );
  _.assert( o.dstFilter.formed === 3 );
  _.assert( o.dstFilter.srcFilter === o.srcFilter );
  _.assert( o.srcFilter.dstFilter === o.dstFilter );

  /* */

  // let groupedByDstMap = path.pathMapGroupByDst( o.reflectMap );
  // debugger;
  let groupedByDstMap = path.pathMapGroupByDst( o.srcFilter.filePath );
  // debugger;
  for( let dstPath in groupedByDstMap )
  {

    let srcPath = groupedByDstMap[ dstPath ];
    let o2 = _.mapOnly( o, self.filesReflectSingle.body.defaults );

    o2.result = [];
    o2.srcFilter = o2.srcFilter.pairFor( srcPath, dstPath );
    o2.dstFilter = o2.srcFilter.dstFilter;

    o2.srcPath = o2.srcFilter.filePath;
    o2.dstPath = o2.dstFilter.filePathSimplest();

    let src = o2.srcFilter.effectiveFileProvider;
    _.assert( _.routineIs( src.filesReflectSingle ), () => 'Method filesReflectSingle is not implemented' );
    let r = src.filesReflectSingle.body.call( src, o2 );
    cons.push( r );

    if( _.consequenceIs( r ) )
    r.ifNoErrorThen( ( arg ) => _.arrayAppendArray( o.result, o2.result ) );
    else
    _.arrayAppendArray( o.result, o2.result );

  }

  /* */

  if( _.any( cons, ( con ) => _.consequenceIs( con ) ) )
  {
    let con = new _.Consequence().take( null ).andKeep( cons );
    con.ifNoErrorThen( end );
    return con;
  }

  return end();

  /* */

  function end()
  {

    if( o.mandatory )
    if( !o.result.length )
    {
      let srcFilter = o.srcFilter.cloneBoth();
      srcFilter.form();
      srcFilter.dstFilter.form();
      let src = srcFilter.filePathSrcCommon();
      let dst = srcFilter.dstFilter.filePathDstCommon();
      throw _.err( 'Error. No file moved :', path.moveReport( dst, src ) );
    }

    if( o.verbosity >= 1 )
    {
      let srcFilter = o.srcFilter.cloneBoth();
      srcFilter.form();
      srcFilter.dstFilter.form();
      let src = srcFilter.filePathSrcCommon();
      let dst = srcFilter.dstFilter.filePathDstCommon();
      self.logger.log( ' + Reflect ' + o.result.length + ' files ' + path.moveReport( dst, src ) + ' in ' + _.timeSpent( time ) );
    }

    return o.result;
  }

}

var defaults = filesReflect_body.defaults = Object.create( filesReflectSingleDefaults );

defaults.reflectMap = null;
defaults.mandatory = 0;

defaults.onWriteDstUp = null;
defaults.onWriteDstDown = null;
defaults.onWriteSrcUp = null;
defaults.onWriteSrcDown = null;

defaults.breakingSrcHardLink = null;
defaults.resolvingSrcSoftLink = null;
defaults.resolvingSrcTextLink = null;
defaults.breakingDstHardLink = null;
defaults.resolvingDstSoftLink = null;
defaults.resolvingDstTextLink = null;

let filesReflect = _.routineFromPreAndBody( filesReflect_pre, filesReflect_body );

//

function filesReflector_functor( routine )
{

  _.assert( arguments.length === 1 );
  _.assert( _.routineIs( routine ) );
  _.routineExtend( reflector, routine );
  return reflector;

  function reflector()
  {
    let self = this;
    let op0 = self.filesFindLike_pre( arguments );
    _.assertMapHasOnly( op0, reflector.defaults );
    return er;

    function er()
    {
      let o = _.mapExtend( null, op0 );
      o.filter = self.recordFilter( o.filter );
      o.srcFilter = self.recordFilter( o.srcFilter );
      o.dstFilter = self.recordFilter( o.dstFilter );

      for( let a = 0 ; a < arguments.length ; a++ )
      {
        let op2 = arguments[ a ];

        if( _.strIs( op2 ) )
        op2 = { reflectMap : { [ op2 ] : true } }

        op2.filter = op2.filter || Object.create( null );
        op2.srcFilter = op2.srcFilter || Object.create( null );
        if( op2.srcFilter.filePath === undefined )
        op2.srcFilter.filePath = '.';
        // if( op2.srcFilter.basePath === undefined )
        // op2.srcFilter.basePath = '.';

        op2.dstFilter = op2.dstFilter || Object.create( null );

        o.filter.and( op2.filter );
        o.filter.pathsJoin( op2.filter );
        o.srcFilter.and( op2.srcFilter );
        o.srcFilter.pathsJoin( op2.srcFilter );
        o.dstFilter.and( op2.dstFilter );
        o.dstFilter.pathsJoin( op2.dstFilter );

        if( op2.reflectMap )
        {
          if( _.strIs( o.reflectMap ) )
          o.reflectMap = { [ o.reflectMap ] : true }
          if( _.strIs( op2.reflectMap ) )
          op2.reflectMap = { [ op2.reflectMap ] : true }
          o.reflectMap = _.mapExtend( o.reflectMap || null, op2.reflectMap );
        }

        op2.reflectMap = o.reflectMap;
        op2.filter = o.filter;
        op2.srcFilter = o.srcFilter;
        op2.dstFilter = o.dstFilter;

        _.mapExtend( o, op2 );
      }

      return routine.call( self, o );
    }

  }

}

let filesReflector = filesReflector_functor( filesReflect );

//

function filesReflectTo_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  if( args[ 1 ] !== undefined || !_.mapIs( args[ 0 ] ) )
  o = { dstProvider : args[ 0 ], dstPath : args[ 1 ] }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( 1 === args.length || 2 === args.length );
  _.routineOptions( routine, o );
  _.assert( o.dstProvider instanceof _.FileProvider.Abstract, () => 'Expects file provider {- o.dstProvider -}, but got ' + _.strType( o.dstProvider ) );
  _.assert( path.isAbsolute( o.dstPath ) );
  _.assert( path.isAbsolute( o.srcPath ) );

  return o;
}

//

function filesReflectTo_body( o )
{
  let self = this;
  let src = self;
  let dst = o.dstProvider;
  let hub;

  _.assertRoutineOptions( filesReflectTo_body, arguments );

  if( src.hub )
  {
    hub = src.hub;
  }
  else if( dst.hub )
  {
    hub = dst.hub;
  }
  else
  {
    hub = new _.FileProvider.Hub({ empty : 1 });
  }

  let srcProtocol = src.protocol;
  let dstProtocol = dst.protocol;
  let srcRegistered = hub.providersWithProtocolMap[ src.protocol ] === src;
  let dstRegistered = hub.providersWithProtocolMap[ dst.protocol ] === dst;

  if( !src.protocol )
  src.protocol = hub.protocolNameGenerate( 0 );
  if( !dst.protocol )
  dst.protocol = hub.protocolNameGenerate( 1 );

  if( !srcRegistered )
  src.providerRegisterTo( hub );
  if( !dstRegistered )
  dst.providerRegisterTo( hub );

  _.assert( src.hub === dst.hub );

  let filePath = { [ src.path.globalFromLocal( o.srcPath ) ] : dst.path.globalFromLocal( o.dstPath ) }
  let result = hub.filesReflect({ reflectMap : filePath });

  _.assert( !_.consequenceIs( result ), 'not implemented' );

  if( !srcRegistered )
  src.providerUnregister();
  if( !dstRegistered )
  dst.providerUnregister();

  if( !srcRegistered && !dstRegistered )
  hub.finit();

  return result;
}

var defaults = filesReflectTo_body.defaults = Object.create( null );
defaults.dstProvider = null;
defaults.dstPath = '/';
defaults.srcPath = '/';

let filesReflectTo = _.routineFromPreAndBody( filesReflectTo_pre, filesReflectTo_body );

//

function filesExtract_pre( routine, args )
{
  let self = this;
  let path = self.path;
  let o = args[ 0 ];

  if( !_.mapIs( o ) )
  o = { filePath : o }

  _.assert( arguments.length === 2, 'Expects exactly two arguments' );
  _.assert( args.length === 1 );
  _.routineOptions( routine, o );
  _.assert( path.isAbsolute( o.filePath ) );

  return o;
}

//

function filesExtract_body( o )
{
  let self = this;
  let extract = new _.FileProvider.Extract();

  let result = self.filesReflectTo
  ({
    srcPath : o.filePath,
    dstProvider : extract,
  });

  _.assert( !_.consequenceIs( result ), 'not implemented' );

  return extract;
}

var defaults = filesExtract_body.defaults = Object.create( null );
defaults.filePath = '/';

let filesExtract = _.routineFromPreAndBody( filesExtract_pre, filesExtract_body );

//

function filesFindSame_body( o )
{
  let self = this;
  let logger = self.logger;
  let r = o.result = o.result || Object.create( null );

  /* result */

  _.assert( arguments.length === 1 );
  _.assert( _.objectIs( r ) );
  _.assert( _.strIs( o.filePath ) );
  _.assert( o.outputFormat === 'record' );

  /* time */

  let time;
  if( o.usingTiming )
  time = _.timeNow();

  /* find */

  let findOptions = _.mapOnly( o, filesFind.defaults );
  findOptions.outputFormat = 'record';
  findOptions.result = [];
  r.unique = self.filesFind.body.call( self, findOptions );

  /* adjust found */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ];

    if( !file1.stat )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( file1.isDir )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

    if( !file1.stat.size > o.maxSize )
    {
      r.unique.splice( f1, 1 );
      f1 -= 1;
      continue;
    }

  }

  /* compare */

  r.similarArray = [];
  r.similarMaps = Object.create( null );
  r.similarGroupsArray = [];
  r.similarGroupsMap = Object.create( null );
  r.similarFilesInTotal = 0;
  r.linkedFilesMap = Object.create( null );
  r.linkGroupsArray = [];

  /* */

  for( let f1 = 0 ; f1 < r.unique.length ; f1++ )
  {
    let file1 = r.unique[ f1 ]
    let path1 = o.relativePaths ? file1.relative : file1.absolute;

    for( let f2 = f1 + 1 ; f2 < r.unique.length ; f2++ )
    {

      let file2 = r.unique[ f2 ];
      let path2 = o.relativePaths ? file2.relative : file2.absolute;
      let minSize = Math.min( file1.stat.size, file2.stat.size );
      let maxSize = Math.max( file1.stat.size, file2.stat.size );

      if( _.statsAreHardLinked( file1.stat, file2.stat ) )
      {
        linkAdd();
        continue;
      }

      if( minSize / maxSize < o.similarityLimit )
      continue;

      if( !file1.stat.hash )
      file1.stat.hash = _.strLattersSpectre( self.fileRead( file1.absolute ) );
      if( !file2.stat.hash )
      file2.stat.hash = _.strLattersSpectre( self.fileRead( file2.absolute ) );

      if( self.verbosity >= 4 )
      self.logger.log( '. strLattersSpectresSimilarity', path1, path2 );
      let similarity = _.strLattersSpectresSimilarity( file1.stat.hash, file2.stat.hash );

      if( similarity < o.similarityLimit )
      continue;

      similarityAdd( similarity );

    }

  }

  /* */

  similarGroupsRefine();
  linkGroupsRefine();

  return o.result;

  /* */

  function similarityAdd( similarity )
  {

    let d = Object.create( null );
    d.path1 = path1;
    d.path2 = path2;
    d.similarity = similarity;
    d.id = r.similarArray.length;
    r.similarArray.push( d );

    let similarMap = r.similarMaps[ path1 ] = r.similarMaps[ path1 ] || Object.create( null );
    similarMap[ path2 ] = d;
    similarMap = r.similarMaps[ path2 ] = r.similarMaps[ path2 ] || Object.create( null );
    similarMap[ path1 ] = d;

    let group1 = r.similarGroupsMap[ path1 ];
    let group2 = r.similarGroupsMap[ path2 ];

    if( !group1 )
    r.similarFilesInTotal += 1;

    if( !group2 )
    r.similarFilesInTotal += 1;

    if( group1 && group2 )
    {
      if( group1 === group2 )
      return;
      groupMove( group1, group2 );
    }

    let group = group1 || group2;

    if( !group )
    {
      group = Object.create( null );
      group.paths = [];
      group.paths.push( path1 );
      group.paths.push( path2 );
      r.similarGroupsArray.push( group );
    }
    else if( !group1 )
    {
      _.arrayAppendOnceStrictly( group.paths, path1 );
    }
    else if( !group2 )
    {
      _.arrayAppendOnceStrictly( group.paths, path2 );
    }

    r.similarGroupsMap[ path1 ] = group;
    r.similarGroupsMap[ path2 ] = group;

    // if( r.similarGroupsMap[ path2 ] )
    // {
    //   debugger;
    //   if( r.similarGroupsMap[ similarGroup1 ] )
    //   similarGroup1 = groupMove( path2, similarGroup1 );
    // }
    // else
    // {
    //   r.similarFilesInTotal += 1;
    //
    //   if( !r.similarGroupsMap[ similarGroup1 ] )
    //   {
    //     _.arrayAppendOnceStrictly( r.similarGroupsArray, similarGroup1 );
    //     r.similarGroupsMap[ similarGroup1 ] = [];
    //     r.similarFilesInTotal += 1;
    //   }
    //
    //   let group = r.similarGroupsMap[ similarGroup1 ]
    //   _.arrayAppendOnce( group, path1 );
    //   _.arrayAppendOnce( group, path2 );
    //
    // }

  }

  /* */

  function groupMove( dst, src )
  {
    debugger;

    _.arrayAppendArrayOnceStrictly( dst.paths, src.paths );
    _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // debugger;
    // if( _.strIs( r.similarGroupsMap[ dst ] ) )
    // dst = r.similarGroupsMap[ dst ];
    // _.assert( _.arrayIs( r.similarGroupsMap[ src ] ) );
    // _.assert( _.arrayIs( r.similarGroupsMap[ dst ] ) );
    // for( let i = 0 ; i < r.similarGroupsMap[ src ].length ; i++ )
    // {
    //   debugger;
    //   let srcElement = r.similarGroupsMap[ src ][ i ];
    //   _.assert( _.strIs( r.similarGroupsMap[ srcElement ] ) || srcElement === src );
    //   _.arrayAppendOnceStrictly( r.similarGroupsMap[ dst ], srcElement );
    //   r.similarGroupsMap[ srcElement ] = dst;
    // }
    // _.arrayRemoveElementOnceStrictly( r.similarGroupsArray, src );

    return dst;
  }

  /* */

  function similarGroupsRefine()
  {
    for( let g in r.similarGroupsMap )
    {
      let group = r.similarGroupsMap[ g ];
      group.id = r.similarGroupsArray.indexOf( group );
      r.similarGroupsMap[ g ] = group.id;
    }
  }

  /* */

  function linkAdd()
  {
    let d1 = r.linkedFilesMap[ path1 ];
    let d2 = r.linkedFilesMap[ path2 ];
    _.assert( !d1 || !d2, 'Two link descriptors for the same instance of linked file', path1, path2 );
    let d = d1 || d2;
    if( !d )
    {
      d = Object.create( null );
      d.paths = [];
      d.paths.push( path1 );
      d.paths.push( path2 );
      r.linkGroupsArray.push( d );
    }
    else if( !d1 )
    {
      _.arrayAppendOnceStrictly( d.paths, path1 );
    }
    else
    {
      _.arrayAppendOnceStrictly( d.paths, path2 );
    }
    r.linkedFilesMap[ path1 ] = d;
    r.linkedFilesMap[ path2 ] = d;
  }

  /* */

  function linkGroupsRefine()
  {
    for( let f in r.linkedFilesMap )
    {
      let d = r.linkedFilesMap[ f ];
      d.id = r.linkGroupsArray.indexOf( d )
      r.linkedFilesMap[ f ] = d.id;
    }
  }

}

_.routineExtend( filesFindSame_body, filesFindRecursive );

var defaults = filesFindSame_body.defaults;
defaults.maxSize = 1 << 22;
// defaults.lattersFileSizeLimit = 1048576;
defaults.similarityLimit = 0.95;

// defaults.usingFast = 1;
// defaults.usingContentComparing = 1;
// defaults.usingTakingNameIntoAccountComparingContent = 1;
// defaults.usingLinkedCollecting = 0;
// defaults.usingSameNameCollecting = 0;

defaults.investigatingLinking = 1;
defaults.investigatingSimilarity = 1;
defaults.usingTiming = 0;
defaults.relativePaths = 0;

defaults.result = null;

let filesFindSame = _.routineFromPreAndBody( filesFind.pre, filesFindSame_body );

filesFindSame.having.aspect = 'entry';

// --
// delete
// --

function filesDelete_pre( routine, args )
{
  let self = this;
  args = _.longSlice( args );
  let o = self.filesFind_pre( routine, args );
  return o;
}

//

/*
qqq :
- add extended test routine
- cover option deletingEmptyDirs
- cover returned result, records of non-exitent files should not be in the result

- if deletingEmptyDirs : 1 then

/a/x
/a/b
/a/b/c
/a/b/c/f1
/a/b/c/f2

filesDelete [ /a/b/c/f1, /a/b/c/f2 ] should delete

/a/b
/a/b/c
/a/b/c/f1
/a/b/c/f2

*/

function filesDelete_body( o )
{
  let self = this;
  let provider = o.filter.effectiveFileProvider;
  let path = self.path;
  let con;
  let time;

  if( o.verbosity >= 1 )
  time = _.timeNow();

  if( !o.sync )
  con = new _.Consequence().take( null );

  _.assert( !o.includingTransient, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( _.numberIs( o.safe ) );
  _.assert( o.filter.formed === 5 );
  _.assert( arguments.length === 1 );

  // debugger;

  /* */

  let filePath = o.filter.filePathArrayGet( o.filter.formedFilePath );
  if( filePath.length === 1 && !o.deletingEmptyDirs )
  {
    filePath = filePath[ 0 ];
    if( !provider.fileExists( filePath ) )
    return end();
    /*
      reminder : masks are not applicable to stem file
    */
    if( provider.isTerminal( filePath ) )
    {
      let file = provider.record( filePath );
      file.isActual = true;
      file.isTransient = true;
      o.result.push( file );
      if( o.writing )
      {
        if( o.sync )
        fileDelete( file );
        else
        con.thenKeep( () => fileDelete( file ) );
      }
      return end();
    }
  }

  /* */

  let o2 = _.mapOnly( o, provider.filesFind.defaults );
  o2.verbosity = 0;
  o2.outputFormat = 'record';
  o2.includingTransient = 1;
  _.assert( !!o.includingDirs );
  _.assert( !!o.includingActual );
  _.assert( !o.includingTransient );
  _.assert( o.result === o2.result );

  /* qqq : this is not async aaa : done*/

  // debugger;

  if( o.sync )
  {
    provider.filesFind.body.call( provider, o2 );
    handleResult();

    if( o.writing )
    handleWriting();

    if( o.deletingEmptyDirs && o.result.length )
    deletingEmptyDirs();
  }
  else
  {
    con.thenKeep( () => provider.filesFind.body.call( provider, o2 ) );
    con.thenKeep( () => handleResult() );

    if( o.writing )
    con.thenKeep( () => handleWriting() );

    if( o.deletingEmptyDirs )
    con.thenKeep( () =>
    {
      if( !o.result.length )
      return null;
      return deletingEmptyDirs();
    })
  }

  /* */

  /*
  workaround to fix phantom issue on windows+nodejs
  program exits before actually deleting several dir files
  */

  // _.timeBegin( 5 );

  /* */

  return end();

  /* - */

  function handleWriting()
  {
    let con;
    if( !o.sync )
    con = new _.Consequence().take( null );

    for( let f = o.result.length-1 ; f >= 0 ; f-- )
    {
      let file = o.result[ f ];

      // qqq : temp hack. comment it out please
      // if( file.isDir )
      // if( !provider.dirIsEmpty( file.absolute ) )
      // {
      //   o.result.splice( f, 1 );
      //   continue;
      // }
      // qqq

      if( file.isActual && file.absolute !== '/' )
      if( o.sync )
      fileDelete( file )
      else
      con.thenKeep( () => fileDelete( file ) );
    }
    return con;
  }

  /*  */

  function handleResult()
  {
    // debugger;
    for( let f1 = 0 ; f1 < o.result.length ; f1++ )
    {
      let file1 = o.result[ f1 ];

      if( file1.isActual /* && ( file1.isTransient || file1.isTerminal ) */ )
      {
        // if( file1.isTerminal )
        // continue;

        if( !file1.isDir )
        continue;

        if( file1.isTransient )
        {
          /* delete dir if:
            recursive : 0
            its empty
            terminals from dir will be included in result
          */

          if( !o.recursive )
          continue;
          if( o.recursive === 2 && o.includingTerminals )
          continue;
          if( provider.dirIsEmpty( file1.absolute ) )
          continue;
        }
      }

      o.result.splice( f1, 1 );
      f1 -= 1;

      if( !file1.isActual || !file1.isTransient )
      for( let f2 = f1 ; f2 >= 0 ; f2-- )
      {
        let file2 = o.result[ f2 ];
        // if( file2.relative === '.' ) /* ? */
        if( _.strBegins( file1.absolute, file2.absolute ) )
        {
          o.result.splice( f2, 1 );
          f1 -=1 ;
        }
      }
    }

    return true;
  }

  /* - */

  function end()
  {
    if( o.sync )
    return endSync();
    else
    return con.thenKeep( () => endSync() );
  }

  /* - */

  function endSync()
  {
    if( o.verbosity >= 1 )
    provider.logger.log( ' - filesDelete ' + o.result.length + ' files at ' + _.color.strFormat( path.commonReport( _.mapKeys( o.filter.formedFilePath ) ), 'path' ) + ' in ' + _.timeSpent( time ) );

    if( o.outputFormat === 'absolute' )
    o.result = _.select( o.result, '*/absolute' );
    else if( o.outputFormat === 'relative' )
    o.result = _.select( o.result, '*/relative' );
    else _.assert( o.outputFormat === 'record' );

    return o.result;
  }

  /* - */

  function fileDelete( file )
  {
    let o2 =
    {
      filePath : file.absolute,
      throwing : o.throwing,
      verbosity : o.verbosity-1,
      safe : o.safe,
      sync : o.sync,
    }
    let r = file.factory.effectiveFileProvider.fileDelete( o2 );
    if( r === null )
    provider.logger.log( ' ! Cant delete ' + file.absolute );
    return r;
  }

  /* - */

  function deletingEmptyDirs()
  {
    let delMap = Object.create( null );
    // let dirMap = Object.create( null );
    let factory = o.result[ 0 ].factory;

    for( let f = o.result.length-1 ; f >= 0 ; f-- )
    {
      let file = o.result[ f ];
      // dirMap[ file.dir ] = 1;
      delMap[ file.absolute ] = 1;
    }

    let dirsFile = [];
    let dirsPath = path.chainToRoot( o.result[ 0 ].dir );

    // debugger;

    for( let d = dirsPath.length-1 ; d >= 0 ; d-- )
    {
      let dirPath = dirsPath[ d ];
      let files = provider.dirRead({ filePath : dirPath, outputFormat : 'absolute' });

      for( let f = files.length-1 ; f >= 0 ; f-- )
      if( delMap[ files[ f ] ] )
      files.splice( f, 1 )

      if( files.length > 0 )
      break;
      // if( files.length === 1 && !delMap[ files[ 0 ] ] )
      // break;

      // dirMap[ dirPath ] = 1;
      delMap[ dirPath ] = 1;

      let file = factory.record( dirPath );
      file.isActual = true;
      file.isTransient = true;
      dirsFile.unshift( file );

    }

    _.arrayPrependArray( o.result, dirsFile );

    let con;

    if( !o.sync )
    con = new _.Consequence().take( null );

    if( o.writing )
    for( let d = dirsFile.length-1 ; d >= 0 ; d-- )
    {
      let file = dirsFile[ d ];
      if( o.sync )
      fileDelete( file );
      else
      con.thenKeep( () => fileDelete( file ) );
    }

    return con;
  }

}

_.routineExtend( filesDelete_body, filesFind );

var defaults = filesDelete_body.defaults;
defaults.outputFormat = 'record';
defaults.sync = 1;
defaults.recursive = 2;
defaults.includingTransient = 0;
defaults.includingDirs = 1;
defaults.includingTerminals = 1;
defaults.resolvingSoftLink = 0;
defaults.resolvingTextLink = 0;
defaults.allowingMissed = 1;
defaults.allowingCycled = 1;
defaults.verbosity = null;
defaults.maskPreset = 0;
defaults.throwing = null;
defaults.safe = null;
defaults.writing = 1;
defaults.deletingEmptyDirs = 0;

//

let filesDelete = _.routineFromPreAndBody( filesDelete_pre, filesDelete_body );
filesDelete.having.aspect = 'entry';

var defaults = filesDelete.defaults;
var having = filesDelete.having;

_.assert( !!defaults );
_.assert( !!having );
_.assert( !!filesDelete.defaults.includingDirs );

// //
//
// function filesDeleteForce( o )
// {
//   let self = this;
//
//   o = self.filesFindLike_pre( arguments );
//
//   _.routineOptions( filesDeleteForce, o );
//
//   return self.filesDelete( o );
// }
//
// _.routineExtend( filesDeleteForce, filesDelete );
//
// var defaults = filesDeleteForce.defaults;

//

function filesDeleteTerminals_body( o )
{
  let self = this;

  _.assertRoutineOptions( filesDeleteTerminals_body, arguments );
  _.assert( o.includingTerminals );
  _.assert( !o.includingDirs );
  _.assert( !o.includingTransient, 'Transient files should not be included' );
  _.assert( o.resolvingTextLink === 0 || o.resolvingTextLink === false );
  _.assert( o.resolvingSoftLink === 0 || o.resolvingSoftLink === false );
  _.assert( _.numberIs( o.safe ) );
  _.assert( arguments.length === 1 );

  /* */

  let o2 = _.mapOnly( o, self.filesFind.defaults );

  o2.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), handleDown );

  let files = self.filesFind.body.call( self, o2 );

  return files;

  /* */

  function handleDown( record )
  {
    if( o.writing )
    self.fileDelete({ filePath : record.absolute, throwing : o.throwing, verbosity : o.verbosity });
    return record;
  }
}

_.routineExtend( filesDeleteTerminals_body, filesDelete );

var defaults = filesDeleteTerminals_body.defaults;

defaults.recursive = 2;
defaults.includingTerminals = 1;
defaults.includingDirs = 0;
defaults.includingTransient = 0;

let filesDeleteTerminals = _.routineFromPreAndBody( filesFind.pre, filesDeleteTerminals_body );

//

/*
qqq : add test coverage, extract pre and body, please
*/

function filesDeleteEmptyDirs_body( o )
{
  let self = this;

  /* */

  _.assertRoutineOptions( filesDeleteEmptyDirs_body, arguments );
  _.assert( !o.includingTerminals );
  _.assert( o.includingDirs );
  _.assert( !o.includingTransient );
  _.assert( o.recursive !== undefined && o.recursive !== null );

  /* */

  let o2 = _.mapOnly( o, self.filesFind.defaults );

  o2.onDown = _.arrayAppendElement( _.arrayAs( o.onDown ), handleDown );

  let files = self.filesFind.body.call( self, o2 );

  return files;

  /* */

  function handleDown( record )
  {

    try
    {

      let sub = self.dirRead( record.absolute );
      if( !sub )
      debugger;

      if( !sub.length )
      {
        // if( self.verbosity >= 1 )
        // self.logger.log( ' - deleted :', record.absolute );
        self.fileDelete({ filePath : record.absolute, throwing : o.throwing, verbosity : o.verbosity });
      }
    }
    catch( err )
    {
      if( o.throwing )
      throw _.err( err );
    }

    return record;
  }

}

_.routineExtend( filesDeleteEmptyDirs_body, filesFind.body );

var defaults = filesDeleteEmptyDirs_body.defaults;
defaults.throwing = false;
defaults.verbosity = null;
defaults.outputFormat = 'absolute';
defaults.includingTerminals = 0;
defaults.includingDirs = 1;
defaults.includingTransient = 0;
defaults.recursive = 2;

let filesDeleteEmptyDirs = _.routineFromPreAndBody( filesFind.pre, filesDeleteEmptyDirs_body );

// --
// other find
// --

function softLinksBreak( o )
{
  let self = this;

  o = self.filesFind.pre.call( self, softLinksBreak, arguments );

  _.assert( o.outputFormat === 'record' );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {

    debugger;
    throw _.err( 'not tested' );

    if( o.breakingSoftLink && record.isSoftLink )
    self.softLinkBreak( record.absolute );
    if( o.breakingTextLink && record.isTextLink )
    self.softLinkBreak( record.absolute );

  });

  let files = self.filesFind.body.call( self, optionsFind );

  return files;
}

_.routineExtend( softLinksBreak, filesFind );

var defaults = softLinksBreak.defaults;
defaults.outputFormat = 'record';
defaults.breakingSoftLink = 1;
defaults.breakingTextLink = 0;
defaults.recursive = 2;

//

function softLinksRebase( o )
{
  let self = this;
  o = self.filesFind.pre.call( self, softLinksRebase, arguments );

  _.assert( o.outputFormat === 'record' );
  _.assert( !o.resolvingSoftLink );

  /* */

  let optionsFind = _.mapOnly( o, filesFind.defaults );
  optionsFind.onDown = _.arrayAppendElement( _.arrayAs( optionsFind.onDown ), function( record )
  {

    if( !record.isSoftLink )
    return;

    record.isSoftLink;
    let resolvedPath = self.pathResolveSoftLink( record.absoluteGlobalMaybe );
    let rebasedPath = self.path.rebase( resolvedPath, o.oldPath, o.newPath );
    self.fileDelete({ filePath : record.absoluteGlobalMaybe, verbosity : 0 });
    self.softLink
    ({
      dstPath : record.absoluteGlobalMaybe,
      srcPath : rebasedPath,
      allowingMissed : 1,
      allowingCycled : 1,
    });

    _.assert( !!self.statResolvedRead({ filePath : record.absoluteGlobalMaybe, resolvingSoftLink : 0 }) );

  });

  let files = self.filesFind.body.call( self, optionsFind );

  return files;
}

_.routineExtend( softLinksRebase, filesFind );

var defaults = softLinksRebase.defaults;
defaults.outputFormat = 'record';
defaults.oldPath = null;
defaults.newPath = null;
defaults.recursive = 2;
defaults.resolvingSoftLink = 0;

//

function filesHasTerminal( filePath )
{
  var self = this;
  _.assert( arguments.length === 1 );

  let terminal = false;

  self.filesFind
  ({
    filePath : filePath,
    includingStem : 1,
    includingDirs : 1,
    includingTerminals : 1,
    onUp : onUp,
    resolvingSoftLink : 0,
    resolvingTextLink : 0,
    recursive : 2
  })

  return terminal;

  /* */

  function onUp( record )
  {
    if( terminal )
    return false;
    if( record.stat && !record.isDir )
    terminal = record;
    return record;
  }
}

// --
// resolver
// --

function filesResolve( o )
{
  let self = this;
  let result;
  var o = _.routineOptions( filesResolve, arguments );

  _.assert( _.objectIs( o.translator ) );

  let globPath = o.translator.realFor( o.globPath );
  let globOptions = _.mapOnly( o, self.filesGlob.defaults );

  globOptions.filter = globOptions.filter || Object.create( null );
  globOptions.filePath = globPath;
  globOptions.filter.basePath = o.translator.realRootPath;
  globOptions.outputFormat = o.outputFormat;

  _.assert( !!self );

  result = self.filesGlob( globOptions );

  return result;
}

_.routineExtend( filesResolve, filesGlob );

var defaults = filesResolve.defaults;
defaults.recursive = 2;
defaults.globPath = null;
defaults.translator = null;
defaults.outputFormat = 'record';

// var paths = filesResolve.paths;
// paths.globPath = null;

// --
// relationship
// --

let Composes =
{
}

let Aggregates =
{
}

let Associates =
{
}

let Restricts =
{
}

// --
// declare
// --

let Supplement =
{

  // etc

  recordsOrder,
  _filesFilterMasksSupplement,

  // find

  filesFindLike_pre,
  filesFind_pre,
  _filesFilterForm,

  filesFindSingle,
  filesFind,
  filesFindRecursive,
  filesGlob,

  filesFinder_functor,
  filesFinder,
  filesGlober,

  //

  filesFindGroups,
  filesRead,

  // reflect

  filesCopyWithAdapter,

  _filesPrepareFilters,

  filesReflectEvaluate,
  filesReflectSingle,
  filesReflect,

  filesReflector_functor,
  filesReflector,

  filesReflectTo,
  filesExtract,

  // same

  filesFindSame,

  // delete

  filesDelete,

  filesDeleteTerminals,
  filesDeleteEmptyDirs,

  // other find

  softLinksBreak,
  softLinksRebase,
  filesHasTerminal,

  // resolver

  filesResolve,

  //

  Composes,
  Aggregates,
  Associates,
  Restricts,

}

//

_.classDeclare
({
  cls : Self,
  supplement : Supplement,
  withMixin : true,
  withClass : true,
});

_.FileProvider = _.FileProvider || Object.create( null );
_.FileProvider[ Self.shortName ] = Self;

_.assert( !!_.FileProvider.Find.prototype.filesDelete.defaults.includingDirs );

// --
// export
// --

// if( typeof module !== 'undefined' )
// if( _global_.WTOOLS_PRIVATE )
// { /* delete require.cache[ module.id ]; */ }

if( typeof module !== 'undefined' && module !== null )
module[ 'exports' ] = Self;

})();
