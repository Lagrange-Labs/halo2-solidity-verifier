// SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

contract Halo2VerifyingKey {
    constructor() {
        assembly {
            {%- for (name, chunk) in constants %}
            mstore({{ (32 * loop.index0)|hex_padded(4) }}, {{ chunk|hex_padded(64) }}) // {{ name }}
            {%- endfor %}
            {%- for (x, y) in fixed_comms %}
            {%- let offset = constants.len() %}
            mstore({{ (32 * (offset + 2 * loop.index0))|hex_padded(4) }}, {{ x|hex_padded(64) }}) // fixed_comms[{{ loop.index0 }}].x
            mstore({{ (32 * (offset + 2 * loop.index0 + 1))|hex_padded(4) }}, {{ y|hex_padded(64) }}) // fixed_comms[{{ loop.index0 }}].y
            {%- endfor %}
            {%- for (x, y) in permutation_comms %}
            {%- let offset = constants.len() + 2 * fixed_comms.len() %}
            mstore({{ (32 * (offset + 2 * loop.index0))|hex_padded(4) }}, {{ x|hex_padded(64) }}) // permutation_comms[{{ loop.index0 }}].x
            mstore({{ (32 * (offset + 2 * loop.index0 + 1))|hex_padded(4) }}, {{ y|hex_padded(64) }}) // permutation_comms[{{ loop.index0 }}].y
            {%- endfor %}
            {%- for const in const_expressions %}
            {%- let offset = constants.len() + 2 * fixed_comms.len() + 2 * permutation_comms.len() %}
            mstore({{ (32 * (offset + loop.index0))|hex_padded(4) }}, {{ const|hex_padded(64) }}) // const_expressions[{{ loop.index0 }}]
            {%- endfor %}
            {%- let offset = constants.len() + 2 * fixed_comms.len() + 2 * permutation_comms.len() + const_expressions.len() %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{(2 * 32 * num_advices_user_challenges.len())|hex_padded(64) }}) // num_advices_user_challenges length
            {%- for (x, y) in num_advices_user_challenges %}
            {%- let offset = constants.len() + 2 * fixed_comms.len() + 2 * permutation_comms.len() + const_expressions.len() + 1 %}
            mstore({{ (32 * (offset + 2 * loop.index0))|hex_padded(4) }}, {{ x|hex_padded(64) }}) // num_advices[{{ loop.index0 }}].x
            mstore({{ (32 * (offset + 2 * loop.index0 + 1))|hex_padded(4) }}, {{ y|hex_padded(64) }}) // user_challenges[{{ loop.index0 }}].y
            {%- endfor %}
            {%- let offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 1 %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ (32 * gate_computations.gates.len())|hex_padded(64) }}) // gate_computations length
            {%- for gate in gate_computations.gates %}
            {%- let base_offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 2 %}
            {%- let offset = base_offset + loop.index0 + gate.acc %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ (32 * gate.expression.len())|hex_padded(64) }}) // gate_computation length[{{ loop.index0 }}]
            {%- for operation in gate.expression %}
            {%- let offset = offset + loop.index0 + 1 %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ operation|hex_padded(64) }}) // gate_computation[{{ loop.index0 }}]
            {%- endfor %}
            {%- endfor %}
            {%- let offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 1 + gate_computations.len() %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ permutation_computations.z_evals_last_idx|hex_padded(64) }}) // z_evals_last_idx
            {%- let offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 2 + gate_computations.len() %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ permutation_computations.chunk_offset|hex_padded(64) }}) // chunk_offset
            {%- for z_eval in permutation_computations.permutation_z_evals %}
            {%- let base_offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 3 + gate_computations.len() %}
            {%- let offset = base_offset + loop.index0 * (permutation_computations.column_evals[0].len() + 1)%}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ z_eval|hex_padded(64) }}) // permutation_z_evals[{{ loop.index0 }}]
            {%- let last_index = permutation_computations.permutation_z_evals.len() - 1 %}
            {%- let plus_one %}
            {%- if loop.index0 == last_index %}
            {%- let offset = offset + 1 %}
            {%- let plus_one = 1 %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ (32 * (permutation_computations.column_evals[last_index].len() + 1))|hex_padded(64) }}) // chunk_offset_last
            {%- else -%}
            {%- let plus_one = 0 -%}
            {%- endif %}
            {%- for column_eval in permutation_computations.column_evals[loop.index0] %}
            {%- let offset = offset + loop.index0 + 1 + plus_one %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ column_eval|hex_padded(64) }}) // column_eval[{{ loop.index0 }}]
            {%- endfor %}
            {%- endfor %}
            {%- let offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 1 + gate_computations.len() + permutation_computations.len() %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ lookup_computations.end_ptr|hex_padded(64) }}) // end_ptr of lookup_computations
            {%- for lookup in lookup_computations.lookups %}
            {%- let base_offset = constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 2 + gate_computations.len() + permutation_computations.len() %}
            {%- let offset = base_offset + (loop.index0 * 3) + lookup.acc %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ lookup.evals|hex_padded(64) }}) // lookup_evals[{{ loop.index0 }}]
            mstore({{ (32 * (offset + 1))|hex_padded(4) }}, {{ lookup.table_lines|hex_padded(64) }}) // lookup_table_lines[{{ loop.index0 }}]
            mstore({{ (32 * (offset + 2))|hex_padded(4) }}, {{ (32 * lookup.inputs.len())|hex_padded(64) }}) // outer_inputs_len[{{ loop.index0 }}]
            {%- for input in lookup.inputs %}
            {%- let offset = offset + loop.index0 + input.acc + 3 %}
            mstore({{ (32 * offset)|hex_padded(4) }}, {{ (32 * input.expression.len())|hex_padded(64) }}) // inputs_len [{{ loop.index0 }}]
            {%- for expression in input.expression %}
            mstore({{ (32 * (offset + loop.index0 + 1))|hex_padded(4) }}, {{ expression|hex_padded(64) }}) // input_expression [{{ loop.index0 }}]
            {%- endfor %}
            mstore({{ (32 * (offset + input.expression.len() + 1))|hex_padded(4) }}, {{ input.vars|hex_padded(64) }}) // input_vars [{{ loop.index0 }}]
            {%- endfor %}
            {%- endfor %}
            return(0, {{ (32 * (constants.len() + 2 * (fixed_comms.len() + permutation_comms.len() + num_advices_user_challenges.len()) + const_expressions.len() + 2 + gate_computations.len() + permutation_computations.len() + lookup_computations.len() ))|hex() }})
        }
    }
}
