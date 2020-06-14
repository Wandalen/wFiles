(function _Mid_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( './Basic.s' );

  _.assert( !!_.FieldsStack );
  _.assert( !_.FileRecord );
  _.assert( !_.FileRecordFactory );
  _.assert( !_.FileRecordFilter );
  _.assert( !_.FileStat );

  require( '../l1/Namespace.s' );

  require( '../l2/Encoders.s' );
  require( '../l2/RecordContext.s' );

  require( '../l3/Path.s' );
  if( Config.interpreter === 'njs' )
  require( '../l3/Path.ss' );
  require( '../l3/Record.s' );
  require( '../l3/RecordFactory.s' );
  require( '../l3/RecordFilter.s' );
  require( '../l3/Stat.s' );

  require( '../l4/Abstract.s' );

  require( '../l5/Partial.s' );
  require( '../l6/System.s' );
  require( './Find.s' )
  require( './Secondary.s' )

  module[ 'exports' ] = _;
}

})();
