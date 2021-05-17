( function _Operator_s_()
{

'use strict';

if( typeof module !== 'undefined' )
{
  const _ = require( '../../../../node_modules/Tools' );

  require( '../l7_operator/Mission.s' );
  require( '../l7_operator/Namespace.s' );
  require( '../l7_operator/Operation.s' );
  require( '../l7_operator/Operator.s' );

  module[ 'exports' ] = _;
}

})();
