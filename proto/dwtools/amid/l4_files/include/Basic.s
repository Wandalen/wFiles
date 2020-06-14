( function _Basic_s_() {

'use strict';

if( typeof module !== 'undefined' )
{
  let _ = require( '../../../../dwtools/Tools.s' );

  _.include( 'wSelector' );
  _.include( 'wProcess' );
  _.include( 'wRoutineBasic' );
  _.include( 'wProto' );

  _.include( 'wGdf' );
  _.include( 'wPathBasic' );
  _.include( 'wUriBasic' );
  _.include( 'wWebUriBasic' );
  _.include( 'wPathTools' );
  _.include( 'wLogger' );
  _.include( 'wRegexpObject' );
  _.include( 'wFieldsStack' );
  _.include( 'wConsequence' );
  _.include( 'wStringer' );
  _.include( 'wStringsExtra' );
  _.include( 'wVerbal' );

  _.assert( !!_.FieldsStack );

  module[ 'exports' ] = _;
}

})();
