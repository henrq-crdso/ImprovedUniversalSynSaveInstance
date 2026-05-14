--!nocheck
--!nolint
local select_ref = select;
local function copy_varargs_into_array(target_array, target_start_index, ...)
    local vararg_values, vararg_count = {
        ...
    }, select_ref("#", ...);
    for copy_index = target_start_index, target_start_index + vararg_count - 1 do
        target_array[copy_index] = vararg_values[copy_index - target_start_index + 1];
    end;
end;
local getscriptbytecode_ref = getscriptbytecode;
local getscripthash_ref = getscripthash;
local _ = getgenv;

local vector_three_compat = Vector3 or {
    new = function(vector_x, vector_y, vector_z)
        return {
            X = vector_x,
            Y = vector_y,
            Z = vector_z
        };
    end
};
local encode_opcode_byte = nil;
local active_opcode_encoding = nil;
local decoded_opcode_by_encoded_byte = {};
local function rebuild_opcode_decoder()
    if active_opcode_encoding == "vanilla" then
        encode_opcode_byte = function(plain_opcode_byte)
            return plain_opcode_byte;
        end;
    elseif active_opcode_encoding == "mul227" then
        encode_opcode_byte = function(mul_encoded_opcode_byte)
            return mul_encoded_opcode_byte * 227;
        end;
    else
        error("Invalid opcode_encoding_type");
    end;
    table.clear(decoded_opcode_by_encoded_byte);
    for opcode_byte_index = 0, 255 do
        decoded_opcode_by_encoded_byte[bit32.band(encode_opcode_byte(opcode_byte_index), 255)] = opcode_byte_index;
    end;
end;
local DEFAULT_DECOMPILER_OPTIONS = {
    use_proto_debugnames = true,
    show_proto_line_defined = true,
    show_proto_upvalues = true,
    show_proto_constants = true,
    inline_table_initialization = true,
    table_string_key_shortening = true,
    table_dict_key_semicolons = true,
    table_array_value_semicolons = false,
    always_use_table_keys = false,
    use_compound_assignment = true,
    exact_argument_names = false,
    string_quotes_behavior = "single char, single quotes",
    do_tonumber_nan = true,
    do_while_1 = false,
    show_nil_definitions = true,
    smart_var_level = 3,
    smart_var_usage_analysis = true,
    smart_var_extensive_prefixes = false,
    mark_upvalues = "extra",
    mark_setglobal = true,
    mark_reads_and_writes = false,
    minify_if_statements = true,
    assume_if_else = true,
    prefix_error = "KONSTANTERROR",
    prefix_warning = "KONSTANTWARNING",
    prefix_information = "KONSTANTINFO"
};
local task_wait_ref = if task then task.wait else nil;
local CONSTANT_TYPE_NAMES = {
    [0] = "nil",
    [1] = "boolean",
    [2] = "number",
    [3] = "string",
    [4] = "import",
    [5] = "table",
    [6] = "function",
    [7] = "vector"
};
local clock_ref = os.clock;
local elapsed_time_ref = elapsedTime or clock_ref;
local last_yield_time = elapsed_time_ref();
local running_inside_game = game ~= nil;

local function yield_if_needed(yield_context, yield_label, yield_payload)
    if elapsed_time_ref() - last_yield_time >= 0.016666666666666666 then

        if task_wait_ref and running_inside_game then
            task_wait_ref();
        end;
        last_yield_time = elapsed_time_ref();
    end;
end;
local function create_noop_benchmark()
    return {
        start_times = {},
        end_times = {},
        completed_benchmarks = {},
        start_benchmark = function(_, _)

        end,
        end_benchmark = function(_, _)

        end,
        get_benchmark_time = function(_, _)
            return 0;
        end,
        print_benchmark_time = function(_, _)

        end,
        print_all_times = function(_)

        end
    };
end;
local scratch_buffer_u64 = buffer.create(8);
local function _(param_001)
    return (bit32.band(bit32.rshift(param_001, 8), 255));
end;
local function _(param_002)
    return (bit32.band(bit32.rshift(param_002, 16), 255));
end;
local function _(param_003)
    return (bit32.band(bit32.rshift(param_003, 24), 255));
end;
local function _(param_004)
    return (bit32.band(bit32.rshift(param_004, 16), 65535));
end;
local function _(param_005)
    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_005, 16), 65535)));
    return (buffer.readi16(scratch_buffer_u64, 0));
end;
local function _(param_006)
    return (bit32.rshift(param_006, 8));
end;
local function _(param_007)
    buffer.writeu32(scratch_buffer_u64, 0, (bit32.rshift(param_007, 8)));
    return (bit32.rshift(buffer.readi32(scratch_buffer_u64, 1), 16));
end;
local function _(param_008)
    return (bit32.band(param_008, 255));
end;
local VOWELS_BY_CHAR = {
    A = true,
    a = true,
    E = true,
    e = true,
    I = true,
    i = true,
    O = true,
    o = true,
    U = true,
    u = true
};
local function _(param_009)
    return string.format("%X", param_009);
end;
local HEX_BYTE = {};
for index_001 = 0, 255 do
    HEX_BYTE[index_001] = string.format("%.2X", index_001);
end;
local hex_pair_buffer = buffer.create(2);
local HEX_PAIR_U16 = {};
for hex_pair_index = 0, 255 do
    buffer.writestring(hex_pair_buffer, 0, HEX_BYTE[hex_pair_index]);
    HEX_PAIR_U16[hex_pair_index] = buffer.readu16(hex_pair_buffer, 0);
end;
local HEX_ESCAPE_U32 = {};
for hex_escape_index = 0, 255 do
    HEX_ESCAPE_U32[hex_escape_index] = bit32.bor(bit32.lrotate(HEX_PAIR_U16[hex_escape_index], 16), 30812);
end;
local function _(param_010)
    return HEX_BYTE[param_010];
end;
local function _(param_011)
    return string.format("%.4X", param_011);
end;
local function _(param_012)
    return HEX_BYTE[bit32.rshift(param_012, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(param_012, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(param_012, 8), 255)] .. HEX_BYTE[bit32.band(param_012, 255)];
end;
local function _(param_013)
    assert(param_013);
    return param_013;
end;
local function _(param_014, param_015)
    table.clear(param_014);
    for array_value_001, item_001 in pairs(param_015) do
        param_014[array_value_001] = item_001;
    end;
end;
local function append_array_copy(base_array, items_to_append)
    if #items_to_append > 8 then
        return table.move(items_to_append, 1, #items_to_append, 1, table.clone(base_array));
    else
        local cloned_array = table.clone(base_array);
        for _, append_item in ipairs(items_to_append) do
            table.insert(cloned_array, append_item);
        end;
        return cloned_array;
    end;
end;
local function _(param_016, param_017)
    local array_value_002 = table.clone(param_016);
    for item_002 in pairs(param_017) do
        array_value_002[item_002] = true;
    end;
    return array_value_002;
end;
local function _(param_018, param_019, param_020)
    local condition_value_001 = table.find(param_018, param_019);
    assert(condition_value_001);
    if param_020 == nil then
        table.remove(param_018, condition_value_001);
    else
        param_018[condition_value_001] = param_020;
    end;
    assert(not table.find(param_018, param_019));
end;
local function _(param_021, param_022, param_023)
    for index_002 = #param_021, 1, -1 do
        if param_021[index_002] == param_022 then
            if param_023 == nil then
                table.remove(param_021, index_002);
                return;
            else
                param_021[index_002] = param_023;
                return;
            end;
        end;
    end;
end;
local function shallow_clone_nested_tables(source_table)
    local cloned_table = table.clone(source_table);
    for clone_key, clone_value in pairs(cloned_table) do
        if type(clone_value) == "table" then
            cloned_table[clone_key] = table.clone(clone_value);
        end;
    end;
    return cloned_table;
end;
local function _(param_024, param_025)
    local array_value_003 = param_024[param_025];
    if array_value_003 then
        return array_value_003;
    else
        local table_value_001 = {};
        param_024[param_025] = table_value_001;
        return table_value_001;
    end;
end;
local function _(param_026)
    assert(#param_026 > 0);
end;
local function _(param_027, param_028)
    local array_value_004 = table.create(param_027, param_028);
    if param_028 then
        array_value_004[0] = param_028;
        return array_value_004;
    else
        array_value_004[0] = nil;
        return array_value_004;
    end;
end;
local table_cycle_cache = {};
local function _(param_029, param_030, param_031)
    local condition_value_002 = param_029[param_030];
    if condition_value_002 then
        return condition_value_002[param_031];
    else
        return nil;
    end;
end;
local function _(param_032, param_033, param_034, param_035)
    local condition_value_003 = param_032[param_033];
    if condition_value_003 then
        condition_value_003[param_034] = param_035;
        return;
    else
        param_032[param_033] = {
            [param_034] = param_035
        };
        return;
    end;
end;
local _ = function(param_036, param_037)
    for _, item_003 in ipairs(param_036) do
        if table.find(param_037, item_003) then
            return item_003;
        end;
    end;
    return nil;
end;
local function _()
    table_cycle_cache = {};
end;
local function table_contains_nested_table(current_table, wanted_nested_table, visited_tables)
    local cached_cycle_lookup = table_cycle_cache[current_table];
    local cached_cycle_result = if cached_cycle_lookup then cached_cycle_lookup[wanted_nested_table] else nil;
    if cached_cycle_result then
        return cached_cycle_result;
    else
        local active_visited_tables = visited_tables or {};
        for nested_key, nested_value in current_table do
            if type(nested_key) == "table" then
                if not active_visited_tables[nested_key] then
                    active_visited_tables[nested_key] = true;
                    if nested_key == wanted_nested_table then
                        local cached_table_cycle_cache = table_cycle_cache;
                        local cycle_cache_for_current = cached_table_cycle_cache[current_table];
                        if cycle_cache_for_current then
                            cycle_cache_for_current[wanted_nested_table] = true;
                        else
                            cached_table_cycle_cache[current_table] = {
                                [wanted_nested_table] = true
                            };
                        end;
                        return true;
                    elseif table_contains_nested_table(nested_value, wanted_nested_table, active_visited_tables) then
                        local cached_table_cycle_cache_001 = table_cycle_cache;
                        local cycle_cache_after_recursive_key = cached_table_cycle_cache_001[current_table];
                        if cycle_cache_after_recursive_key then
                            cycle_cache_after_recursive_key[wanted_nested_table] = true;
                        else
                            cached_table_cycle_cache_001[current_table] = {
                                [wanted_nested_table] = true
                            };
                        end;
                        return true;
                    end;
                end;
            elseif type(nested_value) == "table" and not active_visited_tables[nested_value] then
                active_visited_tables[nested_value] = true;
                if nested_value == wanted_nested_table then
                    local cached_table_cycle_cache_002 = table_cycle_cache;
                    local cycle_cache_after_value_hit = cached_table_cycle_cache_002[current_table];
                    if cycle_cache_after_value_hit then
                        cycle_cache_after_value_hit[wanted_nested_table] = true;
                    else
                        cached_table_cycle_cache_002[current_table] = {
                            [wanted_nested_table] = true
                        };
                    end;
                    return true;
                elseif table_contains_nested_table(nested_value, wanted_nested_table, active_visited_tables) then
                    local cached_table_cycle_cache_003 = table_cycle_cache;
                    local cycle_cache_after_recursive_value = cached_table_cycle_cache_003[current_table];
                    if cycle_cache_after_recursive_value then
                        cycle_cache_after_recursive_value[wanted_nested_table] = true;
                    else
                        cached_table_cycle_cache_003[current_table] = {
                            [wanted_nested_table] = true
                        };
                    end;
                    return true;
                end;
            end;
        end;
        cached_cycle_lookup = table_cycle_cache;
        local cycle_cache_root_entry = cached_cycle_lookup[current_table];
        if cycle_cache_root_entry then
            cycle_cache_root_entry[wanted_nested_table] = false;
        else
            cached_cycle_lookup[current_table] = {
                [wanted_nested_table] = false
            };
        end;
        return false;
    end;
end;
local function _(param_038, param_039)
    if param_039 then
        return {
            beginning = param_038,
            ending = param_039
        };
    else
        return {
            beginning = param_038,
            ending = param_038
        };
    end;
end;
local function _(param_040)
    return param_040.ending - param_040.beginning + 1;
end;
local function _(param_041, param_042)
    local range_value_001 = false;
    if param_041.beginning == param_042.beginning then
        range_value_001 = param_041.ending == param_042.ending;
    end;
    return range_value_001;
end;
local function _(param_043)
    return (("range<%*:%*>"):format(param_043.beginning, param_043.ending));
end;
local function _(param_044, param_045, param_046)
    local range_value_002 = false;
    if param_045 <= param_044 then
        range_value_002 = param_044 <= param_046;
    end;
    return range_value_002;
end;
local function _(param_047, param_048)
    local range_beginning = param_048.beginning;
    local range_ending = param_048.ending;
    local range_value_003 = false;
    if range_beginning <= param_047 then
        range_value_003 = param_047 <= range_ending;
    end;
    return range_value_003;
end;
local opcode_defs_by_real_index = nil;
local opcode_def_by_name = nil;
local opcode_def_by_encoded_byte = nil;
local function _(param_049)
    local opcode_value_001 = opcode_def_by_name[param_049];
    if not opcode_value_001 then
        error((("Unknown opname %*"):format(param_049)));
    end;
    return opcode_value_001;
end;
local function _(param_050)
    return opcode_def_by_encoded_byte[param_050];
end;
local JUMP_OPCODE_NAMES = {
    "LOADB",
    "JUMP",
    "JUMPBACK",
    "JUMPIF",
    "JUMPIFNOT",
    "JUMPIFEQ",
    "JUMPIFLE",
    "JUMPIFLT",
    "JUMPIFNOTEQ",
    "JUMPIFNOTLE",
    "JUMPIFNOTLT",
    "FORNPREP",
    "FORNLOOP",
    "FORGLOOP",
    "FORGPREP",
    "FORGPREP_INEXT",
    "DEP_FORGLOOP_INEXT",
    "FORGPREP_NEXT",
    "JUMPX",
    "JUMPXEQKNIL",
    "JUMPXEQKB",
    "JUMPXEQKN",
    "JUMPXEQKS",
    "DEP_JUMPIFEQK",
    "DEP_JUMPIFNOTEQK"
};
local jump_opcode_names_set = nil;
local jump_opcode_bytes_set = nil;
local function initialize_opcode_tables(luau_bytecode_version)
    rebuild_opcode_decoder();
    local opcode_layout_entries = nil;
    if luau_bytecode_version >= 16 then
        error((("Luau version %* not supported. You likely didn't input Luau bytecode, or the bytecode was encoded. No encoding is supported."):format(luau_bytecode_version)));
    elseif luau_bytecode_version >= 4 then
        local deprecated_jump_equal_constant_opcode = {
            opname = "DEP_JUMPIFEQK",
            aux = false
        };
        local subrk_opcode_entry = {
            opname = "SUBRK",
            aux = false
        };
        local deprecated_jump_not_equal_constant_opcode = {
            opname = "DEP_JUMPIFNOTEQK",
            aux = false
        };
        local divrk_opcode_entry = {
            opname = "DIVRK",
            aux = false
        };
        local deprecated_forgloop_inext_opcode_entry = {
            opname = "DEP_FORGLOOP_INEXT",
            aux = false
        };
        local fastcall_three_opcode_entry = {
            opname = "FASTCALL3",
            aux = true
        };
        opcode_layout_entries = {
            {
                opname = "NOP",
                aux = false
            },
            {
                opname = "BREAK",
                aux = false
            },
            {
                opname = "LOADNIL",
                aux = false
            },
            {
                opname = "LOADB",
                aux = false
            },
            {
                opname = "LOADN",
                aux = false
            },
            {
                opname = "LOADK",
                aux = false
            },
            {
                opname = "MOVE",
                aux = false
            },
            {
                opname = "GETGLOBAL",
                aux = true
            },
            {
                opname = "SETGLOBAL",
                aux = true
            },
            {
                opname = "GETUPVAL",
                aux = false
            },
            {
                opname = "SETUPVAL",
                aux = false
            },
            {
                opname = "CLOSEUPVALS",
                aux = false
            },
            {
                opname = "GETIMPORT",
                aux = true
            },
            {
                opname = "GETTABLE",
                aux = false
            },
            {
                opname = "SETTABLE",
                aux = false
            },
            {
                opname = "GETTABLEKS",
                aux = true
            },
            {
                opname = "SETTABLEKS",
                aux = true
            },
            {
                opname = "GETTABLEN",
                aux = false
            },
            {
                opname = "SETTABLEN",
                aux = false
            },
            {
                opname = "NEWCLOSURE",
                aux = false
            },
            {
                opname = "NAMECALL",
                aux = true
            },
            {
                opname = "CALL",
                aux = false
            },
            {
                opname = "RETURN",
                aux = false
            },
            {
                opname = "JUMP",
                aux = false
            },
            {
                opname = "JUMPBACK",
                aux = false
            },
            {
                opname = "JUMPIF",
                aux = false
            },
            {
                opname = "JUMPIFNOT",
                aux = false
            },
            {
                opname = "JUMPIFEQ",
                aux = true
            },
            {
                opname = "JUMPIFLE",
                aux = true
            },
            {
                opname = "JUMPIFLT",
                aux = true
            },
            {
                opname = "JUMPIFNOTEQ",
                aux = true
            },
            {
                opname = "JUMPIFNOTLE",
                aux = true
            },
            {
                opname = "JUMPIFNOTLT",
                aux = true
            },
            {
                opname = "ADD",
                aux = false
            },
            {
                opname = "SUB",
                aux = false
            },
            {
                opname = "MUL",
                aux = false
            },
            {
                opname = "DIV",
                aux = false
            },
            {
                opname = "MOD",
                aux = false
            },
            {
                opname = "POW",
                aux = false
            },
            {
                opname = "ADDK",
                aux = false
            },
            {
                opname = "SUBK",
                aux = false
            },
            {
                opname = "MULK",
                aux = false
            },
            {
                opname = "DIVK",
                aux = false
            },
            {
                opname = "MODK",
                aux = false
            },
            {
                opname = "POWK",
                aux = false
            },
            {
                opname = "AND",
                aux = false
            },
            {
                opname = "OR",
                aux = false
            },
            {
                opname = "ANDK",
                aux = false
            },
            {
                opname = "ORK",
                aux = false
            },
            {
                opname = "CONCAT",
                aux = false
            },
            {
                opname = "NOT",
                aux = false
            },
            {
                opname = "MINUS",
                aux = false
            },
            {
                opname = "LENGTH",
                aux = false
            },
            {
                opname = "NEWTABLE",
                aux = true
            },
            {
                opname = "DUPTABLE",
                aux = false
            },
            {
                opname = "SETLIST",
                aux = true
            },
            {
                opname = "FORNPREP",
                aux = false
            },
            {
                opname = "FORNLOOP",
                aux = false
            },
            {
                opname = "FORGLOOP",
                aux = true
            },
            {
                opname = "FORGPREP_INEXT",
                aux = false
            },
            deprecated_forgloop_inext_opcode_entry,
            {
                opname = "FORGPREP_NEXT",
                aux = false
            },
            {
                opname = "NATIVECALL",
                aux = false
            },
            {
                opname = "GETVARARGS",
                aux = false
            },
            {
                opname = "DUPCLOSURE",
                aux = false
            },
            {
                opname = "PREPVARARGS",
                aux = false
            },
            {
                opname = "LOADKX",
                aux = false
            },
            {
                opname = "JUMPX",
                aux = false
            },
            {
                opname = "FASTCALL",
                aux = false
            },
            {
                opname = "COVERAGE",
                aux = false
            },
            {
                opname = "CAPTURE",
                aux = false
            },
            subrk_opcode_entry,
            divrk_opcode_entry,
            {
                opname = "FASTCALL1",
                aux = false
            },
            {
                opname = "FASTCALL2",
                aux = true
            },
            {
                opname = "FASTCALL2K",
                aux = true
            },
            {
                opname = "FORGPREP",
                aux = false
            },
            {
                opname = "JUMPXEQKNIL",
                aux = true
            },
            {
                opname = "JUMPXEQKB",
                aux = true
            },
            {
                opname = "JUMPXEQKN",
                aux = true
            },
            {
                opname = "JUMPXEQKS",
                aux = true
            },
            {
                opname = "IDIV",
                aux = false
            },
            {
                opname = "IDIVK",
                aux = false
            },
            {
                opname = "GETUDATAKS",
                aux = true
            },
            {
                opname = "SETUDATAKS",
                aux = true
            },
            {
                opname = "NAMECALLUDATA",
                aux = true
            }
        };
        if luau_bytecode_version >= 6 then
            local opcode_replace_index = table.find(opcode_layout_entries, deprecated_forgloop_inext_opcode_entry);
            assert(opcode_replace_index);
            opcode_layout_entries[opcode_replace_index] = fastcall_three_opcode_entry;
        end;
    else
        error((("Luau version %* not supported. Minimum supported version is 4."):format(luau_bytecode_version)));
    end;
    opcode_defs_by_real_index = {};
    for layout_index, layout_entry in ipairs(opcode_layout_entries) do
        local opcode_aux_flag = layout_entry.aux;
        opcode_defs_by_real_index[layout_index] = {
            opname = layout_entry.opname,
            aux = opcode_aux_flag,
            opcode = -1,
            real_opcode = -1,
            size = opcode_aux_flag and 2 or 1
        };
    end;
    for opcode_index, opcode_definition in ipairs(opcode_defs_by_real_index) do
        local real_opcode_index = opcode_index - 1;
        opcode_definition.real_opcode = real_opcode_index;
        opcode_definition.opcode = bit32.band(encode_opcode_byte(real_opcode_index), 255);
    end;
    opcode_def_by_name = {};
    opcode_def_by_encoded_byte = {};
    for _, opcode_lookup_entry in pairs(opcode_defs_by_real_index) do
        opcode_def_by_name[opcode_lookup_entry.opname] = opcode_lookup_entry;
        opcode_def_by_encoded_byte[opcode_lookup_entry.opcode] = opcode_lookup_entry;
    end;
    jump_opcode_names_set = {};
    jump_opcode_bytes_set = {};
    for _, jump_opcode_name in pairs(JUMP_OPCODE_NAMES) do
        if opcode_def_by_name[jump_opcode_name] then
            local jump_opcode_definition = opcode_def_by_name[jump_opcode_name];
            if not jump_opcode_definition then
                error((("Unknown opname %*"):format(jump_opcode_name)));
            end;
            local cached_jump_opcode_definition = jump_opcode_definition;
            jump_opcode_names_set[jump_opcode_name] = true;
            jump_opcode_bytes_set[cached_jump_opcode_definition.opcode] = true;
        end;
    end;
end;
local _ = {
    LOADB = true,
    JUMP = true,
    JUMPBACK = true,
    JUMPX = true
};
local COMPOUND_ASSIGNMENT_BY_KIND = {
    addition = "+=",
    subtraction = "-=",
    multiplication = "*=",
    division = "/=",
    ["floor division"] = "//=",
    exponentiation = "^=",
    concatenation = "..=",
    modulus = "%="
};
local INVERTED_CONDITION_OPERATOR = {
    [">"] = "<=",
    ["<="] = ">",
    ["<"] = ">=",
    [">="] = "<",
    ["=="] = "~=",
    ["~="] = "==",
    exist = "not exist",
    ["not exist"] = "exist"
};
local SWAPPED_CONDITION_OPERATOR = {
    [">"] = "<",
    ["<"] = ">",
    ["<="] = ">=",
    [">="] = "<=",
    ["=="] = "==",
    ["~="] = "~=",
    exist = "not exist",
    ["not exist"] = "exist"
};
local LUAU_RESERVED_KEYWORDS = {
    ["end"] = true,
    ["if"] = true,
    ["local"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["function"] = true,
    ["break"] = true,
    ["then"] = true,
    ["and"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["until"] = true,
    ["for"] = true,
    ["do"] = true,
    ["in"] = true,
    ["nil"] = true,
    ["true"] = true,
    ["false"] = true,
    ["not"] = true,
    ["return"] = true
};
local LUAU_KEYWORDS_REQUIRING_SUFFIX = {
    ["for"] = true
};
local MULTI_RETURN_EXPRESSION_TYPES = {
    call = true,
    varargs = true
};
local FASTCALL_FUNCTION_NAMES = {
    [0] = "<none>";
    "assert",
    "math.abs",
    "math.acos",
    "math.asin",
    "math.atan2",
    "math.atan",
    "math.ceil",
    "math.cosh",
    "math.cos",
    "math.deg",
    "math.exp",
    "math.floor",
    "math.fmod",
    "math.frexp",
    "math.ldexp",
    "math.log10",
    "math.log",
    "math.max",
    "math.min",
    "math.modf",
    "math.pow",
    "math.rad",
    "math.sinh",
    "math.sin",
    "math.sqrt",
    "math.tanh",
    "math.tan",
    "bit32.arshift",
    "bit32.band",
    "bit32.bnot",
    "bit32.bor",
    "bit32.bxor",
    "bit32.btest",
    "bit32.extract",
    "bit32.lrotate",
    "bit32.lshift",
    "bit32.replace",
    "bit32.rrotate",
    "bit32.rshift",
    "type",
    "string.byte",
    "string.char",
    "string.len",
    "typeof",
    "string.sub",
    "math.clamp",
    "math.sign",
    "math.round",
    "rawset",
    "rawget",
    "rawequal",
    "table.insert",
    "table.unpack",
    "vector",
    "bit32.countlz",
    "bit32.countrz",
    "select.vararg",
    "rawlen",
    "bit32.extractk",
    "getmetatable",
    "setmetatable",
    "tonumber",
    "tostring",
    "bit32.byteswap",
    "buffer.readi8",
    "buffer.readu8",
    "buffer.writeu8",
    "buffer.readi16",
    "buffer.readu16",
    "buffer.writeu16",
    "buffer.readi32",
    "buffer.readu32",
    "buffer.writeu32",
    "buffer.readf32",
    "buffer.writef32",
    "buffer.readf64",
    "buffer.writef64"
};
local function _(param_051)
    table.move(param_051, 1, #param_051, 0, param_051);
    table.remove(param_051, #param_051);
end;
local function _(param_052, param_053)
    if param_053 then
        return not param_052;
    else
        return param_052;
    end;
end;
local strict_type_info_enabled = true;
local allow_new_type_info_fallback = false;
local ignore_unsupported_debug_info = true;
local function deserialize_luau_bytecode(bytecode_input)
    local bytecode_buffer = nil;
    bytecode_buffer = if type(bytecode_input) == "buffer" then bytecode_input else buffer.fromstring(bytecode_input);
    last_yield_time = elapsed_time_ref();
    local reader_offset = 0;
    local v_safe_len = buffer.len(bytecode_buffer);
    local function v_safe_need(v_safe_n)
        if reader_offset + v_safe_n > v_safe_len then
            error((("Corrupted bytecode: unexpected end of buffer at offset %*, need %* byte(s), length %*"):format(reader_offset, v_safe_n, v_safe_len)));
        end;
    end;
    local function v_safe_readu8()
        v_safe_need(1);
        local v_safe_value = buffer.readu8(bytecode_buffer, reader_offset);
        reader_offset = reader_offset + 1;
        return v_safe_value;
    end;
    local function v_safe_readu32()
        v_safe_need(4);
        local v_safe_value = buffer.readu32(bytecode_buffer, reader_offset);
        reader_offset = reader_offset + 4;
        return v_safe_value;
    end;
    local function v_safe_readf32()
        v_safe_need(4);
        local v_safe_value = buffer.readf32(bytecode_buffer, reader_offset);
        reader_offset = reader_offset + 4;
        return v_safe_value;
    end;
    local function v_safe_readf64()
        v_safe_need(8);
        local v_safe_value = buffer.readf64(bytecode_buffer, reader_offset);
        reader_offset = reader_offset + 8;
        return v_safe_value;
    end;
    local function v_safe_copy(v_safe_dst, v_safe_dst_offset, v_safe_n)
        v_safe_need(v_safe_n);
        buffer.copy(v_safe_dst, v_safe_dst_offset, bytecode_buffer, reader_offset, v_safe_n);
        reader_offset = reader_offset + v_safe_n;
    end;
    local function _()
        local read_byte_value = v_safe_readu8();
        return read_byte_value;
    end;
    local function read_varint()
        local varint_byte = nil;
        local varint_shift = 0;
        local varint_result = 0;
        while true do
            local current_varint_byte = v_safe_readu8();
            varint_byte = current_varint_byte;
            varint_result = bit32.bor(varint_result, (bit32.lshift(bit32.band(varint_byte, 127), varint_shift)));
            varint_shift = varint_shift + 7;
            if varint_shift > 35 then
                error("Corrupted bytecode: malformed varint");
            end;
            if not (bit32.band(varint_byte, 128) ~= 0) then
                break;
            end;
        end;
        return varint_result;
    end;
    local function _()
        local read_u32_value = v_safe_readu32();
        return read_u32_value;
    end;
    local function _()
        local read_f32_value = v_safe_readf32();
        return read_f32_value;
    end;
    local function _()
        local read_f64_value = v_safe_readf64();
        return read_f64_value;
    end;
    local function read_bytecode_string()
        local string_byte_length = read_varint();
        v_safe_need(string_byte_length);
        local string_buffer = buffer.create(string_byte_length);
        v_safe_copy(string_buffer, 0, string_byte_length);
        return buffer.tostring(string_buffer);
    end;
    local type_info_version = v_safe_readu8();
    local cached_type_info_version = type_info_version;
    initialize_opcode_tables(cached_type_info_version);
    type_info_version = nil;
    if cached_type_info_version >= 4 then
        local raw_type_info_version = v_safe_readu8();
        type_info_version = raw_type_info_version;
        if type_info_version > 3 then
            if strict_type_info_enabled or not allow_new_type_info_fallback then
                error((("Types version %* not supported. Only versions 1 to 3 are supported. Pass allow_new_type_info_fallback = true only if you explicitly accept an unsafe best-effort parse."):format(type_info_version)));
            else
                -- Unsafe compatibility mode for newer Luau type-info streams.
                -- This can desynchronize the bytecode cursor if the layout changed.
                type_info_version = 3;
            end;
        end;
    end;
    local parsed_protos = {};
    local string_table = {};
    for _ = 1, read_varint() do
        table.insert(string_table, read_bytecode_string());
    end;
    local _ = {};
    if type_info_version == 3 then
        local userdata_remap_tag = v_safe_readu8();
        local cached_userdata_remap_tag = userdata_remap_tag;
        while cached_userdata_remap_tag ~= 0 do
            local userdata_remap_length = read_varint();
            v_safe_need(userdata_remap_length);
            local userdata_remap_buffer = buffer.create(userdata_remap_length);
            v_safe_copy(userdata_remap_buffer, 0, userdata_remap_length);
            userdata_remap_tag = buffer.tostring(userdata_remap_buffer);
            userdata_remap_length = v_safe_readu8();
            cached_userdata_remap_tag = userdata_remap_length;
        end;
    end;
    local proto_count = read_varint();
    if buffer.len(bytecode_buffer) / 11 <= proto_count then
        error("Corrupted bytecode. If the `luau_load` is able to load this bytecode, then this is a bug");
    end;
    for _ = 1, proto_count do
        table.insert(parsed_protos, {});
    end;
    for proto_index = 1, proto_count do
        local proto_data = parsed_protos[proto_index];
        local code_size = v_safe_readu8();
        proto_data.stack_size = code_size;
        code_size = v_safe_readu8();
        proto_data.params_count = code_size;
        code_size = v_safe_readu8();
        proto_data.upvalues_count = code_size;
        local code_words = v_safe_readu8();
        proto_data.is_vararg = code_words ~= 0;
        code_size = v_safe_readu8();
        proto_data.flags = code_size;
        local type_info_entries = {};
        if type_info_version == 1 then
            for type_info_index = 1, read_varint() do
                local type_info_byte = v_safe_readu8();
                type_info_entries[type_info_index] = type_info_byte;
            end;
        elseif not (type_info_version ~= 2) or type_info_version == 3 then
            for type_info_index_modern = 1, read_varint() do
                local type_info_byte_modern = v_safe_readu8();
                type_info_entries[type_info_index_modern] = type_info_byte_modern;
            end;
        end;
        proto_data.type_info = type_info_entries;
        table.move(type_info_entries, 1, #type_info_entries, 0, type_info_entries);
        table.remove(type_info_entries, #type_info_entries);
        code_size = read_varint();
        code_words = table.create(code_size);
        for code_word_index = 1, code_size do
            local instruction_word = v_safe_readu32();
            code_words[code_word_index] = instruction_word;
        end;
        proto_data.code = code_words;
        table.move(code_words, 1, #code_words, 0, code_words);
        table.remove(code_words, #code_words);
        local constant_count = read_varint();
        local constants = table.create(constant_count);
        for _ = 1, constant_count do
            local constant_entry = nil;
            local constant_type_or_entry = v_safe_readu8();
            local cached_constant_type_or_entry = constant_type_or_entry;
            if cached_constant_type_or_entry == 2 then
                constant_type_or_entry = {
                    type = 2
                };
                local number_constant = v_safe_readf64();
                constant_type_or_entry.value = number_constant;
                constant_entry = constant_type_or_entry;
            elseif cached_constant_type_or_entry == 3 then
                constant_entry = {
                    type = 3,
                    value = string_table[read_varint()]
                };
            elseif cached_constant_type_or_entry == 6 then
                constant_entry = {
                    type = 6,
                    value = read_varint()
                };
            elseif cached_constant_type_or_entry == 5 then
                constant_entry = {
                    type = 5,
                    value = {}
                };
                for _ = 1, read_varint() do
                    read_varint();
                end;
            elseif cached_constant_type_or_entry == 4 then
                constant_type_or_entry = v_safe_readu32();
                constant_entry = {
                    type = 4,
                    value = constant_type_or_entry
                };
            elseif cached_constant_type_or_entry == 1 then
                constant_type_or_entry = {
                    type = 1
                };
                local boolean_constant_byte = v_safe_readu8();
                constant_type_or_entry.value = boolean_constant_byte ~= 0;
                constant_entry = constant_type_or_entry;
            elseif cached_constant_type_or_entry == 0 then
                constant_entry = {
                    type = 0,
                    value = nil
                };
            elseif cached_constant_type_or_entry == 7 and cached_type_info_version >= 5 then
                constant_type_or_entry = {
                    type = 7
                };
                local vector_constructor = vector_three_compat.new;
                local vector_component_x_or_padding = v_safe_readf32();
                local cached_vector_component_x_or_padding = vector_component_x_or_padding;
                local vector_component_y = v_safe_readf32();
                vector_component_x_or_padding = vector_component_y;
                local vector_component_z = v_safe_readf32();
                constant_type_or_entry.value = vector_constructor(cached_vector_component_x_or_padding, vector_component_x_or_padding, vector_component_z);
                constant_entry = constant_type_or_entry;
                constant_type_or_entry = v_safe_readf32();
            else
                error((("Unknown constant type %*"):format(cached_constant_type_or_entry)));
            end;
            table.insert(constants, constant_entry);
        end;
        table.move(constants, 1, #constants, 0, constants);
        table.remove(constants, #constants);
        proto_data.constants = constants;
        local child_proto_count = read_varint();
        local child_protos = table.create(child_proto_count);
        for _ = 1, child_proto_count do
            table.insert(child_protos, parsed_protos[read_varint() + 1]);
        end;
        table.move(child_protos, 1, #child_protos, 0, child_protos);
        table.remove(child_protos, #child_protos);
        proto_data.protos = child_protos;
        proto_data.line_defined = read_varint();
        proto_data.debug_name = string_table[read_varint()];
        local debug_info_version = v_safe_readu8();
        if debug_info_version > 0 then
            local line_info_gaplog_or_entries = v_safe_readu8();
            debug_info_version = line_info_gaplog_or_entries;
            line_info_gaplog_or_entries = table.create(code_size);
            for _ = 1, code_size do
                local line_info_byte = v_safe_readu8();
                table.insert(line_info_gaplog_or_entries, line_info_byte);
            end;
            table.move(line_info_gaplog_or_entries, 1, #line_info_gaplog_or_entries, 0, line_info_gaplog_or_entries);
            table.remove(line_info_gaplog_or_entries, #line_info_gaplog_or_entries);
            proto_data.line_info = line_info_gaplog_or_entries;
            local _ = bit32.band(code_size + 3, -4);
            local abs_line_info_count = bit32.rshift(code_size - 1, debug_info_version) + 1;
            local abs_line_info_entries = table.create(abs_line_info_count);
            for _ = 1, abs_line_info_count do
                local abs_line_info_word = v_safe_readu32();
                table.insert(abs_line_info_entries, abs_line_info_word);
            end;
            table.move(abs_line_info_entries, 1, #abs_line_info_entries, 0, abs_line_info_entries);
            table.remove(abs_line_info_entries, #abs_line_info_entries);
            proto_data.abs_line_info = abs_line_info_entries;
        end;
        local aux_debug_info_version = v_safe_readu8();
        debug_info_version = aux_debug_info_version;
        if debug_info_version > 0 then
            if debug_info_version ~= 1 and not ignore_unsupported_debug_info then
                error((("g2 unsupported by deserializer (%*)"):format(HEX_BYTE[debug_info_version])));
            end;
            -- Luau debug-info block. We do not currently use these names here, but we must
            -- consume the stream so following protos keep the correct byte offset.
            local v_debug_locals_count = read_varint();
            for _ = 1, v_debug_locals_count do
                read_varint(); -- local name string id
                read_varint(); -- start pc
                read_varint(); -- end pc
                v_safe_readu8(); -- register
            end;
            local v_debug_upvalues_count = read_varint();
            for _ = 1, v_debug_upvalues_count do
                read_varint(); -- upvalue name string id
            end;
        end;
    end;
    table.move(parsed_protos, 1, #parsed_protos, 0, parsed_protos);
    table.remove(parsed_protos, #parsed_protos);
    return parsed_protos[read_varint()], parsed_protos, cached_type_info_version, type_info_version;
end;
local current_instruction_index = 0;
local last_multireturn_register = 0;
local current_proto_context = nil;
local current_function_context = nil;
local analyze_register_usage = nil;
local is_non_printable_byte = 0;
local function escape_byte_or_noop_handler(_)
    return {}, {};
end;
local register_usage_handlers_or_quote_string = {
    FASTCALL = escape_byte_or_noop_handler,
    FASTCALL1 = escape_byte_or_noop_handler,
    FASTCALL2 = escape_byte_or_noop_handler,
    FASTCALL2K = escape_byte_or_noop_handler,
    FASTCALL3 = escape_byte_or_noop_handler,
    JUMP = escape_byte_or_noop_handler,
    JUMPX = escape_byte_or_noop_handler,
    JUMPBACK = escape_byte_or_noop_handler,
    COVERAGE = escape_byte_or_noop_handler,
    CLOSEUPVALS = escape_byte_or_noop_handler,
    PREPVARARGS = escape_byte_or_noop_handler,
    GETVARARGS = function(param_054)
        local instruction_word_001 = param_054.inst;
        local instruction_value_001 = bit32.band(bit32.rshift(instruction_word_001, 8), 255);
        local table_value_002 = {};
        local instruction_value_002 = bit32.band(bit32.rshift(instruction_word_001, 16), 255) - 1;
        if instruction_value_002 == -1 then
            instruction_value_002 = 1;
            last_multireturn_register = instruction_value_001;
        end;
        for index_003 = instruction_value_001, instruction_value_001 + instruction_value_002 - 1 do
            table.insert(table_value_002, index_003);
        end;
        return {}, table_value_002;
    end,
    MOVE = function(param_055)
        local source_instruction_word = param_055.inst;
        return {
            (bit32.band(bit32.rshift(source_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(source_instruction_word, 8), 255))
        }, "copies";
    end,
    LOADK = function(param_056)
        return {}, {
            (bit32.band(bit32.rshift(param_056.inst, 8), 255))
        };
    end,
    LOADKX = function(param_057)
        return {}, {
            (bit32.band(bit32.rshift(param_057.inst, 8), 255))
        };
    end,
    LOADN = function(param_058)
        return {}, {
            (bit32.band(bit32.rshift(param_058.inst, 8), 255))
        };
    end,
    LOADNIL = function(param_059)
        return {}, {
            (bit32.band(bit32.rshift(param_059.inst, 8), 255))
        };
    end,
    LOADB = function(param_060)
        return {}, {
            (bit32.band(bit32.rshift(param_060.inst, 8), 255))
        };
    end,
    NEWTABLE = function(param_061)
        return {}, {
            (bit32.band(bit32.rshift(param_061.inst, 8), 255))
        };
    end,
    DUPTABLE = function(param_062)
        return {}, {
            (bit32.band(bit32.rshift(param_062.inst, 8), 255))
        };
    end,
    SETTABLE = function(param_063)
        local table_set_instruction_word = param_063.inst;
        return {
            bit32.band(bit32.rshift(table_set_instruction_word, 24), 255),
            bit32.band(bit32.rshift(table_set_instruction_word, 8), 255),
            (bit32.band(bit32.rshift(table_set_instruction_word, 16), 255))
        }, {};
    end,
    SETTABLEKS = function(param_064)
        local table_key_set_instruction_word = param_064.inst;
        return {
            bit32.band(bit32.rshift(table_key_set_instruction_word, 8), 255),
            (bit32.band(bit32.rshift(table_key_set_instruction_word, 16), 255))
        }, {};
    end,
    SETUDATAKS = function(param_064)
        local table_key_set_instruction_word = param_064.inst;
        return {
            bit32.band(bit32.rshift(table_key_set_instruction_word, 8), 255),
            (bit32.band(bit32.rshift(table_key_set_instruction_word, 16), 255))
        }, {};
    end,
    SETTABLEN = function(param_065)
        local table_number_set_instruction_word = param_065.inst;
        return {
            bit32.band(bit32.rshift(table_number_set_instruction_word, 8), 255),
            (bit32.band(bit32.rshift(table_number_set_instruction_word, 16), 255))
        }, {};
    end,
    GETTABLE = function(param_066)
        local table_get_instruction_word = param_066.inst;
        return {
            bit32.band(bit32.rshift(table_get_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(table_get_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(table_get_instruction_word, 8), 255))
        };
    end,
    GETTABLEKS = function(param_067)
        local table_key_get_instruction_word = param_067.inst;
        return {
            (bit32.band(bit32.rshift(table_key_get_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(table_key_get_instruction_word, 8), 255))
        };
    end,
    GETUDATAKS = function(param_067)
        local table_key_get_instruction_word = param_067.inst;
        return {
            (bit32.band(bit32.rshift(table_key_get_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(table_key_get_instruction_word, 8), 255))
        };
    end,
    GETTABLEN = function(param_068)
        local table_number_get_instruction_word = param_068.inst;
        return {
            (bit32.band(bit32.rshift(table_number_get_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(table_number_get_instruction_word, 8), 255))
        };
    end,
    SETLIST = function(param_069)
        local setlist_instruction_word = param_069.inst;
        local instruction_value_003 = bit32.band(bit32.rshift(setlist_instruction_word, 8), 255);
        local instruction_value_004 = bit32.band(bit32.rshift(setlist_instruction_word, 16), 255);
        local instruction_value_005 = bit32.band(bit32.rshift(setlist_instruction_word, 24), 255) - 1;
        local table_value_003 = {};
        local cached_instruction_value_001 = instruction_value_004;
        local array_value_005 = if instruction_value_005 == -1 then last_multireturn_register else instruction_value_004 + instruction_value_005 - 1;
        for index_004 = cached_instruction_value_001, array_value_005 do
            table.insert(table_value_003, index_004);
        end;
        table.insert(table_value_003, instruction_value_003);
        return table_value_003, {};
    end,
    GETUPVAL = function(param_070)
        return {}, {
            (bit32.band(bit32.rshift(param_070.inst, 8), 255))
        };
    end,
    SETUPVAL = function(param_071)
        return {
            (bit32.band(bit32.rshift(param_071.inst, 8), 255))
        }, {};
    end,
    GETIMPORT = function(param_072)
        return {}, {
            (bit32.band(bit32.rshift(param_072.inst, 8), 255))
        };
    end,
    GETGLOBAL = function(param_073)
        return {}, {
            (bit32.band(bit32.rshift(param_073.inst, 8), 255))
        };
    end,
    SETGLOBAL = function(param_074)
        return {
            (bit32.band(bit32.rshift(param_074.inst, 8), 255))
        }, {};
    end,
    NAMECALL = function(param_075)
        local namecall_instruction_word = param_075.inst;
        local instruction_value_006 = bit32.band(bit32.rshift(namecall_instruction_word, 8), 255);
        return {
            (bit32.band(bit32.rshift(namecall_instruction_word, 16), 255))
        }, {
            instruction_value_006,
            instruction_value_006 + 1
        };
    end,
    NAMECALLUDATA = function(param_075)
        local namecall_instruction_word = param_075.inst;
        local instruction_value_006 = bit32.band(bit32.rshift(namecall_instruction_word, 8), 255);
        return {
            (bit32.band(bit32.rshift(namecall_instruction_word, 16), 255))
        }, {
            instruction_value_006,
            instruction_value_006 + 1
        };
    end,
    RETURN = function(param_076)
        local return_instruction_word = param_076.inst;
        local instruction_value_007 = bit32.band(bit32.rshift(return_instruction_word, 8), 255);
        local instruction_value_008 = bit32.band(bit32.rshift(return_instruction_word, 16), 255) - 1;
        local table_value_004 = {};
        local cached_instruction_value_002 = instruction_value_007;
        local array_value_006 = if instruction_value_008 == -1 then last_multireturn_register else instruction_value_007 + instruction_value_008 - 1;
        for index_005 = cached_instruction_value_002, array_value_006 do
            table.insert(table_value_004, index_005);
        end;
        return table_value_004, {};
    end,
    CALL = function(param_077)
        local call_instruction_word = param_077.inst;
        local instruction_value_009 = bit32.band(bit32.rshift(call_instruction_word, 8), 255);
        local instruction_value_010 = bit32.band(bit32.rshift(call_instruction_word, 16), 255) - 1;
        local instruction_value_011 = bit32.band(bit32.rshift(call_instruction_word, 24), 255) - 1;
        if instruction_value_010 == -1 then
            instruction_value_010 = last_multireturn_register - instruction_value_009;
        end;
        local table_value_005 = {
            instruction_value_009
        };
        local table_value_006 = {};
        for index_006 = instruction_value_009 + 1, instruction_value_009 + instruction_value_010 do
            table.insert(table_value_005, index_006);
        end;
        if instruction_value_011 == -1 then
            instruction_value_011 = 1;
            last_multireturn_register = instruction_value_009;
        end;
        for index_007 = instruction_value_009, instruction_value_009 + instruction_value_011 - 1 do
            table.insert(table_value_006, index_007);
        end;
        return table_value_005, table_value_006;
    end,
    DUPCLOSURE = function(param_078)
        return {}, {
            (bit32.band(bit32.rshift(param_078.inst, 8), 255))
        };
    end,
    NEWCLOSURE = function(param_079)
        return {}, {
            (bit32.band(bit32.rshift(param_079.inst, 8), 255))
        };
    end,
    ADD = function(param_080)
        local add_instruction_word = param_080.inst;
        return {
            bit32.band(bit32.rshift(add_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(add_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(add_instruction_word, 8), 255))
        };
    end,
    ADDK = function(param_081)
        local addk_instruction_word = param_081.inst;
        return {
            (bit32.band(bit32.rshift(addk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(addk_instruction_word, 8), 255))
        };
    end,
    SUB = function(param_082)
        local sub_instruction_word = param_082.inst;
        return {
            bit32.band(bit32.rshift(sub_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(sub_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(sub_instruction_word, 8), 255))
        };
    end,
    SUBK = function(param_083)
        local subk_instruction_word = param_083.inst;
        return {
            (bit32.band(bit32.rshift(subk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(subk_instruction_word, 8), 255))
        };
    end,
    MUL = function(param_084)
        local mul_instruction_word = param_084.inst;
        return {
            bit32.band(bit32.rshift(mul_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(mul_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(mul_instruction_word, 8), 255))
        };
    end,
    MULK = function(param_085)
        local mulk_instruction_word = param_085.inst;
        return {
            (bit32.band(bit32.rshift(mulk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(mulk_instruction_word, 8), 255))
        };
    end,
    DIV = function(param_086)
        local div_instruction_word = param_086.inst;
        return {
            bit32.band(bit32.rshift(div_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(div_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(div_instruction_word, 8), 255))
        };
    end,
    DIVK = function(param_087)
        local divk_instruction_word = param_087.inst;
        return {
            (bit32.band(bit32.rshift(divk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(divk_instruction_word, 8), 255))
        };
    end,
    SUBRK = function(param_088)
        local subrk_instruction_word = param_088.inst;
        return {
            (bit32.band(bit32.rshift(subrk_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(subrk_instruction_word, 8), 255))
        };
    end,
    DIVRK = function(param_089)
        local divrk_instruction_word = param_089.inst;
        return {
            (bit32.band(bit32.rshift(divrk_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(divrk_instruction_word, 8), 255))
        };
    end,
    IDIV = function(param_090)
        local idiv_instruction_word = param_090.inst;
        return {
            bit32.band(bit32.rshift(idiv_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(idiv_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(idiv_instruction_word, 8), 255))
        };
    end,
    IDIVK = function(param_091)
        local idivk_instruction_word = param_091.inst;
        return {
            (bit32.band(bit32.rshift(idivk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(idivk_instruction_word, 8), 255))
        };
    end,
    POW = function(param_092)
        local pow_instruction_word = param_092.inst;
        return {
            bit32.band(bit32.rshift(pow_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(pow_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(pow_instruction_word, 8), 255))
        };
    end,
    POWK = function(param_093)
        local powk_instruction_word = param_093.inst;
        return {
            (bit32.band(bit32.rshift(powk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(powk_instruction_word, 8), 255))
        };
    end,
    MOD = function(param_094)
        local mod_instruction_word = param_094.inst;
        return {
            bit32.band(bit32.rshift(mod_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(mod_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(mod_instruction_word, 8), 255))
        };
    end,
    MODK = function(param_095)
        local modk_instruction_word = param_095.inst;
        return {
            (bit32.band(bit32.rshift(modk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(modk_instruction_word, 8), 255))
        };
    end,
    AND = function(param_096)
        local and_instruction_word = param_096.inst;
        return {
            bit32.band(bit32.rshift(and_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(and_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(and_instruction_word, 8), 255))
        };
    end,
    ANDK = function(param_097)
        local andk_instruction_word = param_097.inst;
        return {
            (bit32.band(bit32.rshift(andk_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(andk_instruction_word, 8), 255))
        };
    end,
    OR = function(param_098)
        local or_instruction_word = param_098.inst;
        return {
            bit32.band(bit32.rshift(or_instruction_word, 16), 255),
            (bit32.band(bit32.rshift(or_instruction_word, 24), 255))
        }, {
            (bit32.band(bit32.rshift(or_instruction_word, 8), 255))
        };
    end,
    ORK = function(param_099)
        local ork_instruction_word = param_099.inst;
        return {
            (bit32.band(bit32.rshift(ork_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(ork_instruction_word, 8), 255))
        };
    end,
    CONCAT = function(param_100)
        local concat_instruction_word = param_100.inst;
        local instruction_value_012 = bit32.band(bit32.rshift(concat_instruction_word, 16), 255);
        local array_value_007 = bit32.band(bit32.rshift(concat_instruction_word, 24), 255);
        local table_value_007 = {};
        for index_008 = instruction_value_012, array_value_007 do
            table.insert(table_value_007, index_008);
        end;
        return table_value_007, {
            (bit32.band(bit32.rshift(concat_instruction_word, 8), 255))
        };
    end,
    NOT = function(param_101)
        local not_instruction_word = param_101.inst;
        return {
            (bit32.band(bit32.rshift(not_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(not_instruction_word, 8), 255))
        };
    end,
    MINUS = function(param_102)
        local minus_instruction_word = param_102.inst;
        return {
            (bit32.band(bit32.rshift(minus_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(minus_instruction_word, 8), 255))
        };
    end,
    LENGTH = function(param_103)
        local length_instruction_word = param_103.inst;
        return {
            (bit32.band(bit32.rshift(length_instruction_word, 16), 255))
        }, {
            (bit32.band(bit32.rshift(length_instruction_word, 8), 255))
        };
    end,
    NATIVECALL = function(_)
        return {}, {};
    end,
    BREAK = function(_)
        return {}, {};
    end,
    NOP = function(_)
        return {}, {};
    end,
    CAPTURE = function(param_104)
        local capture_instruction_word = param_104.inst;
        if bit32.band(bit32.rshift(capture_instruction_word, 8), 255) ~= 2 then
            return {
                (bit32.band(bit32.rshift(capture_instruction_word, 16), 255))
            }, {};
        else
            return {}, {};
        end;
    end,
    JUMPIF = function(param_105)
        return {
            (bit32.band(bit32.rshift(param_105.inst, 8), 255))
        }, {};
    end,
    JUMPIFNOT = function(param_106)
        return {
            (bit32.band(bit32.rshift(param_106.inst, 8), 255))
        }, {};
    end,
    JUMPIFEQ = function(param_107)
        local jump_equal_aux_register = param_107.aux;
        assert(jump_equal_aux_register);
        return {
            bit32.band(bit32.rshift(param_107.inst, 8), 255),
            jump_equal_aux_register
        }, {};
    end,
    JUMPIFLE = function(param_108)
        local jump_less_equal_aux_register = param_108.aux;
        assert(jump_less_equal_aux_register);
        return {
            bit32.band(bit32.rshift(param_108.inst, 8), 255),
            jump_less_equal_aux_register
        }, {};
    end,
    JUMPIFLT = function(param_109)
        local jump_less_than_aux_register = param_109.aux;
        assert(jump_less_than_aux_register);
        return {
            bit32.band(bit32.rshift(param_109.inst, 8), 255),
            jump_less_than_aux_register
        }, {};
    end,
    JUMPIFNOTEQ = function(param_110)
        local jump_not_equal_aux_register = param_110.aux;
        assert(jump_not_equal_aux_register);
        return {
            bit32.band(bit32.rshift(param_110.inst, 8), 255),
            jump_not_equal_aux_register
        }, {};
    end,
    JUMPIFNOTLE = function(param_111)
        local jump_not_less_equal_aux_register = param_111.aux;
        assert(jump_not_less_equal_aux_register);
        return {
            bit32.band(bit32.rshift(param_111.inst, 8), 255),
            jump_not_less_equal_aux_register
        }, {};
    end,
    JUMPIFNOTLT = function(param_112)
        local jump_not_less_than_aux_register = param_112.aux;
        assert(jump_not_less_than_aux_register);
        return {
            bit32.band(bit32.rshift(param_112.inst, 8), 255),
            jump_not_less_than_aux_register
        }, {};
    end,
    JUMPXEQKNIL = function(param_113)
        return {
            (bit32.band(bit32.rshift(param_113.inst, 8), 255))
        }, {};
    end,
    JUMPXEQKB = function(param_114)
        return {
            (bit32.band(bit32.rshift(param_114.inst, 8), 255))
        }, {};
    end,
    JUMPXEQKN = function(param_115)
        return {
            (bit32.band(bit32.rshift(param_115.inst, 8), 255))
        }, {};
    end,
    JUMPXEQKS = function(param_116)
        return {
            (bit32.band(bit32.rshift(param_116.inst, 8), 255))
        }, {};
    end,
    FORNPREP = function(param_117)
        local instruction_value_013 = bit32.band(bit32.rshift(param_117.inst, 8), 255);
        return {
            instruction_value_013,
            instruction_value_013 + 1,
            instruction_value_013 + 2
        }, {};
    end,
    FORNLOOP = function(param_118)
        local instruction_value_014 = bit32.band(bit32.rshift(param_118.inst, 8), 255);
        return {
            instruction_value_014,
            instruction_value_014 + 1,
            instruction_value_014 + 2
        }, {
            instruction_value_014 + 2,
            instruction_value_014 + 3
        };
    end,
    FORGPREP = function(param_119)
        local instruction_value_015 = bit32.band(bit32.rshift(param_119.inst, 8), 255);
        return {
            instruction_value_015,
            instruction_value_015 + 1,
            instruction_value_015 + 2
        }, {};
    end,
    FORGPREP_NEXT = function(param_120)
        local instruction_value_016 = bit32.band(bit32.rshift(param_120.inst, 8), 255);
        return {
            instruction_value_016,
            instruction_value_016 + 1,
            instruction_value_016 + 2
        }, {};
    end,
    FORGPREP_INEXT = function(param_121)
        local instruction_value_017 = bit32.band(bit32.rshift(param_121.inst, 8), 255);
        return {
            instruction_value_017,
            instruction_value_017 + 1,
            instruction_value_017 + 2
        }, {};
    end,
    FORGLOOP = function(param_122)
        local instruction_value_018 = bit32.band(bit32.rshift(param_122.inst, 8), 255);
        local table_value_008 = {
            instruction_value_018 + 2
        };
        local array_value_008 = 1;
        local generic_loop_aux_word = param_122.aux;
        assert(generic_loop_aux_word);
        for index_009 = array_value_008, bit32.band(generic_loop_aux_word, 255) do
            table.insert(table_value_008, instruction_value_018 + 2 + index_009);
        end;
        return {
            instruction_value_018,
            instruction_value_018 + 1,
            instruction_value_018 + 2
        }, table_value_008;
    end
};
local cached_register_usage_handlers_or_quote_string = register_usage_handlers_or_quote_string ;
do
    local cached_is_non_printable_byte = is_non_printable_byte;
    analyze_register_usage = function(param_123)
        local cached_opname = param_123.opname;
        local opcode_value_002 = cached_register_usage_handlers_or_quote_string[cached_opname];
        if opcode_value_002 then
            local opcode_value_003, opcode_value_004, opcode_value_005 = opcode_value_002(param_123);
            local opcode_value_006 = -1;
            for _, item_004 in ipairs(opcode_value_004) do
                if opcode_value_006 < item_004 then
                    opcode_value_006 = item_004;
                end;
            end;
            if opcode_value_006 >= 0 and cached_opname ~= "NAMECALL" then
                cached_is_non_printable_byte = opcode_value_006;
            end;
            return opcode_value_003, opcode_value_004, opcode_value_005;
        else
            error((("Unknown opname %*"):format(cached_opname)));
            return;
        end;
    end;
end;
is_non_printable_byte = function(byte_value_to_check)
    local opcode_value_007 = true;
    if byte_value_to_check >= 32 then
        opcode_value_007 = byte_value_to_check > 126;
    end;
    return opcode_value_007;
end;
escape_byte_or_noop_handler = function(byte_to_escape)
    if byte_to_escape == 11 then
        return "\\v";
    elseif byte_to_escape == 10 then
        return "\\n";
    elseif byte_to_escape == 9 then
        return "\\t";
    elseif byte_to_escape == 7 then
        return "\\a";
    elseif byte_to_escape == 13 then
        return "\\r";
    elseif byte_to_escape == 12 then
        return "\\f";
    elseif byte_to_escape == 8 then
        return "\\b";
    else
        return "\\x" .. HEX_BYTE[byte_to_escape];
    end;
end;
register_usage_handlers_or_quote_string = function(quote_behavior, raw_string_value, template_string_mode)
    if #raw_string_value == 1 then
        local string_value_001 = (not (quote_behavior ~= "single char, single quotes") or quote_behavior == "single quotes") and "'" or "\"";
        local string_value_002 = string.byte(raw_string_value);
        local string_value_003 = true;
        if string_value_002 >= 32 then
            string_value_003 = string_value_002 > 126;
        end;
        if string_value_003 then
            if template_string_mode then
                return (escape_byte_or_noop_handler(string_value_002));
            else
                return string_value_001 .. escape_byte_or_noop_handler(string_value_002) .. string_value_001;
            end;
        elseif raw_string_value == string_value_001 then
            if string_value_001 == "'" then
                if template_string_mode then
                    return "'";
                else
                    return "\"'\"";
                end;
            elseif template_string_mode then
                return "\"";
            else
                return "'\"'";
            end;
        elseif raw_string_value == "\\" then
            if template_string_mode then
                return "\\\\";
            elseif string_value_001 == "'" then
                return "'\\\\'";
            else
                return "\"\\\\\"";
            end;
        elseif template_string_mode then
            if raw_string_value == "`" then
                return "\\`";
            else
                return raw_string_value;
            end;
        else
            return string_value_001 .. raw_string_value .. string_value_001;
        end;
    elseif #raw_string_value == 0 then
        if not (quote_behavior ~= "double quotes") or quote_behavior == "single char, single quotes" then
            if template_string_mode then
                return "";
            else
                return "\"\"";
            end;
        elseif template_string_mode then
            return "";
        else
            return "''";
        end;
    else
        local string_value_004 = #raw_string_value;
        local string_value_005 = false;
        local string_value_006 = utf8.len(raw_string_value);
        if string_value_006 then
            string_value_005 = true;
            string_value_004 = string_value_006;
        end;
        local string_value_007 = 0;
        local buffer_value_001 = 0;
        local buffer_value_002 = 0;
        local buffer_value_003 = 0;
        local buffer_value_004 = 0;
        local buffer_value_005 = 0;
        local buffer_value_006 = false;
        local buffer_value_007 = buffer.fromstring(raw_string_value);
        if not string_value_005 then
            for index_010 = 0, string_value_004 - 1 do
                local buffer_value_008 = buffer.readu8(buffer_value_007, index_010);
                if buffer_value_006 then
                    if buffer_value_008 == 10 then
                        string_value_007 = string_value_007 + 1;
                    elseif buffer_value_008 == 9 then
                        buffer_value_001 = buffer_value_001 + 1;
                        buffer_value_002 = buffer_value_002 + 1;
                    else
                        local condition_value_004 = true;
                        if buffer_value_008 >= 32 then
                            condition_value_004 = buffer_value_008 > 126;
                        end;
                        if condition_value_004 then
                            buffer_value_004 = buffer_value_004 + 1;
                            if buffer_value_008 == 0 then
                                buffer_value_005 = buffer_value_005 + 1;
                            end;
                            buffer_value_006 = false;
                        else
                            buffer_value_003 = buffer_value_003 + 1;
                            buffer_value_006 = false;
                        end;
                    end;
                elseif buffer_value_008 == 10 then
                    string_value_007 = string_value_007 + 1;
                    buffer_value_006 = true;
                elseif buffer_value_008 == 9 then
                    buffer_value_001 = buffer_value_001 + 1;
                    if buffer_value_006 then
                        buffer_value_002 = buffer_value_002 + 1;
                    end;
                else
                    local condition_value_005 = true;
                    if buffer_value_008 >= 32 then
                        condition_value_005 = buffer_value_008 > 126;
                    end;
                    if condition_value_005 then
                        buffer_value_004 = buffer_value_004 + 1;
                        if buffer_value_008 == 0 then
                            buffer_value_005 = buffer_value_005 + 1;
                        end;
                    else
                        buffer_value_003 = buffer_value_003 + 1;
                    end;
                end;
            end;
        end;
        if buffer_value_004 / string_value_004 > 0.4 then
            local buffer_value_009 = (not (quote_behavior ~= "single char, double quotes") or quote_behavior == "single quotes") and 39 or 34;
            local buffer_value_010 = 0;
            local buffer_value_011 = buffer.create(if template_string_mode then buffer.len(buffer_value_007) * 4 else buffer.len(buffer_value_007) * 4 + 2);
            if not template_string_mode then
                buffer.writeu8(buffer_value_011, 0, buffer_value_009);
                buffer_value_010 = buffer_value_010 + 1;
            end;
            for index_011 = 0, string_value_004 - 1 do
                buffer.writeu32(buffer_value_011, buffer_value_010, HEX_ESCAPE_U32[buffer.readu8(buffer_value_007, index_011)]);
                buffer_value_010 = buffer_value_010 + 4;
            end;
            if not template_string_mode then
                buffer.writeu8(buffer_value_011, buffer_value_010, buffer_value_009);
            end;
            return buffer.tostring(buffer_value_011);
        else
            local buffer_value_012 = (not (quote_behavior ~= "single char, double quotes") or quote_behavior == "single quotes") and "'" or "\"";
            local condition_value_006 = nil;
            local condition_value_007 = true;
            if template_string_mode then
                condition_value_006 = "";
            elseif string_value_007 > 1 then
                condition_value_007 = false;
                condition_value_006 = "[[";
            else
                condition_value_006 = buffer_value_012;
            end;
            local string_value_008 = nil;
            if condition_value_006 == "[[" then
                local string_value_009 = false;
                while true do
                    string_value_008 = string.gsub(condition_value_006, "%[", "]");
                    string_value_009 = string.match(raw_string_value, string_value_008) and true;
                    if string_value_009 then
                        condition_value_006 = "[" .. string.rep("=", #condition_value_006 - 1) .. "[";
                    end;
                    if not string_value_009 then
                        break;
                    end;
                end;
            else
                string_value_008 = condition_value_006;
            end;
            local table_value_009 = {
                condition_value_006
            };
            local local_symbol_001 = "";
            local function append_escaped_string_byte(param_124)
                local local_symbol_002 = false;
                if condition_value_007 then
                    local condition_value_008 = true;
                    if param_124 >= 32 then
                        condition_value_008 = param_124 > 126;
                    end;
                    if condition_value_008 then
                        local_symbol_001 = local_symbol_001 .. escape_byte_or_noop_handler(param_124);
                        local_symbol_002 = true;
                    end;
                end;
                if not local_symbol_002 then
                    if condition_value_006 == buffer_value_012 and param_124 == string.byte(buffer_value_012) then
                        local_symbol_001 = local_symbol_001 .. "\\" .. buffer_value_012;
                    elseif template_string_mode and param_124 == 96 then
                        local_symbol_001 = local_symbol_001 .. "\\`";
                    elseif condition_value_007 and param_124 == 92 then
                        local_symbol_001 = local_symbol_001 .. "\\\\";
                    else
                        return false;
                    end;
                end;
                local_symbol_002 = false;
                return true;
            end;
            local function _()
                if #local_symbol_001 > 18 then
                    table.insert(table_value_009, local_symbol_001);
                    local_symbol_001 = "";
                end;
            end;
            if string_value_005 then
                for _, item_005 in utf8.codes(raw_string_value) do
                    if not (item_005 <= 255) or not append_escaped_string_byte(item_005) then
                        local_symbol_001 = local_symbol_001 .. utf8.char(item_005);
                    end;
                    if #local_symbol_001 > 18 then
                        table.insert(table_value_009, local_symbol_001);
                        local_symbol_001 = "";
                    end;
                end;
            else
                for index_012 = 0, string_value_004 - 1 do
                    local buffer_value_013 = buffer.readu8(buffer_value_007, index_012);
                    if not append_escaped_string_byte(buffer_value_013) then
                        local_symbol_001 = local_symbol_001 .. string.char(buffer_value_013);
                    end;
                    if #local_symbol_001 > 18 then
                        table.insert(table_value_009, local_symbol_001);
                        local_symbol_001 = "";
                    end;
                end;
            end;
            if #local_symbol_001 > 0 then
                table.insert(table_value_009, local_symbol_001);
            end;
            table.insert(table_value_009, string_value_008);
            local array_value_009 = 0;
            for _, item_006 in ipairs(table_value_009) do
                array_value_009 = array_value_009 + #item_006;
            end;
            local buffer_value_014 = buffer.create(array_value_009);
            local buffer_value_015 = 0;
            for _, item_007 in ipairs(table_value_009) do
                buffer.writestring(buffer_value_014, buffer_value_015, item_007);
                buffer_value_015 = buffer_value_015 + #item_007;
            end;
            return buffer.tostring(buffer_value_014);
        end;
    end;
end;
local buffer_value_016 = nil;
local function format_number_literal(param_125, param_126)
    local buffer_value_017 = math.abs(param_125);
    if buffer_value_017 == 3.141592653589793 then
        if param_125 == 3.141592653589793 then
            return "math.pi";
        else
            return "(-math.pi)";
        end;
    elseif buffer_value_017 == 1.5707963267948966 then
        if param_125 == 1.5707963267948966 then
            return "(math.pi/2)";
        else
            return "(-math.pi/2)";
        end;
    elseif buffer_value_017 == 6.283185307179586 then
        if param_125 == 6.283185307179586 then
            return "(math.pi*2)";
        else
            return "(-math.pi*2)";
        end;
    elseif buffer_value_017 == 1e999 then
        if param_125 == 1e999 then
            return "math.huge";
        else
            return "(-math.huge)";
        end;
    elseif buffer_value_017 == 0.016666666666666666 then
        if param_125 == 0.016666666666666666 then
            return "(1/60)";
        else
            return "(-1/60)";
        end;
    elseif param_125 ~= param_125 then
        if buffer_value_016 then
            return "tonumber(\"nan\")";
        else
            return "(0/0)";
        end;
    else
        return (tostring(param_125));
    end;
end;
local table_value_010 = {};
local table_value_011 = {};
for index_013 = 97, 122 do
    local string_value_010 = string.char(index_013);
    table_value_010[string_value_010] = true;
    table_value_010[string.upper(string_value_010)] = true;
    table_value_011[string.byte(string_value_010)] = true;
    table_value_011[string.byte(string.upper(string_value_010))] = true;
end;
table_value_010._ = true;
table_value_011[95] = true;
local array_value_010 = table.clone(table_value_010);
local array_value_011 = table.clone(table_value_011);
for index_014 = 48, 57 do
    array_value_010[string.char(index_014)] = true;
    array_value_011[index_014] = true;
end;
local _ = {
    [" "] = true,
    ["\t"] = true
};
local function is_valid_identifier(param_127)
    if #param_127 == 0 then
        return false;
    elseif not table_value_010[string.sub(param_127, 1, 1)] then
        return false;
    else
        for index_015 = 2, #param_127 do
            if not array_value_010[string.sub(param_127, index_015, index_015)] then
                return false;
            end;
        end;
        if LUAU_RESERVED_KEYWORDS[param_127] then
            return false;
        else
            return true;
        end;
    end;
end;
local function make_safe_identifier(param_128, param_129, param_130)
    if #param_128 == 0 then
        return "";
    else
        local buffer_value_018 = buffer.fromstring(param_128);
        if not param_129 and not table_value_011[buffer.readu8(buffer_value_018, 0)] then
            buffer.writeu8(buffer_value_018, 0, 95);
        end;
        for index_016 = 1, buffer.len(buffer_value_018) - 1 do
            if not array_value_011[buffer.readu8(buffer_value_018, index_016)] then
                buffer.writeu8(buffer_value_018, index_016, 95);
            end;
        end;
        local buffer_value_019 = buffer.tostring(buffer_value_018);
        if not param_130 and LUAU_RESERVED_KEYWORDS[buffer_value_019] then
            return buffer_value_019 .. "_";
        else
            return buffer_value_019;
        end;
    end;
end;
local function format_constant(param_131, param_132, param_133)
    if not param_131 then
        return "<INVALIDCONSTANT>";
    else
        local cached_type = param_131.type;
        if cached_type == 2 then
            return (format_number_literal(param_131.value));
        elseif cached_type == 3 then
            return register_usage_handlers_or_quote_string(param_132 or "double quotes", param_131.value, param_133);
        elseif cached_type == 7 then
            return "Vector3.new(" .. format_number_literal(param_131.value.X, true) .. ", " .. format_number_literal(param_131.value.Y, true) .. ", " .. format_number_literal(param_131.value.Z, true) .. ")";
        elseif cached_type == 4 then
            return "<IMPORT>";
        elseif cached_type == 0 then
            return "nil";
        elseif cached_type == 1 then
            if param_131.value then
                return "true";
            else
                return "false";
            end;
        else
            error((("Unknown const type %*"):format(cached_type)));
            return;
        end;
    end;
end;
local failed_instruction_count = nil;
local function disassemble_bytecode(param_134)
    failed_instruction_count = 0;
    current_instruction_index = 0;
    last_multireturn_register = 0;
    local buffer_value_020 = nil;
    buffer_value_020 = if type(param_134) == "buffer" then param_134 else buffer.fromstring(param_134);
    local buffer_value_021, buffer_value_022, buffer_value_023, buffer_value_024 = deserialize_luau_bytecode(buffer_value_020);
    local buffer_value_025 = clock_ref();
    last_yield_time = buffer_value_025;
    local function _(param_135)
        return string.rep("\t", #param_135 + 1);
    end;
    local table_value_012 = {};
    local string_value_011 = "";
    local string_value_012 = 0;
    local function _()
        string_value_012 = string_value_012 + 1;
        return string_value_012;
    end;
    buffer_value_016 = true;
    local function format_import_path(param_136, param_137)
        if not param_136 then
            string_value_011 = string_value_011 .. "--[[INVALIDPROTO]]";
            table.insert(table_value_012, string_value_011);
            string_value_011 = "";
            return;
        else
            local array_value_012 = param_136 == buffer_value_021;
            local array_value_013 = buffer.create(8);
            local cached_constants = param_136.constants;
            local cached_protos = param_136.protos;
            if not array_value_012 then
                table.insert(table_value_012, param_137 .. "local function " .. param_136.debug_name .. "() -- Line " .. param_136.line_defined .. "\n");
            end;
            local _ = string.rep("\t", #param_137 + 1);
            local string_value_013 = 0;
            local string_value_014 = 0;
            local string_value_015 = 0;
            local cached_code = param_136.code;
            local condition_value_009 = #cached_code;
            local function _()
                local condition_value_010 = cached_code[string_value_014];
                if string_value_014 == condition_value_009 then
                    error("Corrupted aux");
                end;
                string_value_014 = string_value_014 + 1;
                return condition_value_010;
            end;
            local function emit_disassembly_line(param_138, param_139)
                if param_139 then
                    local cached_string_value_001 = string_value_011;
                    local bit_value_001 = " [0x";
                    local bit_value_002 = cached_code[string_value_013];
                    local bit_value_003 = cached_string_value_001 .. bit_value_001 .. (HEX_BYTE[bit32.rshift(bit_value_002, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(bit_value_002, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(bit_value_002, 8), 255)] .. HEX_BYTE[bit32.band(bit_value_002, 255)]) .. "] ";
                    bit_value_003 = (bit_value_003 .. string.rep(" ", #param_137 + 28 - #bit_value_003) .. " ") .. param_138;
                    cached_string_value_001 = string.rep(" ", #param_137 + 62 - #bit_value_003) .. " ; ";
                    bit_value_001 = buffer.create(#bit_value_003 + #cached_string_value_001 + #param_139 + 1);
                    buffer.writestring(bit_value_001, 0, bit_value_003);
                    local buffer_value_026 = #bit_value_003;
                    buffer.writestring(bit_value_001, buffer_value_026, cached_string_value_001);
                    buffer_value_026 = buffer_value_026 + #cached_string_value_001;
                    buffer.writestring(bit_value_001, buffer_value_026, param_139);
                    buffer.writeu8(bit_value_001, buffer_value_026 + #param_139, 10);
                    string_value_011 = buffer.tostring(bit_value_001);
                    return;
                else
                    local cached_string_value_002 = string_value_011;
                    local bit_value_004 = "[0x";
                    local bit_value_005 = cached_code[string_value_013];
                    string_value_011 = cached_string_value_002 .. bit_value_004 .. (HEX_BYTE[bit32.rshift(bit_value_005, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(bit_value_005, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(bit_value_005, 8), 255)] .. HEX_BYTE[bit32.band(bit_value_005, 255)]) .. "] " .. param_138 .. "\n";
                    return;
                end;
            end;
            local function _()
                string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
            end;
            local table_value_013 = {};
            local function _(param_140, param_141)
                local array_value_014 = table_value_013[param_140];
                if array_value_014 then
                    table.insert(array_value_014, string_value_014 - param_141);
                    return;
                else
                    table_value_013[param_140] = {
                        string_value_014 - param_141
                    };
                    return;
                end;
            end;
            local table_value_014 = {
                NOP = function(_, _)
                    emit_disassembly_line("NOP", "-- Do nothing");
                end,
                BREAK = function(_, _)
                    emit_disassembly_line("BREAK", "-- Stop execution for debugger");
                end,
                LOADNIL = function(param_142, _)
                    local bit_value_006 = bit32.band(bit32.rshift(param_142, 8), 255);
                    emit_disassembly_line("LOADNIL " .. bit_value_006, "var" .. bit_value_006 .. " = nil");
                end,
                LOADB = function(param_143, _)
                    local bit_value_007 = bit32.band(bit32.rshift(param_143, 8), 255);
                    local bit_value_008 = bit32.band(bit32.rshift(param_143, 16), 255);
                    local bit_value_009 = bit32.band(bit32.rshift(param_143, 24), 255);
                    if bit_value_009 == 0 then
                        emit_disassembly_line("LOADB " .. bit_value_007 .. ", " .. bit_value_008 .. ", " .. bit_value_009, "var" .. bit_value_007 .. " = " .. (bit_value_008 > 0 and "true" or "false"));
                        return;
                    else
                        local array_value_015 = string_value_014 + bit_value_009;
                        local array_value_016 = table_value_013[array_value_015];
                        if array_value_016 then
                            table.insert(array_value_016, string_value_014 - 1);
                        else
                            table_value_013[array_value_015] = {
                                string_value_014 - 1
                            };
                        end;
                        emit_disassembly_line("LOADB " .. bit_value_007 .. ", " .. bit_value_008 .. ", " .. bit_value_009, "var" .. bit_value_007 .. " = " .. (bit_value_008 > 0 and "true" or "false") .. " -- goto [" .. array_value_015 .. "]");
                        return;
                    end;
                end,
                LOADN = function(param_144, _)
                    local buffer_value_027 = bit32.band(bit32.rshift(param_144, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_144, 16), 65535)));
                    local buffer_value_028 = buffer.readi16(array_value_013, 0);
                    emit_disassembly_line("LOADN " .. buffer_value_027 .. ", " .. buffer_value_028, "var" .. buffer_value_027 .. " = " .. buffer_value_028);
                end,
                LOADK = function(param_145, _)
                    local bit_value_010 = bit32.band(bit32.rshift(param_145, 8), 255);
                    local constant_value_001 = bit32.band(bit32.rshift(param_145, 16), 65535);
                    emit_disassembly_line("LOADK " .. bit_value_010 .. ", " .. constant_value_001, "var" .. bit_value_010 .. " = " .. format_constant(cached_constants[constant_value_001]));
                end,
                MOVE = function(param_146, _)
                    local constant_value_002 = bit32.band(bit32.rshift(param_146, 8), 255);
                    local bit_value_011 = bit32.band(bit32.rshift(param_146, 16), 255);
                    emit_disassembly_line("MOVE " .. constant_value_002 .. ", " .. bit_value_011, "var" .. constant_value_002 .. " = var" .. bit_value_011);
                end,
                GETGLOBAL = function(param_147, _)
                    local bit_value_012 = bit32.band(bit32.rshift(param_147, 8), 255);
                    local bit_value_013 = bit32.band(bit32.rshift(param_147, 24), 255);
                    local bit_value_014 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_001 = bit_value_014;
                    bit_value_014 = cached_constants[cached_bit_value_001];
                    if bit_value_014.type == 3 and is_valid_identifier(bit_value_014.value) and string.sub(bit_value_014.value, 1, 3) ~= "var" then
                        emit_disassembly_line("GETGLOBAL " .. bit_value_012 .. ", " .. bit_value_013 .. " [" .. cached_bit_value_001 .. "]", "var" .. bit_value_012 .. " = " .. bit_value_014.value);
                        return;
                    else
                        emit_disassembly_line("GETGLOBAL " .. bit_value_012 .. ", " .. bit_value_013 .. " [" .. cached_bit_value_001 .. "]", "var" .. bit_value_012 .. " = getfenv()[" .. format_constant(bit_value_014) .. "]");
                        return;
                    end;
                end,
                SETGLOBAL = function(param_148, _)
                    local bit_value_015 = bit32.band(bit32.rshift(param_148, 8), 255);
                    local bit_value_016 = bit32.band(bit32.rshift(param_148, 24), 255);
                    local bit_value_017 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_002 = bit_value_017;
                    bit_value_017 = cached_constants[cached_bit_value_002];
                    if bit_value_017.type == 3 and is_valid_identifier(bit_value_017.value) and string.sub(bit_value_017.value, 1, 3) ~= "var" then
                        emit_disassembly_line("SETGLOBAL " .. bit_value_015 .. ", " .. bit_value_016 .. " [" .. cached_bit_value_002 .. "]", bit_value_017.value .. " = var" .. bit_value_015);
                        return;
                    else
                        emit_disassembly_line("SETGLOBAL " .. bit_value_015 .. ", " .. bit_value_016 .. " [" .. cached_bit_value_002 .. "]", "getfenv()[" .. format_constant(bit_value_017) .. "] = var" .. bit_value_015);
                        return;
                    end;
                end,
                GETUPVAL = function(param_149, _)
                    local bit_value_018 = bit32.band(bit32.rshift(param_149, 8), 255);
                    local bit_value_019 = bit32.band(bit32.rshift(param_149, 16), 255);
                    emit_disassembly_line("GETUPVAL " .. bit_value_018 .. ", " .. bit_value_019, "var" .. bit_value_018 .. " = " .. "up" .. bit_value_019);
                end,
                SETUPVAL = function(param_150, _)
                    local bit_value_020 = bit32.band(bit32.rshift(param_150, 8), 255);
                    local bit_value_021 = bit32.band(bit32.rshift(param_150, 16), 255);
                    emit_disassembly_line("SETUPVAL " .. bit_value_020 .. ", " .. bit_value_021, "up" .. bit_value_021 .. " = var" .. bit_value_020);
                end,
                CLOSEUPVALS = function(param_151, _)
                    local register_value_001 = bit32.band(bit32.rshift(param_151, 8), 255);
                    emit_disassembly_line("CLOSEUPVALS " .. register_value_001, "move_upvalues_to_heap(var" .. register_value_001 .. "->...)");
                end,
                GETIMPORT = function(param_152, _)
                    local bit_value_022 = bit32.band(bit32.rshift(param_152, 8), 255);
                    local bit_value_023 = bit32.band(bit32.rshift(param_152, 16), 65535);
                    local bit_value_024 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_003 = bit_value_024;
                    bit_value_024 = bit32.rrotate(bit32.band(cached_bit_value_003, 3221225472), 30);
                    local constant_value_003 = cached_constants[bit32.rrotate(bit32.band(cached_bit_value_003, 1072693248), 20)];
                    if bit_value_024 == 2 then
                        local constant_value_004 = cached_constants[bit32.rrotate(bit32.band(cached_bit_value_003, 1047552), 10)];
                        local constant_value_005 = nil;
                        constant_value_005 = if constant_value_003.type == 3 and is_valid_identifier(constant_value_003.value) and string.sub(constant_value_003.value, 1, 3) ~= "var" then constant_value_003.value else "getfenv()[" .. format_constant(constant_value_003) .. "]";
                        constant_value_005 = if constant_value_004.type == 3 and is_valid_identifier(constant_value_004.value) and string.sub(constant_value_004.value, 1, 3) ~= "var" then constant_value_005 .. "." .. constant_value_004.value else constant_value_005 .. "[" .. format_constant(constant_value_004) .. "]";
                        emit_disassembly_line("GETIMPORT " .. bit_value_022 .. ", " .. bit_value_023 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_bit_value_003, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 8), 255)] .. HEX_BYTE[bit32.band(cached_bit_value_003, 255)]) .. "]", "var" .. bit_value_022 .. " = " .. constant_value_005);
                        return;
                    elseif bit_value_024 == 3 then
                        local constant_value_006 = cached_constants[bit32.rrotate(bit32.band(cached_bit_value_003, 1047552), 10)];
                        local constant_value_007 = cached_constants[bit32.band(cached_bit_value_003, 1023)];
                        local constant_value_008 = nil;
                        constant_value_008 = if constant_value_003.type == 3 and is_valid_identifier(constant_value_003.value) and string.sub(constant_value_003.value, 1, 3) ~= "var" then constant_value_003.value else "getfenv()[" .. format_constant(constant_value_003) .. "]";
                        constant_value_008 = if constant_value_006.type == 3 and is_valid_identifier(constant_value_006.value) and string.sub(constant_value_006.value, 1, 3) ~= "var" then constant_value_008 .. "." .. constant_value_006.value else constant_value_008 .. "[" .. format_constant(constant_value_006) .. "]";
                        constant_value_008 = if constant_value_007.type == 3 and is_valid_identifier(constant_value_007.value) and string.sub(constant_value_007.value, 1, 3) ~= "var" then constant_value_008 .. "." .. constant_value_007.value else constant_value_008 .. "[" .. format_constant(constant_value_007) .. "]";
                        emit_disassembly_line("GETIMPORT " .. bit_value_022 .. ", " .. bit_value_023 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_bit_value_003, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 8), 255)] .. HEX_BYTE[bit32.band(cached_bit_value_003, 255)]) .. "]", "var" .. bit_value_022 .. " = " .. constant_value_008);
                        return;
                    elseif constant_value_003.type == 3 and is_valid_identifier(constant_value_003.value) and string.sub(constant_value_003.value, 1, 3) ~= "var" then
                        emit_disassembly_line("GETIMPORT " .. bit_value_022 .. ", " .. bit_value_023 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_bit_value_003, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 8), 255)] .. HEX_BYTE[bit32.band(cached_bit_value_003, 255)]) .. "]", "var" .. bit_value_022 .. " = " .. constant_value_003.value);
                        return;
                    else
                        emit_disassembly_line("GETIMPORT " .. bit_value_022 .. ", " .. bit_value_023 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_bit_value_003, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_bit_value_003, 8), 255)] .. HEX_BYTE[bit32.band(cached_bit_value_003, 255)]) .. "]", "var" .. bit_value_022 .. " = getfenv()[" .. format_constant(constant_value_003) .. "]");
                        return;
                    end;
                end,
                GETTABLE = function(param_153, _)
                    local bit_value_025 = bit32.band(bit32.rshift(param_153, 8), 255);
                    local bit_value_026 = bit32.band(bit32.rshift(param_153, 16), 255);
                    local bit_value_027 = bit32.band(bit32.rshift(param_153, 24), 255);
                    emit_disassembly_line("GETTABLE " .. bit_value_025 .. ", " .. bit_value_026 .. ", " .. bit_value_027, "var" .. bit_value_025 .. " = var" .. bit_value_026 .. "[var" .. bit_value_027 .. "]");
                end,
                SETTABLE = function(param_154, _)
                    local bit_value_028 = bit32.band(bit32.rshift(param_154, 8), 255);
                    local bit_value_029 = bit32.band(bit32.rshift(param_154, 16), 255);
                    local bit_value_030 = bit32.band(bit32.rshift(param_154, 24), 255);
                    emit_disassembly_line("SETTABLE " .. bit_value_028 .. ", " .. bit_value_029 .. ", " .. bit_value_030, "var" .. bit_value_029 .. "[var" .. bit_value_030 .. "] = var" .. bit_value_028);
                end,
                GETTABLEKS = function(param_155, _)
                    local bit_value_031 = bit32.band(bit32.rshift(param_155, 8), 255);
                    local bit_value_032 = bit32.band(bit32.rshift(param_155, 16), 255);
                    local bit_value_033 = bit32.band(bit32.rshift(param_155, 24), 255);
                    local bit_value_034 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_004 = bit_value_034;
                    bit_value_034 = cached_constants[cached_bit_value_004];
                    if bit_value_034.type == 3 and is_valid_identifier(bit_value_034.value) then
                        emit_disassembly_line("GETTABLEKS " .. bit_value_031 .. ", " .. bit_value_032 .. ", " .. bit_value_033 .. " [" .. cached_bit_value_004 .. "]", "var" .. bit_value_031 .. " = var" .. bit_value_032 .. "." .. bit_value_034.value);
                        return;
                    else
                        emit_disassembly_line("GETTABLEKS " .. bit_value_031 .. ", " .. bit_value_032 .. ", " .. bit_value_033 .. " [" .. cached_bit_value_004 .. "]", "var" .. bit_value_031 .. " = var" .. bit_value_032 .. "[" .. format_constant(bit_value_034) .. "]");
                        return;
                    end;
                end,
                GETUDATAKS = function(param_155, _)
                    local bit_value_031 = bit32.band(bit32.rshift(param_155, 8), 255);
                    local bit_value_032 = bit32.band(bit32.rshift(param_155, 16), 255);
                    local bit_value_033 = bit32.band(bit32.rshift(param_155, 24), 255);
                    local bit_value_034 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_004 = bit_value_034;
                    bit_value_034 = cached_constants[cached_bit_value_004];
                    if bit_value_034.type == 3 and is_valid_identifier(bit_value_034.value) then
                        emit_disassembly_line("GETUDATAKS " .. bit_value_031 .. ", " .. bit_value_032 .. ", " .. bit_value_033 .. " [" .. cached_bit_value_004 .. "]", "var" .. bit_value_031 .. " = var" .. bit_value_032 .. "." .. bit_value_034.value);
                        return;
                    else
                        emit_disassembly_line("GETUDATAKS " .. bit_value_031 .. ", " .. bit_value_032 .. ", " .. bit_value_033 .. " [" .. cached_bit_value_004 .. "]", "var" .. bit_value_031 .. " = var" .. bit_value_032 .. "[" .. format_constant(bit_value_034) .. "]");
                        return;
                    end;
                end,
                SETTABLEKS = function(param_156, _)
                    local bit_value_035 = bit32.band(bit32.rshift(param_156, 8), 255);
                    local bit_value_036 = bit32.band(bit32.rshift(param_156, 16), 255);
                    local bit_value_037 = bit32.band(bit32.rshift(param_156, 24), 255);
                    local bit_value_038 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_005 = bit_value_038;
                    bit_value_038 = cached_constants[cached_bit_value_005];
                    if bit_value_038.type == 3 and is_valid_identifier(bit_value_038.value) then
                        emit_disassembly_line("SETTABLEKS " .. bit_value_035 .. ", " .. bit_value_036 .. ", " .. bit_value_037 .. " [" .. cached_bit_value_005 .. "]", "var" .. bit_value_036 .. "." .. bit_value_038.value .. " = var" .. bit_value_035);
                        return;
                    else
                        emit_disassembly_line("SETTABLEKS " .. bit_value_035 .. ", " .. bit_value_036 .. ", " .. bit_value_037 .. " [" .. cached_bit_value_005 .. "]", "var" .. bit_value_036 .. "[" .. format_constant(bit_value_038) .. "] = var" .. bit_value_035);
                        return;
                    end;
                end,
                SETUDATAKS = function(param_156, _)
                    local bit_value_035 = bit32.band(bit32.rshift(param_156, 8), 255);
                    local bit_value_036 = bit32.band(bit32.rshift(param_156, 16), 255);
                    local bit_value_037 = bit32.band(bit32.rshift(param_156, 24), 255);
                    local bit_value_038 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_005 = bit_value_038;
                    bit_value_038 = cached_constants[cached_bit_value_005];
                    if bit_value_038.type == 3 and is_valid_identifier(bit_value_038.value) then
                        emit_disassembly_line("SETUDATAKS " .. bit_value_035 .. ", " .. bit_value_036 .. ", " .. bit_value_037 .. " [" .. cached_bit_value_005 .. "]", "var" .. bit_value_036 .. "." .. bit_value_038.value .. " = var" .. bit_value_035);
                        return;
                    else
                        emit_disassembly_line("SETUDATAKS " .. bit_value_035 .. ", " .. bit_value_036 .. ", " .. bit_value_037 .. " [" .. cached_bit_value_005 .. "]", "var" .. bit_value_036 .. "[" .. format_constant(bit_value_038) .. "] = var" .. bit_value_035);
                        return;
                    end;
                end,
                GETTABLEN = function(param_157, _)
                    local bit_value_039 = bit32.band(bit32.rshift(param_157, 8), 255);
                    local bit_value_040 = bit32.band(bit32.rshift(param_157, 16), 255);
                    local bit_value_041 = bit32.band(bit32.rshift(param_157, 24), 255);
                    emit_disassembly_line("GETTABLEN " .. bit_value_039 .. ", " .. bit_value_040 .. ", " .. bit_value_041, "var" .. bit_value_039 .. " = var" .. bit_value_040 .. "[" .. bit_value_041 .. "]");
                end,
                SETTABLEN = function(param_158, _)
                    local bit_value_042 = bit32.band(bit32.rshift(param_158, 8), 255);
                    local bit_value_043 = bit32.band(bit32.rshift(param_158, 16), 255);
                    local bit_value_044 = bit32.band(bit32.rshift(param_158, 24), 255);
                    emit_disassembly_line("SETTABLEN " .. bit_value_042 .. ", " .. bit_value_043 .. ", " .. bit_value_044, "var" .. bit_value_043 .. "[" .. bit_value_044 .. "] = var" .. bit_value_042);
                end,
                NAMECALL = function(param_159, _)
                    local bit_value_045 = bit32.band(bit32.rshift(param_159, 8), 255);
                    local bit_value_046 = bit32.band(bit32.rshift(param_159, 16), 255);
                    local bit_value_047 = bit32.band(bit32.rshift(param_159, 24), 255);
                    local bit_value_048 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_006 = bit_value_048;
                    bit_value_048 = cached_constants[cached_bit_value_006];
                    if bit_value_048.type == 3 and is_valid_identifier(bit_value_048.value) then
                        emit_disassembly_line("NAMECALL " .. bit_value_045 .. ", " .. bit_value_046 .. ", " .. bit_value_047 .. " [" .. cached_bit_value_006 .. "]", "var" .. bit_value_045 + 1 .. " = var" .. bit_value_046 .. "; var" .. bit_value_045 .. " = var" .. bit_value_046 .. "." .. bit_value_048.value .. " -- Invokes __namecall");
                        return;
                    else
                        emit_disassembly_line("NAMECALL " .. bit_value_045 .. ", " .. bit_value_046 .. ", " .. bit_value_047 .. " [" .. cached_bit_value_006 .. "]", "var" .. bit_value_045 + 1 .. " = var" .. bit_value_046 .. "; var" .. bit_value_045 .. " = var" .. bit_value_046 .. "[" .. format_constant(bit_value_048) .. "] -- Invokes __namecall");
                        return;
                    end;
                end,
                NAMECALLUDATA = function(param_159, _)
                    local bit_value_045 = bit32.band(bit32.rshift(param_159, 8), 255);
                    local bit_value_046 = bit32.band(bit32.rshift(param_159, 16), 255);
                    local bit_value_047 = bit32.band(bit32.rshift(param_159, 24), 255);
                    local bit_value_048 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_006 = bit_value_048;
                    bit_value_048 = cached_constants[cached_bit_value_006];
                    if bit_value_048.type == 3 and is_valid_identifier(bit_value_048.value) then
                        emit_disassembly_line("NAMECALLUDATA " .. bit_value_045 .. ", " .. bit_value_046 .. ", " .. bit_value_047 .. " [" .. cached_bit_value_006 .. "]", "var" .. bit_value_045 + 1 .. " = var" .. bit_value_046 .. "; var" .. bit_value_045 .. " = var" .. bit_value_046 .. "." .. bit_value_048.value .. " -- Invokes __namecall");
                        return;
                    else
                        emit_disassembly_line("NAMECALLUDATA " .. bit_value_045 .. ", " .. bit_value_046 .. ", " .. bit_value_047 .. " [" .. cached_bit_value_006 .. "]", "var" .. bit_value_045 + 1 .. " = var" .. bit_value_046 .. "; var" .. bit_value_045 .. " = var" .. bit_value_046 .. "[" .. format_constant(bit_value_048) .. "] -- Invokes __namecall");
                        return;
                    end;
                end,
                CALL = function(param_160, _)
                    local bit_value_049 = bit32.band(bit32.rshift(param_160, 8), 255);
                    local bit_value_050 = bit32.band(bit32.rshift(param_160, 16), 255);
                    local bit_value_051 = bit32.band(bit32.rshift(param_160, 24), 255);
                    local bit_value_052 = bit_value_050 - 1;
                    local bit_value_053 = bit_value_051 - 1;
                    local condition_value_011 = nil;
                    if bit_value_052 == -1 then
                        condition_value_011 = {
                            "var" .. bit_value_049 + 1 .. "->(top)"
                        };
                    else
                        condition_value_011 = {};
                        for index_017 = bit_value_049 + 1, bit_value_049 + bit_value_052 do
                            table.insert(condition_value_011, "var" .. index_017);
                        end;
                    end;
                    if bit_value_053 == 0 then
                        emit_disassembly_line("CALL " .. bit_value_049 .. ", " .. bit_value_050 .. ", " .. bit_value_051, "var" .. bit_value_049 .. "(" .. table.concat(condition_value_011, ", ") .. ")");
                        return;
                    else
                        local condition_value_012 = nil;
                        if bit_value_053 == -1 then
                            condition_value_012 = {
                                "var" .. bit_value_049 .. "->(top)"
                            };
                        else
                            condition_value_012 = {};
                            for index_018 = bit_value_049, bit_value_049 + bit_value_053 - 1 do
                                table.insert(condition_value_012, "var" .. index_018);
                            end;
                        end;
                        emit_disassembly_line("CALL " .. bit_value_049 .. ", " .. bit_value_050 .. ", " .. bit_value_051, table.concat(condition_value_012, ", ") .. " = var" .. bit_value_049 .. "(" .. table.concat(condition_value_011, ", ") .. ")");
                        return;
                    end;
                end,
                RETURN = function(param_161, _)
                    local bit_value_054 = bit32.band(bit32.rshift(param_161, 8), 255);
                    local bit_value_055 = bit32.band(bit32.rshift(param_161, 16), 255);
                    local bit_value_056 = bit_value_055 - 1;
                    if bit_value_056 == 0 then
                        emit_disassembly_line("RETURN " .. bit_value_054 .. ", " .. bit_value_055, "return");
                        return;
                    elseif bit_value_056 == -1 then
                        emit_disassembly_line("RETURN " .. bit_value_054 .. ", " .. bit_value_055, "return var" .. bit_value_054 .. "->(top)");
                        return;
                    else
                        emit_disassembly_line("RETURN " .. bit_value_054 .. ", " .. bit_value_055, "return var" .. bit_value_054 .. "->var" .. bit_value_054 + bit_value_056 - 1);
                        return;
                    end;
                end,
                JUMP = function(param_162, _)
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_162, 16), 65535)));
                    local buffer_value_029 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_017 = string_value_014 + buffer_value_029;
                    local array_value_018 = table_value_013[array_value_017];
                    if array_value_018 then
                        table.insert(array_value_018, string_value_014 - 1);
                    else
                        table_value_013[array_value_017] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("JUMP " .. buffer_value_029, "-- goto [" .. array_value_017 .. "]");
                end,
                JUMPBACK = function(param_163, _)
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_163, 16), 65535)));
                    local buffer_value_030 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_019 = string_value_014 + buffer_value_030;
                    local array_value_020 = table_value_013[array_value_019];
                    if array_value_020 then
                        table.insert(array_value_020, string_value_014 - 1);
                    else
                        table_value_013[array_value_019] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("JUMPBACK " .. buffer_value_030, "-- goto [" .. array_value_019 .. "] (likely while/repeat loop)");
                end,
                JUMPIF = function(param_164, _)
                    local buffer_value_031 = bit32.band(bit32.rshift(param_164, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_164, 16), 65535)));
                    local buffer_value_032 = buffer.readi16(array_value_013, 0);
                    local array_value_021 = string_value_014 + buffer_value_032;
                    local array_value_022 = table_value_013[array_value_021];
                    if array_value_022 then
                        table.insert(array_value_022, string_value_014 - 1);
                    else
                        table_value_013[array_value_021] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("JUMPIF " .. buffer_value_031 .. ", " .. buffer_value_032, "if var" .. buffer_value_031 .. " then goto [" .. array_value_021 .. "] end");
                end,
                JUMPIFNOT = function(param_165, _)
                    local buffer_value_033 = bit32.band(bit32.rshift(param_165, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_165, 16), 65535)));
                    local buffer_value_034 = buffer.readi16(array_value_013, 0);
                    local array_value_023 = string_value_014 + buffer_value_034;
                    local array_value_024 = table_value_013[array_value_023];
                    if array_value_024 then
                        table.insert(array_value_024, string_value_014 - 1);
                    else
                        table_value_013[array_value_023] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("JUMPIFNOT " .. buffer_value_033 .. ", " .. buffer_value_034, "if not var" .. buffer_value_033 .. " then goto [" .. array_value_023 .. "] end");
                end,
                JUMPIFEQ = function(param_166, _)
                    local buffer_value_035 = bit32.band(bit32.rshift(param_166, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_166, 16), 65535)));
                    local buffer_value_036 = buffer.readi16(array_value_013, 0);
                    local buffer_value_037 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_001 = buffer_value_037;
                    buffer_value_037 = string_value_014 - 1 + buffer_value_036;
                    local array_value_025 = table_value_013[buffer_value_037];
                    if array_value_025 then
                        table.insert(array_value_025, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_037] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFEQ " .. buffer_value_035 .. ", " .. buffer_value_036 .. " [" .. cached_buffer_value_001 .. "]", "if var" .. buffer_value_035 .. " == var" .. cached_buffer_value_001 .. " then goto [" .. buffer_value_037 .. "] end");
                end,
                JUMPIFLE = function(param_167, _)
                    local buffer_value_038 = bit32.band(bit32.rshift(param_167, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_167, 16), 65535)));
                    local buffer_value_039 = buffer.readi16(array_value_013, 0);
                    local buffer_value_040 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_002 = buffer_value_040;
                    buffer_value_040 = string_value_014 - 1 + buffer_value_039;
                    local array_value_026 = table_value_013[buffer_value_040];
                    if array_value_026 then
                        table.insert(array_value_026, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_040] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFLE " .. buffer_value_038 .. ", " .. buffer_value_039 .. " [" .. cached_buffer_value_002 .. "]", "if var" .. buffer_value_038 .. " <= var" .. cached_buffer_value_002 .. " then goto [" .. buffer_value_040 .. "] end");
                end,
                JUMPIFLT = function(param_168, _)
                    local buffer_value_041 = bit32.band(bit32.rshift(param_168, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_168, 16), 65535)));
                    local buffer_value_042 = buffer.readi16(array_value_013, 0);
                    local buffer_value_043 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_003 = buffer_value_043;
                    buffer_value_043 = string_value_014 - 1 + buffer_value_042;
                    local array_value_027 = table_value_013[buffer_value_043];
                    if array_value_027 then
                        table.insert(array_value_027, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_043] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFLT " .. buffer_value_041 .. ", " .. buffer_value_042 .. " [" .. cached_buffer_value_003 .. "]", "if var" .. buffer_value_041 .. " < var" .. cached_buffer_value_003 .. " then goto [" .. buffer_value_043 .. "] end");
                end,
                JUMPIFNOTEQ = function(param_169, _)
                    local buffer_value_044 = bit32.band(bit32.rshift(param_169, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_169, 16), 65535)));
                    local buffer_value_045 = buffer.readi16(array_value_013, 0);
                    local buffer_value_046 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_004 = buffer_value_046;
                    buffer_value_046 = string_value_014 - 1 + buffer_value_045;
                    local array_value_028 = table_value_013[buffer_value_046];
                    if array_value_028 then
                        table.insert(array_value_028, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_046] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFNOTEQ " .. buffer_value_044 .. ", " .. buffer_value_045 .. " [" .. cached_buffer_value_004 .. "]", "if var" .. buffer_value_044 .. " ~= var" .. cached_buffer_value_004 .. " then goto [" .. buffer_value_046 .. "] end");
                end,
                JUMPIFNOTLE = function(param_170, _)
                    local buffer_value_047 = bit32.band(bit32.rshift(param_170, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_170, 16), 65535)));
                    local buffer_value_048 = buffer.readi16(array_value_013, 0);
                    local buffer_value_049 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_005 = buffer_value_049;
                    buffer_value_049 = string_value_014 - 1 + buffer_value_048;
                    local array_value_029 = table_value_013[buffer_value_049];
                    if array_value_029 then
                        table.insert(array_value_029, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_049] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFNOTLE " .. buffer_value_047 .. ", " .. buffer_value_048 .. " [" .. cached_buffer_value_005 .. "]", "if var" .. buffer_value_047 .. " > var" .. cached_buffer_value_005 .. " then goto [" .. buffer_value_049 .. "] end");
                end,
                JUMPIFNOTLT = function(param_171, _)
                    local buffer_value_050 = bit32.band(bit32.rshift(param_171, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_171, 16), 65535)));
                    local buffer_value_051 = buffer.readi16(array_value_013, 0);
                    local buffer_value_052 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_006 = buffer_value_052;
                    buffer_value_052 = string_value_014 - 1 + buffer_value_051;
                    local array_value_030 = table_value_013[buffer_value_052];
                    if array_value_030 then
                        table.insert(array_value_030, string_value_014 - 2);
                    else
                        table_value_013[buffer_value_052] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPIFNOTLT " .. buffer_value_050 .. ", " .. buffer_value_051 .. " [" .. cached_buffer_value_006 .. "]", "if var" .. buffer_value_050 .. " >= var" .. cached_buffer_value_006 .. " then goto [" .. buffer_value_052 .. "] end");
                end,
                ADD = function(param_172, _)
                    local bit_value_057 = bit32.band(bit32.rshift(param_172, 8), 255);
                    local bit_value_058 = bit32.band(bit32.rshift(param_172, 16), 255);
                    local bit_value_059 = bit32.band(bit32.rshift(param_172, 24), 255);
                    if bit_value_057 == bit_value_058 then
                        emit_disassembly_line("ADD " .. bit_value_057 .. ", " .. bit_value_058 .. ", " .. bit_value_059, "var" .. bit_value_057 .. " += var" .. bit_value_059);
                        return;
                    elseif bit_value_057 == bit_value_059 then
                        emit_disassembly_line("ADD " .. bit_value_057 .. ", " .. bit_value_058 .. ", " .. bit_value_059, "var" .. bit_value_057 .. " += var" .. bit_value_058);
                        return;
                    else
                        emit_disassembly_line("ADD " .. bit_value_057 .. ", " .. bit_value_058 .. ", " .. bit_value_059, "var" .. bit_value_057 .. " = var" .. bit_value_058 .. " + var" .. bit_value_059);
                        return;
                    end;
                end,
                SUB = function(param_173, _)
                    local bit_value_060 = bit32.band(bit32.rshift(param_173, 8), 255);
                    local bit_value_061 = bit32.band(bit32.rshift(param_173, 16), 255);
                    local bit_value_062 = bit32.band(bit32.rshift(param_173, 24), 255);
                    if bit_value_060 == bit_value_061 then
                        emit_disassembly_line("SUB " .. bit_value_060 .. ", " .. bit_value_061 .. ", " .. bit_value_062, "var" .. bit_value_060 .. " -= var" .. bit_value_062);
                        return;
                    else
                        emit_disassembly_line("SUB " .. bit_value_060 .. ", " .. bit_value_061 .. ", " .. bit_value_062, "var" .. bit_value_060 .. " = var" .. bit_value_061 .. " - var" .. bit_value_062);
                        return;
                    end;
                end,
                MUL = function(param_174, _)
                    local bit_value_063 = bit32.band(bit32.rshift(param_174, 8), 255);
                    local bit_value_064 = bit32.band(bit32.rshift(param_174, 16), 255);
                    local bit_value_065 = bit32.band(bit32.rshift(param_174, 24), 255);
                    if bit_value_063 == bit_value_064 then
                        emit_disassembly_line("MUL " .. bit_value_063 .. ", " .. bit_value_064 .. ", " .. bit_value_065, "var" .. bit_value_063 .. " *= var" .. bit_value_065);
                        return;
                    elseif bit_value_063 == bit_value_065 then
                        emit_disassembly_line("MUL " .. bit_value_063 .. ", " .. bit_value_064 .. ", " .. bit_value_065, "var" .. bit_value_063 .. " *= var" .. bit_value_064);
                        return;
                    else
                        emit_disassembly_line("MUL " .. bit_value_063 .. ", " .. bit_value_064 .. ", " .. bit_value_065, "var" .. bit_value_063 .. " = var" .. bit_value_064 .. " * var" .. bit_value_065);
                        return;
                    end;
                end,
                DIV = function(param_175, _)
                    local bit_value_066 = bit32.band(bit32.rshift(param_175, 8), 255);
                    local bit_value_067 = bit32.band(bit32.rshift(param_175, 16), 255);
                    local bit_value_068 = bit32.band(bit32.rshift(param_175, 24), 255);
                    if bit_value_066 == bit_value_067 then
                        emit_disassembly_line("DIV " .. bit_value_066 .. ", " .. bit_value_067 .. ", " .. bit_value_068, "var" .. bit_value_066 .. " /= var" .. bit_value_068);
                        return;
                    else
                        emit_disassembly_line("DIV " .. bit_value_066 .. ", " .. bit_value_067 .. ", " .. bit_value_068, "var" .. bit_value_066 .. " = var" .. bit_value_067 .. " / var" .. bit_value_068);
                        return;
                    end;
                end,
                MOD = function(param_176, _)
                    local bit_value_069 = bit32.band(bit32.rshift(param_176, 8), 255);
                    local bit_value_070 = bit32.band(bit32.rshift(param_176, 16), 255);
                    local bit_value_071 = bit32.band(bit32.rshift(param_176, 24), 255);
                    if bit_value_069 == bit_value_070 then
                        emit_disassembly_line("MOD " .. bit_value_069 .. ", " .. bit_value_070 .. ", " .. bit_value_071, "var" .. bit_value_069 .. " %= var" .. bit_value_071);
                        return;
                    else
                        emit_disassembly_line("MOD " .. bit_value_069 .. ", " .. bit_value_070 .. ", " .. bit_value_071, "var" .. bit_value_069 .. " = var" .. bit_value_070 .. " % var" .. bit_value_071);
                        return;
                    end;
                end,
                POW = function(param_177, _)
                    local bit_value_072 = bit32.band(bit32.rshift(param_177, 8), 255);
                    local bit_value_073 = bit32.band(bit32.rshift(param_177, 16), 255);
                    local bit_value_074 = bit32.band(bit32.rshift(param_177, 24), 255);
                    if bit_value_072 == bit_value_073 then
                        emit_disassembly_line("POW " .. bit_value_072 .. ", " .. bit_value_073 .. ", " .. bit_value_074, "var" .. bit_value_072 .. " ^= var" .. bit_value_074);
                        return;
                    else
                        emit_disassembly_line("POW " .. bit_value_072 .. ", " .. bit_value_073 .. ", " .. bit_value_074, "var" .. bit_value_072 .. " = var" .. bit_value_073 .. " ^ var" .. bit_value_074);
                        return;
                    end;
                end,
                ADDK = function(param_178, _)
                    local bit_value_075 = bit32.band(bit32.rshift(param_178, 8), 255);
                    local constant_value_009 = bit32.band(bit32.rshift(param_178, 16), 255);
                    local constant_value_010 = bit32.band(bit32.rshift(param_178, 24), 255);
                    local constant_value_011 = cached_constants[constant_value_010];
                    if bit_value_075 == constant_value_009 then
                        emit_disassembly_line("ADDK " .. bit_value_075 .. ", " .. constant_value_009 .. ", " .. constant_value_010, "var" .. bit_value_075 .. " += " .. format_constant(constant_value_011));
                        return;
                    else
                        emit_disassembly_line("ADDK " .. bit_value_075 .. ", " .. constant_value_009 .. ", " .. constant_value_010, "var" .. bit_value_075 .. " = var" .. constant_value_009 .. " + " .. format_constant(constant_value_011));
                        return;
                    end;
                end,
                SUBK = function(param_179, _)
                    local bit_value_076 = bit32.band(bit32.rshift(param_179, 8), 255);
                    local constant_value_012 = bit32.band(bit32.rshift(param_179, 16), 255);
                    local constant_value_013 = bit32.band(bit32.rshift(param_179, 24), 255);
                    local constant_value_014 = cached_constants[constant_value_013];
                    if bit_value_076 == constant_value_012 then
                        emit_disassembly_line("SUBK " .. bit_value_076 .. ", " .. constant_value_012 .. ", " .. constant_value_013, "var" .. bit_value_076 .. " -= " .. format_constant(constant_value_014));
                        return;
                    else
                        emit_disassembly_line("SUBK " .. bit_value_076 .. ", " .. constant_value_012 .. ", " .. constant_value_013, "var" .. bit_value_076 .. " = var" .. constant_value_012 .. " - " .. format_constant(constant_value_014));
                        return;
                    end;
                end,
                MULK = function(param_180, _)
                    local bit_value_077 = bit32.band(bit32.rshift(param_180, 8), 255);
                    local constant_value_015 = bit32.band(bit32.rshift(param_180, 16), 255);
                    local constant_value_016 = bit32.band(bit32.rshift(param_180, 24), 255);
                    local constant_value_017 = cached_constants[constant_value_016];
                    if bit_value_077 == constant_value_015 then
                        emit_disassembly_line("MULK " .. bit_value_077 .. ", " .. constant_value_015 .. ", " .. constant_value_016, "var" .. bit_value_077 .. " *= " .. format_constant(constant_value_017));
                        return;
                    else
                        emit_disassembly_line("MULK " .. bit_value_077 .. ", " .. constant_value_015 .. ", " .. constant_value_016, "var" .. bit_value_077 .. " = var" .. constant_value_015 .. " * " .. format_constant(constant_value_017));
                        return;
                    end;
                end,
                DIVK = function(param_181, _)
                    local bit_value_078 = bit32.band(bit32.rshift(param_181, 8), 255);
                    local constant_value_018 = bit32.band(bit32.rshift(param_181, 16), 255);
                    local constant_value_019 = bit32.band(bit32.rshift(param_181, 24), 255);
                    local constant_value_020 = cached_constants[constant_value_019];
                    if bit_value_078 == constant_value_018 then
                        emit_disassembly_line("DIVK " .. bit_value_078 .. ", " .. constant_value_018 .. ", " .. constant_value_019, "var" .. bit_value_078 .. " /= " .. format_constant(constant_value_020));
                        return;
                    else
                        emit_disassembly_line("DIVK " .. bit_value_078 .. ", " .. constant_value_018 .. ", " .. constant_value_019, "var" .. bit_value_078 .. " = var" .. constant_value_018 .. " / " .. format_constant(constant_value_020));
                        return;
                    end;
                end,
                MODK = function(param_182, _)
                    local bit_value_079 = bit32.band(bit32.rshift(param_182, 8), 255);
                    local constant_value_021 = bit32.band(bit32.rshift(param_182, 16), 255);
                    local constant_value_022 = bit32.band(bit32.rshift(param_182, 24), 255);
                    local constant_value_023 = cached_constants[constant_value_022];
                    if bit_value_079 == constant_value_021 then
                        emit_disassembly_line("MODK " .. bit_value_079 .. ", " .. constant_value_021 .. ", " .. constant_value_022, "var" .. bit_value_079 .. " %= " .. format_constant(constant_value_023));
                        return;
                    else
                        emit_disassembly_line("MODK " .. bit_value_079 .. ", " .. constant_value_021 .. ", " .. constant_value_022, "var" .. bit_value_079 .. " = var" .. constant_value_021 .. " % " .. format_constant(constant_value_023));
                        return;
                    end;
                end,
                POWK = function(param_183, _)
                    local bit_value_080 = bit32.band(bit32.rshift(param_183, 8), 255);
                    local constant_value_024 = bit32.band(bit32.rshift(param_183, 16), 255);
                    local constant_value_025 = bit32.band(bit32.rshift(param_183, 24), 255);
                    local constant_value_026 = cached_constants[constant_value_025];
                    if bit_value_080 == constant_value_024 then
                        emit_disassembly_line("POWK " .. bit_value_080 .. ", " .. constant_value_024 .. ", " .. constant_value_025, "var" .. bit_value_080 .. " ^= " .. format_constant(constant_value_026));
                        return;
                    else
                        emit_disassembly_line("POWK " .. bit_value_080 .. ", " .. constant_value_024 .. ", " .. constant_value_025, "var" .. bit_value_080 .. " = var" .. constant_value_024 .. " ^ " .. format_constant(constant_value_026));
                        return;
                    end;
                end,
                AND = function(param_184, _)
                    local bit_value_081 = bit32.band(bit32.rshift(param_184, 8), 255);
                    local bit_value_082 = bit32.band(bit32.rshift(param_184, 16), 255);
                    local bit_value_083 = bit32.band(bit32.rshift(param_184, 24), 255);
                    emit_disassembly_line("AND " .. bit_value_081 .. ", " .. bit_value_082 .. ", " .. bit_value_083, "var" .. bit_value_081 .. " = var" .. bit_value_082 .. " and var" .. bit_value_083);
                end,
                OR = function(param_185, _)
                    local bit_value_084 = bit32.band(bit32.rshift(param_185, 8), 255);
                    local bit_value_085 = bit32.band(bit32.rshift(param_185, 16), 255);
                    local bit_value_086 = bit32.band(bit32.rshift(param_185, 24), 255);
                    emit_disassembly_line("OR " .. bit_value_084 .. ", " .. bit_value_085 .. ", " .. bit_value_086, "var" .. bit_value_084 .. " = var" .. bit_value_085 .. " or var" .. bit_value_086);
                end,
                ANDK = function(param_186, _)
                    local bit_value_087 = bit32.band(bit32.rshift(param_186, 8), 255);
                    local constant_value_027 = bit32.band(bit32.rshift(param_186, 16), 255);
                    local constant_value_028 = bit32.band(bit32.rshift(param_186, 24), 255);
                    local constant_value_029 = cached_constants[constant_value_028];
                    emit_disassembly_line("ANDK " .. bit_value_087 .. ", " .. constant_value_027 .. ", " .. constant_value_028, "var" .. bit_value_087 .. " = var" .. constant_value_027 .. " and " .. format_constant(constant_value_029));
                end,
                ORK = function(param_187, _)
                    local bit_value_088 = bit32.band(bit32.rshift(param_187, 8), 255);
                    local constant_value_030 = bit32.band(bit32.rshift(param_187, 16), 255);
                    local constant_value_031 = bit32.band(bit32.rshift(param_187, 24), 255);
                    local constant_value_032 = cached_constants[constant_value_031];
                    emit_disassembly_line("ORK " .. bit_value_088 .. ", " .. constant_value_030 .. ", " .. constant_value_031, "var" .. bit_value_088 .. " = var" .. constant_value_030 .. " or " .. format_constant(constant_value_032));
                end,
                CONCAT = function(param_188, _)
                    local bit_value_089 = bit32.band(bit32.rshift(param_188, 8), 255);
                    local bit_value_090 = bit32.band(bit32.rshift(param_188, 16), 255);
                    local array_value_031 = bit32.band(bit32.rshift(param_188, 24), 255);
                    local table_value_015 = {};
                    for index_019 = bit_value_090, array_value_031 do
                        table.insert(table_value_015, "var" .. index_019);
                    end;
                    if bit_value_089 == bit_value_090 and bit_value_090 <= array_value_031 then
                        table.remove(table_value_015, 1);
                        emit_disassembly_line("CONCAT " .. bit_value_089 .. ", " .. bit_value_090 .. ", " .. array_value_031, "var" .. bit_value_089 .. " ..= " .. table.concat(table_value_015, ".."));
                        return;
                    else
                        emit_disassembly_line("CONCAT " .. bit_value_089 .. ", " .. bit_value_090 .. ", " .. array_value_031, "var" .. bit_value_089 .. " = " .. table.concat(table_value_015, ".."));
                        return;
                    end;
                end,
                NOT = function(param_189, _)
                    local bit_value_091 = bit32.band(bit32.rshift(param_189, 8), 255);
                    local bit_value_092 = bit32.band(bit32.rshift(param_189, 16), 255);
                    emit_disassembly_line("NOT " .. bit_value_091 .. ", " .. bit_value_092, "var" .. bit_value_091 .. " = not var" .. bit_value_092);
                end,
                MINUS = function(param_190, _)
                    local bit_value_093 = bit32.band(bit32.rshift(param_190, 8), 255);
                    local bit_value_094 = bit32.band(bit32.rshift(param_190, 16), 255);
                    emit_disassembly_line("MINUS " .. bit_value_093 .. ", " .. bit_value_094, "var" .. bit_value_093 .. " = -var" .. bit_value_094);
                end,
                LENGTH = function(param_191, _)
                    local bit_value_095 = bit32.band(bit32.rshift(param_191, 8), 255);
                    local bit_value_096 = bit32.band(bit32.rshift(param_191, 16), 255);
                    emit_disassembly_line("LENGTH " .. bit_value_095 .. ", " .. bit_value_096, "var" .. bit_value_095 .. " = #var" .. bit_value_096);
                end,
                NEWTABLE = function(param_192, _)
                    local bit_value_097 = bit32.band(bit32.rshift(param_192, 8), 255);
                    local bit_value_098 = bit32.band(bit32.rshift(param_192, 16), 255);
                    local _ = bit_value_098 == 0 and 0 or bit32.lrotate(1, bit_value_098 - 1);
                    local bit_value_099 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_007 = bit_value_099;
                    if cached_bit_value_007 > 0 then
                        emit_disassembly_line("NEWTABLE " .. bit_value_097 .. ", " .. bit_value_098 .. " [" .. cached_bit_value_007 .. "]", "var" .. bit_value_097 .. " = table.create(" .. cached_bit_value_007 .. ")");
                        return;
                    else
                        emit_disassembly_line("NEWTABLE " .. bit_value_097 .. ", " .. bit_value_098 .. " [" .. cached_bit_value_007 .. "]", "var" .. bit_value_097 .. " = {}");
                        return;
                    end;
                end,
                DUPTABLE = function(param_193, _)
                    local bit_value_100 = bit32.band(bit32.rshift(param_193, 8), 255);
                    emit_disassembly_line("DUPTABLE " .. bit_value_100 .. ", " .. bit32.band(bit32.rshift(param_193, 16), 65535), "var" .. bit_value_100 .. " = {}");
                end,
                SETLIST = function(param_194, _)
                    local bit_value_101 = bit32.band(bit32.rshift(param_194, 8), 255);
                    local bit_value_102 = bit32.band(bit32.rshift(param_194, 16), 255);
                    local bit_value_103 = bit32.band(bit32.rshift(param_194, 24), 255);
                    local bit_value_104 = bit_value_103 - 1;
                    local bit_value_105 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_008 = bit_value_105;
                    if bit_value_104 == -1 then
                        emit_disassembly_line("SETLIST " .. bit_value_101 .. ", " .. bit_value_102 .. ", " .. bit_value_103 .. " [" .. cached_bit_value_008 .. "]", "var" .. bit_value_101 .. "[" .. cached_bit_value_008 .. "->(top)] = var" .. bit_value_102 .. "->(top)");
                        return;
                    else
                        emit_disassembly_line("SETLIST " .. bit_value_101 .. ", " .. bit_value_102 .. ", " .. bit_value_103 .. " [" .. cached_bit_value_008 .. "]", "var" .. bit_value_101 .. "[" .. cached_bit_value_008 .. "->" .. cached_bit_value_008 + bit_value_104 - 1 .. "] = var" .. bit_value_102 .. "->var" .. bit_value_102 + bit_value_104 - 1);
                        return;
                    end;
                end,
                FORNPREP = function(param_195, _)
                    local buffer_value_053 = bit32.band(bit32.rshift(param_195, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_195, 16), 65535)));
                    local buffer_value_054 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_032 = string_value_014 + buffer_value_054;
                    local array_value_033 = table_value_013[array_value_032];
                    if array_value_033 then
                        table.insert(array_value_033, string_value_014 - 1);
                    else
                        table_value_013[array_value_032] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FORNPREP " .. buffer_value_053 .. ", " .. buffer_value_054, "for var" .. buffer_value_053 + 2 .. " = var" .. buffer_value_053 + 2 .. ", var" .. buffer_value_053 .. ", var" .. buffer_value_053 + 1 .. " do -- If loop shouldn't start (var" .. buffer_value_053 + 2 .. " > var" .. buffer_value_053 .. ") then goto [" .. array_value_032 .. "]");
                end,
                FORNLOOP = function(param_196, _)
                    local buffer_value_055 = bit32.band(bit32.rshift(param_196, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_196, 16), 65535)));
                    local buffer_value_056 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_034 = string_value_014 + buffer_value_056;
                    local array_value_035 = table_value_013[array_value_034];
                    if array_value_035 then
                        table.insert(array_value_035, string_value_014 - 1);
                    else
                        table_value_013[array_value_034] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FORNLOOP " .. buffer_value_055 .. ", " .. buffer_value_056, "var" .. buffer_value_055 + 2 .. " += var" .. buffer_value_055 + 1 .. "; if var" .. buffer_value_055 + 2 .. " <= var" .. buffer_value_055 .. " then goto [" .. array_value_034 .. "] end");
                end,
                FORGLOOP = function(param_197, _)
                    local buffer_value_057 = bit32.band(bit32.rshift(param_197, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_197, 16), 65535)));
                    local buffer_value_058 = buffer.readi16(scratch_buffer_u64, 0);
                    local buffer_value_059 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_007 = buffer_value_059;
                    buffer_value_059 = bit32.band(cached_buffer_value_007, 255);
                    local array_value_036 = table.create(buffer_value_059);
                    for index_020 = 1, buffer_value_059 do
                        table.insert(array_value_036, "var" .. buffer_value_057 + 2 + index_020);
                    end;
                    local array_value_037 = string_value_014 + buffer_value_058 - 1;
                    local array_value_038 = table_value_013[array_value_037];
                    if array_value_038 then
                        table.insert(array_value_038, string_value_014 - 2);
                    else
                        table_value_013[array_value_037] = {
                            string_value_014 - 2
                        };
                    end;
                    if bit32.band(cached_buffer_value_007, 2147483648) > 0 then
                        emit_disassembly_line("FORGLOOP " .. buffer_value_057 .. ", " .. buffer_value_058 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_007, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_007, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_007, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_007, 255)]) .. "]", table.concat(array_value_036, ", ") .. " = var" .. buffer_value_057 .. "(var" .. buffer_value_057 + 1 .. ", var" .. buffer_value_057 + 2 .. "); if var" .. buffer_value_057 + 3 .. " ~= nil then goto [" .. array_value_037 .. "]");
                        return;
                    else
                        emit_disassembly_line("FORGLOOP " .. buffer_value_057 .. ", " .. buffer_value_058 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_007, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_007, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_007, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_007, 255)]) .. "]", table.concat(array_value_036, ", ") .. " = var" .. buffer_value_057 .. "(var" .. buffer_value_057 + 1 .. ", var" .. buffer_value_057 + 2 .. "); if var" .. buffer_value_057 + 3 .. " ~= nil then goto [" .. array_value_037 .. "]");
                        return;
                    end;
                end,
                FORGPREP = function(param_198, _)
                    local buffer_value_060 = bit32.band(bit32.rshift(param_198, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_198, 16), 65535)));
                    local buffer_value_061 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_039 = string_value_014 + buffer_value_061;
                    local array_value_040 = table_value_013[array_value_039];
                    if array_value_040 then
                        table.insert(array_value_040, string_value_014 - 1);
                    else
                        table_value_013[array_value_039] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FORGPREP " .. buffer_value_060 .. ", " .. buffer_value_061, "for var" .. buffer_value_060 + 3 .. "->... in var" .. buffer_value_060 .. ", var" .. buffer_value_060 + 1 .. ", var" .. buffer_value_060 + 2 .. " do -- If loop shouldn't start then goto [" .. array_value_039 .. "]");
                end,
                FORGPREP_INEXT = function(param_199, _)
                    local buffer_value_062 = bit32.band(bit32.rshift(param_199, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_199, 16), 65535)));
                    local buffer_value_063 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_041 = string_value_014 + buffer_value_063;
                    local array_value_042 = table_value_013[array_value_041];
                    if array_value_042 then
                        table.insert(array_value_042, string_value_014 - 1);
                    else
                        table_value_013[array_value_041] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FORGPREP_INEXT " .. buffer_value_062 .. ", " .. buffer_value_063, "for var" .. buffer_value_062 + 3 .. "->... in var" .. buffer_value_062 .. ", var" .. buffer_value_062 + 1 .. ", var" .. buffer_value_062 + 2 .. " do -- If loop shouldn't start then goto [" .. array_value_041 .. "]");
                end,
                DEP_FORGLOOP_INEXT = function(_, _)
                    emit_disassembly_line("DEP_FORGLOOP_INEXT", "-- Deprecated instruction, send me some bytecode that has this and I'll support it");
                end,
                FORGPREP_NEXT = function(param_200, _)
                    local buffer_value_064 = bit32.band(bit32.rshift(param_200, 8), 255);
                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_200, 16), 65535)));
                    local buffer_value_065 = buffer.readi16(scratch_buffer_u64, 0);
                    local array_value_043 = string_value_014 + buffer_value_065;
                    local array_value_044 = table_value_013[array_value_043];
                    if array_value_044 then
                        table.insert(array_value_044, string_value_014 - 1);
                    else
                        table_value_013[array_value_043] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FORGPREP_NEXT " .. buffer_value_064 .. ", " .. buffer_value_065, "for var" .. buffer_value_064 + 3 .. "->... in var" .. buffer_value_064 .. ", var" .. buffer_value_064 + 1 .. ", var" .. buffer_value_064 + 2 .. " do -- If loop shouldn't start then goto [" .. array_value_043 .. "]");
                end,
                NATIVECALL = function(_, _)
                    emit_disassembly_line("NATIVECALL", "-- Call to native code");
                end,
                GETVARARGS = function(param_201, _)
                    local bit_value_106 = bit32.band(bit32.rshift(param_201, 8), 255);
                    local bit_value_107 = bit32.band(bit32.rshift(param_201, 16), 255);
                    local bit_value_108 = bit_value_107 - 1;
                    if bit_value_108 == 0 then
                        emit_disassembly_line("GETVARARGS " .. bit_value_106 .. ", " .. bit_value_107, "var" .. bit_value_106 .. " = ... -- No variables");
                        return;
                    elseif bit_value_108 == -1 then
                        if bit_value_106 == 1 then
                            emit_disassembly_line("GETVARARGS " .. bit_value_106 .. ", " .. bit_value_107, "var" .. bit_value_106 .. "->(top) = ... -- Load (top) variables");
                            return;
                        else
                            emit_disassembly_line("GETVARARGS " .. bit_value_106 .. ", " .. bit_value_107, "var" .. bit_value_106 .. "->(top) = ... -- Load (top) - " .. bit_value_106 - 1 .. " variables");
                            return;
                        end;
                    else
                        emit_disassembly_line("GETVARARGS " .. bit_value_106 .. ", " .. bit_value_107, "var" .. bit_value_106 .. " = ... -- Load " .. bit_value_108 .. " variable" .. (bit_value_108 == 1 and "" or "s"));
                        return;
                    end;
                end,
                NEWCLOSURE = function(param_202, param_203)
                    local proto_value_001 = bit32.band(bit32.rshift(param_202, 8), 255);
                    local proto_value_002 = bit32.band(bit32.rshift(param_202, 16), 65535);
                    local proto_value_003 = cached_protos[proto_value_002];
                    local _ = string_value_011;
                    local cached_debug_name = proto_value_003.debug_name;
                    if not cached_debug_name then
                        local local_symbol_003 = "func";
                        string_value_012 = string_value_012 + 1;
                        cached_debug_name = local_symbol_003 .. string_value_012;
                    end;
                    proto_value_003.debug_name = cached_debug_name;
                    format_import_path(proto_value_003, param_203);
                    table.insert(table_value_012, string_value_011);
                    string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
                    emit_disassembly_line("NEWCLOSURE " .. proto_value_001 .. ", " .. proto_value_002, "var" .. proto_value_001 .. " = " .. proto_value_003.debug_name);
                    cached_debug_name = 0;
                    while true do
                        local array_value_045 = cached_code[string_value_014];
                        if array_value_045 and opcode_def_by_encoded_byte[bit32.band(array_value_045, 255)].opname == "CAPTURE" then
                            table.insert(table_value_012, string_value_011);
                            string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
                            local bit_value_109 = bit32.band(bit32.rshift(array_value_045, 8), 255);
                            local bit_value_110 = bit32.band(bit32.rshift(array_value_045, 16), 255);
                            if bit_value_109 == 0 then
                                emit_disassembly_line("CAPTURE " .. bit_value_109 .. ", " .. bit_value_110, "up" .. cached_debug_name .. " = var" .. bit_value_110 .. " -- Readable");
                            elseif bit_value_109 == 1 then
                                emit_disassembly_line("CAPTURE " .. bit_value_109 .. ", " .. bit_value_110, "up" .. cached_debug_name .. " = var" .. bit_value_110 .. " -- Readable and writable");
                            elseif bit_value_109 == 2 then
                                emit_disassembly_line("CAPTURE " .. bit_value_109 .. ", " .. bit_value_110, "up" .. cached_debug_name .. " = up" .. bit_value_110);
                            else
                                emit_disassembly_line("CAPTURE " .. bit_value_109 .. ", " .. bit_value_110, "up" .. cached_debug_name .. " = ??? -- Invalid capture type");
                            end;
                            string_value_014 = string_value_014 + 1;
                            cached_debug_name = cached_debug_name + 1;
                        else
                            break;
                        end;
                    end;
                end,
                DUPCLOSURE = function(param_204, param_205)
                    local bit_value_111 = false;
                    local constant_value_033 = bit32.band(bit32.rshift(param_204, 8), 255);
                    local constant_value_034 = bit32.band(bit32.rshift(param_204, 16), 65535);
                    local proto_value_004 = cached_constants[constant_value_034];
                    local proto_value_005 = buffer_value_022[proto_value_004.value] or {
                        debug_name = ("INVALIDPROTO<%*>%*"):format(CONSTANT_TYPE_NAMES[proto_value_004.type] or "NONE", proto_value_004.value),
                        params_count = 0,
                        line_defined = -1,
                        stack_size = 0,
                        type_info = {},
                        upvalues_count = 0,
                        is_vararg = false,
                        protos = {},
                        constants = {},
                        flags = 0,
                        code = {},
                        line_info = {},
                        abs_line_info = {}
                    };
                    local _ = string_value_011;
                    local local_symbol_004, local_symbol_005;
                    if proto_value_005 then
                        local_symbol_005 = proto_value_005.debug_name;
                        bit_value_111 = local_symbol_005;
                    end;
                    if not bit_value_111 then
                        local_symbol_004 = "func";
                        string_value_012 = string_value_012 + 1;
                        local_symbol_005 = local_symbol_004 .. string_value_012;
                    end;
                    bit_value_111 = false;
                    proto_value_005.debug_name = local_symbol_005;
                    format_import_path(proto_value_005, param_205);
                    table.insert(table_value_012, string_value_011);
                    string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
                    emit_disassembly_line("DUPCLOSURE " .. constant_value_033 .. ", " .. constant_value_034, "var" .. constant_value_033 .. " = " .. proto_value_005.debug_name);
                    local_symbol_005 = 0;
                    while true do
                        local_symbol_004 = cached_code[string_value_014];
                        if local_symbol_004 and opcode_def_by_encoded_byte[bit32.band(local_symbol_004, 255)].opname == "CAPTURE" then
                            table.insert(table_value_012, string_value_011);
                            string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
                            local bit_value_112 = bit32.band(bit32.rshift(local_symbol_004, 8), 255);
                            local bit_value_113 = bit32.band(bit32.rshift(local_symbol_004, 16), 255);
                            if bit_value_112 == 0 then
                                emit_disassembly_line("CAPTURE " .. bit_value_112 .. ", " .. bit_value_113, "up" .. local_symbol_005 .. " = var" .. bit_value_113 .. " -- Readable");
                            elseif bit_value_112 == 1 then
                                emit_disassembly_line("CAPTURE " .. bit_value_112 .. ", " .. bit_value_113, "up" .. local_symbol_005 .. " = var" .. bit_value_113 .. " -- Readable and writable");
                            elseif bit_value_112 == 2 then
                                emit_disassembly_line("CAPTURE " .. bit_value_112 .. ", " .. bit_value_113, "up" .. local_symbol_005 .. " = up" .. bit_value_113);
                            else
                                emit_disassembly_line("CAPTURE " .. bit_value_112 .. ", " .. bit_value_113, "up" .. local_symbol_005 .. " = ??? -- Invalid capture type");
                            end;
                            string_value_014 = string_value_014 + 1;
                            local_symbol_005 = local_symbol_005 + 1;
                        else
                            break;
                        end;
                    end;
                end,
                PREPVARARGS = function(param_206, _)
                    local bit_value_114 = bit32.band(bit32.rshift(param_206, 8), 255);
                    local bit_value_115 = bit_value_114 - 1;
                    if bit_value_115 == 0 then
                        emit_disassembly_line("PREPVARARGS " .. bit_value_114, "-- No varargs");
                        return;
                    elseif bit_value_115 == -1 then
                        emit_disassembly_line("PREPVARARGS " .. bit_value_114, "-- Prepare for any number (top) of variables as ...");
                        return;
                    else
                        emit_disassembly_line("PREPVARARGS " .. bit_value_114, "-- Prepare for " .. bit_value_115 .. " variables as ...");
                        return;
                    end;
                end,
                LOADKX = function(param_207, _)
                    local bit_value_116 = bit32.band(bit32.rshift(param_207, 8), 255);
                    local bit_value_117 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_009 = bit_value_117;
                    emit_disassembly_line("LOADKX " .. bit_value_116 .. " [" .. cached_bit_value_009 .. "]", "var" .. bit_value_116 .. " = " .. format_constant(cached_constants[cached_bit_value_009]));
                end,
                JUMPX = function(param_208, _)
                    local constant_value_035 = bit32.arshift(param_208, 8);
                    local array_value_046 = string_value_014 + constant_value_035;
                    local array_value_047 = table_value_013[array_value_046];
                    if array_value_047 then
                        table.insert(array_value_047, string_value_014 - 1);
                    else
                        table_value_013[array_value_046] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("JUMPX " .. constant_value_035, "-- goto [" .. array_value_046 .. "]");
                end,
                COVERAGE = function(param_209, _)
                    emit_disassembly_line("COVERAGE " .. bit32.rshift(param_209, 8), "instruction_hits[" .. string_value_013 .. "] += 1");
                end,
                CAPTURE = function(param_210, _)
                    emit_disassembly_line("CAPTURE " .. bit32.band(bit32.rshift(param_210, 8), 255) .. ", " .. bit32.band(bit32.rshift(param_210, 16), 255), "-- Should not exist here, but equivelant to NOP");
                end,
                SUBRK = function(param_211, _)
                    local bit_value_118 = bit32.band(bit32.rshift(param_211, 8), 255);
                    local constant_value_036 = bit32.band(bit32.rshift(param_211, 16), 255);
                    local constant_value_037 = bit32.band(bit32.rshift(param_211, 24), 255);
                    local constant_value_038 = cached_constants[constant_value_036];
                    emit_disassembly_line("SUBRK " .. bit_value_118 .. ", " .. constant_value_036 .. ", " .. constant_value_037, "var" .. bit_value_118 .. " = " .. format_constant(constant_value_038) .. " - var" .. constant_value_037);
                end,
                DIVRK = function(param_212, _)
                    local bit_value_119 = bit32.band(bit32.rshift(param_212, 8), 255);
                    local constant_value_039 = bit32.band(bit32.rshift(param_212, 16), 255);
                    local constant_value_040 = bit32.band(bit32.rshift(param_212, 24), 255);
                    local constant_value_041 = cached_constants[constant_value_039];
                    emit_disassembly_line("DIVRK " .. bit_value_119 .. ", " .. constant_value_039 .. ", " .. constant_value_040, "var" .. bit_value_119 .. " = " .. format_constant(constant_value_041) .. " / var" .. constant_value_040);
                end,
                FASTCALL = function(param_213, _)
                    local bit_value_120 = bit32.band(bit32.rshift(param_213, 8), 255);
                    local bit_value_121 = bit32.band(bit32.rshift(param_213, 24), 255);
                    local bit_value_122 = FASTCALL_FUNCTION_NAMES[bit_value_120] or "<invalid>";
                    local array_value_048 = string_value_014 + bit_value_121;
                    local array_value_049 = array_value_048 + 1;
                    local array_value_050 = table_value_013[array_value_049];
                    if array_value_050 then
                        table.insert(array_value_050, string_value_014 - 1);
                    else
                        table_value_013[array_value_049] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FASTCALL " .. bit_value_120 .. ", " .. bit_value_121, "... = " .. bit_value_122 .. "(...) -- Uses args and results from call at [" .. array_value_048 .. "]. If successful, goto [" .. array_value_048 + 1 .. "]");
                end,
                FASTCALL1 = function(param_214, _)
                    local bit_value_123 = bit32.band(bit32.rshift(param_214, 8), 255);
                    local bit_value_124 = bit32.band(bit32.rshift(param_214, 16), 255);
                    local bit_value_125 = bit32.band(bit32.rshift(param_214, 24), 255);
                    local bit_value_126 = FASTCALL_FUNCTION_NAMES[bit_value_123] or "<invalid>";
                    local array_value_051 = string_value_014 + bit_value_125;
                    local array_value_052 = array_value_051 + 1;
                    local array_value_053 = table_value_013[array_value_052];
                    if array_value_053 then
                        table.insert(array_value_053, string_value_014 - 1);
                    else
                        table_value_013[array_value_052] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FASTCALL1 " .. bit_value_123 .. ", " .. bit_value_124 .. ", " .. bit_value_125, "... = " .. bit_value_126 .. "(var" .. bit_value_124 .. ") -- Uses results from call at [" .. array_value_051 .. "]. If successful, goto [" .. array_value_051 + 1 .. "]");
                end,
                FASTCALL2 = function(param_215, _)
                    local bit_value_127 = bit32.band(bit32.rshift(param_215, 8), 255);
                    local bit_value_128 = bit32.band(bit32.rshift(param_215, 16), 255);
                    local bit_value_129 = bit32.band(bit32.rshift(param_215, 24), 255);
                    local bit_value_130 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    bit_value_130 = bit32.band(bit_value_130, 255);
                    local bit_value_131 = FASTCALL_FUNCTION_NAMES[bit_value_127] or "<invalid>";
                    local bit_value_132 = string_value_014 + bit_value_129 - 1;
                    local array_value_054 = bit_value_132 + 1;
                    local array_value_055 = table_value_013[array_value_054];
                    if array_value_055 then
                        table.insert(array_value_055, string_value_014 - 1);
                    else
                        table_value_013[array_value_054] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FASTCALL2 " .. bit_value_127 .. ", " .. bit_value_128 .. ", " .. bit_value_129, "... = " .. bit_value_131 .. "(var" .. bit_value_128 .. ", var" .. bit_value_130 .. ") -- Uses results from call at [" .. bit_value_132 .. "]. If successful, goto [" .. bit_value_132 + 1 .. "]");
                end,
                FASTCALL2K = function(param_216, _)
                    local bit_value_133 = bit32.band(bit32.rshift(param_216, 8), 255);
                    local bit_value_134 = bit32.band(bit32.rshift(param_216, 16), 255);
                    local bit_value_135 = bit32.band(bit32.rshift(param_216, 24), 255);
                    local bit_value_136 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_010 = bit_value_136;
                    bit_value_136 = cached_constants[cached_bit_value_010];
                    local constant_value_042 = FASTCALL_FUNCTION_NAMES[bit_value_133] or "<invalid>";
                    local constant_value_043 = string_value_014 + bit_value_135 - 1;
                    local array_value_056 = constant_value_043 + 1;
                    local array_value_057 = table_value_013[array_value_056];
                    if array_value_057 then
                        table.insert(array_value_057, string_value_014 - 1);
                    else
                        table_value_013[array_value_056] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FASTCALL2K " .. bit_value_133 .. ", " .. bit_value_134 .. ", " .. bit_value_135 .. " [" .. cached_bit_value_010 .. "]", "... = " .. constant_value_042 .. "(var" .. bit_value_134 .. ", " .. format_constant(bit_value_136) .. ") -- Uses results from call at [" .. constant_value_043 .. "]. If successful, goto [" .. constant_value_043 + 1 .. "]");
                end,
                FASTCALL3 = function(param_217, _)
                    local bit_value_137 = bit32.band(bit32.rshift(param_217, 8), 255);
                    local bit_value_138 = bit32.band(bit32.rshift(param_217, 16), 255);
                    local bit_value_139 = bit32.band(bit32.rshift(param_217, 24), 255);
                    local bit_value_140 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_bit_value_011 = bit_value_140;
                    bit_value_140 = bit32.band(cached_bit_value_011, 255);
                    local bit_value_141 = bit32.rshift(bit32.band(cached_bit_value_011, 65280), 8);
                    local bit_value_142 = FASTCALL_FUNCTION_NAMES[bit_value_137] or "<invalid>";
                    local local_symbol_006 = string_value_014 + bit_value_139 - 1;
                    local array_value_058 = local_symbol_006 + 1;
                    local array_value_059 = table_value_013[array_value_058];
                    if array_value_059 then
                        table.insert(array_value_059, string_value_014 - 1);
                    else
                        table_value_013[array_value_058] = {
                            string_value_014 - 1
                        };
                    end;
                    emit_disassembly_line("FASTCALL3 " .. bit_value_137 .. ", " .. bit_value_138 .. ", " .. bit_value_139, "... = " .. bit_value_142 .. "(var" .. bit_value_138 .. ", var" .. bit_value_140 .. ", var" .. bit_value_141 .. ") -- Uses results from call at [" .. local_symbol_006 .. "]. If successful, goto [" .. local_symbol_006 + 1 .. "]");
                end,
                JUMPXEQKNIL = function(param_218, _)
                    local buffer_value_066 = bit32.band(bit32.rshift(param_218, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_218, 16), 65535)));
                    local buffer_value_067 = buffer.readi16(array_value_013, 0);
                    local buffer_value_068 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_008 = buffer_value_068;
                    buffer_value_068 = false;
                    if bit32.band(cached_buffer_value_008, 2147483648) > 0 then
                        buffer_value_068 = true;
                    end;
                    local array_value_060 = string_value_014 - 1 + buffer_value_067;
                    local array_value_061 = table_value_013[array_value_060];
                    if array_value_061 then
                        table.insert(array_value_061, string_value_014 - 2);
                    else
                        table_value_013[array_value_060] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPXEQKNIL " .. buffer_value_066 .. ", " .. buffer_value_067 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_008, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_008, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_008, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_008, 255)]) .. "]", "if var" .. buffer_value_066 .. " " .. (buffer_value_068 and "~" or "=") .. "= nil then goto [" .. array_value_060 .. "] end");
                end,
                JUMPXEQKB = function(param_219, _)
                    local buffer_value_069 = bit32.band(bit32.rshift(param_219, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_219, 16), 65535)));
                    local buffer_value_070 = buffer.readi16(array_value_013, 0);
                    local buffer_value_071 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_009 = buffer_value_071;
                    buffer_value_071 = false;
                    if bit32.band(cached_buffer_value_009, 2147483648) > 0 then
                        buffer_value_071 = true;
                    end;
                    local array_value_062 = string_value_014 - 1 + buffer_value_070;
                    local array_value_063 = table_value_013[array_value_062];
                    if array_value_063 then
                        table.insert(array_value_063, string_value_014 - 2);
                    else
                        table_value_013[array_value_062] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPXEQKB " .. buffer_value_069 .. ", " .. buffer_value_070 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_009, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_009, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_009, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_009, 255)]) .. "]", "if var" .. buffer_value_069 .. " " .. (buffer_value_071 and "~" or "=") .. "= " .. (bit32.band(cached_buffer_value_009, 1) == 0 and "false" or "true") .. " then goto [" .. array_value_062 .. "] end");
                end,
                JUMPXEQKN = function(param_220, _)
                    local buffer_value_072 = bit32.band(bit32.rshift(param_220, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_220, 16), 65535)));
                    local buffer_value_073 = buffer.readi16(array_value_013, 0);
                    local buffer_value_074 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_010 = buffer_value_074;
                    buffer_value_074 = false;
                    if bit32.band(cached_buffer_value_010, 2147483648) > 0 then
                        buffer_value_074 = true;
                    end;
                    local constant_value_044 = cached_constants[bit32.band(cached_buffer_value_010, 16777215)];
                    local array_value_064 = string_value_014 - 1 + buffer_value_073;
                    local array_value_065 = table_value_013[array_value_064];
                    if array_value_065 then
                        table.insert(array_value_065, string_value_014 - 2);
                    else
                        table_value_013[array_value_064] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPXEQKN " .. buffer_value_072 .. ", " .. buffer_value_073 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_010, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_010, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_010, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_010, 255)]) .. "]", "if var" .. buffer_value_072 .. " " .. (buffer_value_074 and "~" or "=") .. "= " .. format_constant(constant_value_044) .. " then goto [" .. array_value_064 .. "] end");
                end,
                JUMPXEQKS = function(param_221, _)
                    local buffer_value_075 = bit32.band(bit32.rshift(param_221, 8), 255);
                    buffer.writeu16(array_value_013, 0, (bit32.band(bit32.rshift(param_221, 16), 65535)));
                    local buffer_value_076 = buffer.readi16(array_value_013, 0);
                    local buffer_value_077 = cached_code[string_value_014];
                    if string_value_014 == condition_value_009 then
                        error("Corrupted aux");
                    end;
                    string_value_014 = string_value_014 + 1;
                    local cached_buffer_value_011 = buffer_value_077;
                    buffer_value_077 = false;
                    if bit32.band(cached_buffer_value_011, 2147483648) > 0 then
                        buffer_value_077 = true;
                    end;
                    local constant_value_045 = cached_constants[bit32.band(cached_buffer_value_011, 16777215)];
                    local array_value_066 = string_value_014 - 1 + buffer_value_076;
                    local array_value_067 = table_value_013[array_value_066];
                    if array_value_067 then
                        table.insert(array_value_067, string_value_014 - 2);
                    else
                        table_value_013[array_value_066] = {
                            string_value_014 - 2
                        };
                    end;
                    emit_disassembly_line("JUMPXEQKS " .. buffer_value_075 .. ", " .. buffer_value_076 .. " [0x" .. (HEX_BYTE[bit32.rshift(cached_buffer_value_011, 24)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_011, 16), 255)] .. HEX_BYTE[bit32.band(bit32.rrotate(cached_buffer_value_011, 8), 255)] .. HEX_BYTE[bit32.band(cached_buffer_value_011, 255)]) .. "]", "if var" .. buffer_value_075 .. " " .. (buffer_value_077 and "~" or "=") .. "= " .. format_constant(constant_value_045) .. " then goto [" .. array_value_066 .. "] end");
                end,
                IDIV = function(param_222, _)
                    local bit_value_143 = bit32.band(bit32.rshift(param_222, 8), 255);
                    local bit_value_144 = bit32.band(bit32.rshift(param_222, 16), 255);
                    local bit_value_145 = bit32.band(bit32.rshift(param_222, 24), 255);
                    if bit_value_143 == bit_value_144 then
                        emit_disassembly_line("IDIV " .. bit_value_143 .. ", " .. bit_value_144 .. ", " .. bit_value_145, "var" .. bit_value_143 .. " //= var" .. bit_value_145);
                        return;
                    else
                        emit_disassembly_line("IDIV " .. bit_value_143 .. ", " .. bit_value_144 .. ", " .. bit_value_145, "var" .. bit_value_143 .. " = var" .. bit_value_144 .. " // var" .. bit_value_145);
                        return;
                    end;
                end,
                IDIVK = function(param_223, _)
                    local bit_value_146 = bit32.band(bit32.rshift(param_223, 8), 255);
                    local constant_value_046 = bit32.band(bit32.rshift(param_223, 16), 255);
                    local constant_value_047 = bit32.band(bit32.rshift(param_223, 24), 255);
                    local constant_value_048 = cached_constants[constant_value_047];
                    if bit_value_146 == constant_value_046 then
                        emit_disassembly_line("IDIVK " .. bit_value_146 .. ", " .. constant_value_046 .. ", " .. constant_value_047, "var" .. bit_value_146 .. " //= " .. format_constant(constant_value_048));
                        return;
                    else
                        emit_disassembly_line("IDIVK " .. bit_value_146 .. ", " .. constant_value_046 .. ", " .. constant_value_047, "var" .. bit_value_146 .. " = var" .. constant_value_046 .. " // " .. format_constant(constant_value_048));
                        return;
                    end;
                end
            };
            local table_value_016 = {};
            for condition_value_013, item_008 in pairs(table_value_014) do
                if opcode_def_by_name[condition_value_013] then
                    local opcode_value_008 = opcode_def_by_name[condition_value_013];
                    if not opcode_value_008 then
                        error((("Unknown opname %*"):format(condition_value_013)));
                    end;
                    table_value_016[opcode_value_008.opcode] = item_008;
                end;
            end;
            local table_value_017 = {};
            local cached_param_001 = param_137;
            if not array_value_012 then
                local cached_param_002 = param_137;
                param_137 = string.rep("\t", #cached_param_002 + 1);
            end;
            if condition_value_009 > 0 then
                while string_value_014 <= condition_value_009 do
                    local bit_value_147 = cached_code[string_value_014];
                    string_value_013 = string_value_014;
                    string_value_014 = string_value_014 + 1;
                    string_value_015 = string_value_015 + 1;
                    local bit_value_148 = table_value_016[bit32.band(bit_value_147, 255)];
                    if bit_value_148 then
                        string_value_011 = param_137 .. "[" .. string_value_014 - 1 .. "] #" .. string_value_015;
                        bit_value_148(bit_value_147, param_137);
                        table.insert(table_value_012, string_value_011);
                        table_value_017[string_value_011] = string_value_013;
                    else
                        table.insert(table_value_012, (("%*; Unknown opcode 0x%* (%* reversed: 0x%*)\n"):format(param_137, HEX_BYTE[bit32.band(bit_value_147, 255)], active_opcode_encoding, HEX_BYTE[decoded_opcode_by_encoded_byte[bit32.band(bit_value_147, 255)]])));
                        failed_instruction_count = failed_instruction_count + 1;
                    end;
                end;
            end;
            string_value_011 = "";
            param_137 = cached_param_001;
            for local_symbol_007, item_009 in ipairs(table_value_012) do
                local condition_value_014 = table_value_013[table_value_017[item_009]];
                if condition_value_014 then
                    table_value_012[local_symbol_007] = param_137 .. "::" .. table.concat(condition_value_014, "::, ::") .. "::\n" .. item_009;
                end;
            end;
            if not array_value_012 then
                table.insert(table_value_012, param_137 .. "end\n");
            end;
            return;
        end;
    end;
    format_import_path(buffer_value_021, "");
    table.insert(table_value_012, 1, (("-- Disassembled with Konstant V%*'s disassembler, made by plusgiant5\n\t\t-- Disassembled on %*\n\t\t-- Luau version %*%*\n\t\t-- Time taken: %* seconds\n\n"):format("2.1", os.date("%Y-%m-%d %H:%M:%S"), buffer_value_023, if buffer_value_024 then (", Types version %*"):format(buffer_value_024) else "", (string.format("%.6f", clock_ref() - buffer_value_025)))));
    string_value_011 = "";
    local buffer_value_078 = 0;
    for _, item_010 in ipairs(table_value_012) do
        buffer_value_078 = buffer_value_078 + #item_010;
    end;
    local buffer_value_079 = buffer.create(buffer_value_078 - 1);
    local buffer_value_080 = 0;
    for buffer_value_081, item_011 in ipairs(table_value_012) do
        if buffer_value_081 == #table_value_012 then
            item_011 = string.sub(item_011, 1, #item_011 - 1);
        end;
        buffer.writestring(buffer_value_079, buffer_value_080, item_011);
        buffer_value_080 = buffer_value_080 + #item_011;
    end;
    return buffer.tostring(buffer_value_079);
end;
local previous_error_prefix = DEFAULT_DECOMPILER_OPTIONS.prefix_error;
local previous_warning_prefix = DEFAULT_DECOMPILER_OPTIONS.prefix_warning;
local previous_information_prefix = DEFAULT_DECOMPILER_OPTIONS.prefix_information;
local v_runtime_options = {
    strict = true,
    strict_types = true,
    strictTypes = true,
    allow_new_type_info_fallback = true,
    allow_unknown_type_info_fallback = true,
    ignore_unsupported_debug_info = true,
    show_decompiler_summary = true
};
local function decompile_bytecode(param_224, param_225)
    current_instruction_index = 0;
    last_multireturn_register = 0;
    local local_symbol_008 = clock_ref();
    last_yield_time = local_symbol_008;
    local local_symbol_009 = create_noop_benchmark();
    local_symbol_009:start_benchmark("Global Initialization");
    failed_instruction_count = 0;
    local condition_value_015 = param_225 or {};
    assert(condition_value_015);
    for item_012 in pairs(condition_value_015) do
        if DEFAULT_DECOMPILER_OPTIONS[item_012] == nil and not v_runtime_options[item_012] then
            error("Unknown setting \"" .. tostring(item_012) .. "\"");
        end;
    end;
    for string_value_016, item_013 in pairs(DEFAULT_DECOMPILER_OPTIONS) do
        if condition_value_015[string_value_016] == nil then
            condition_value_015[string_value_016] = item_013;
        end;
    end;
    if condition_value_015.smart_var_level then
        assert(condition_value_015.smart_var_level == math.floor(condition_value_015.smart_var_level), "Expected `smart_var_level` to be an integer");
        assert(condition_value_015.smart_var_level >= 0, "Expected `smart_var_level` to be >= 0");
        assert(condition_value_015.smart_var_level <= 3, "Expected `smart_var_level` to be <= 3");
    end;
    local cached_prefix_error = condition_value_015.prefix_error;
    assert(cached_prefix_error);
    if string.match(cached_prefix_error, "\n") then
        error("Cannot have newline characters in `prefix_error`");
    end;
    previous_error_prefix = cached_prefix_error;
    local cached_prefix_warning = condition_value_015.prefix_warning;
    assert(cached_prefix_warning);
    if string.match(cached_prefix_warning, "\n") then
        error("Cannot have newline characters in `prefix_warning`");
    end;
    previous_warning_prefix = cached_prefix_warning;
    local cached_prefix_information = condition_value_015.prefix_information;
    assert(cached_prefix_information);
    if string.match(cached_prefix_information, "\n") then
        error("Cannot have newline characters in `prefix_information`");
    end;
    previous_information_prefix = cached_prefix_information;
    if string.byte(param_224, 1, 1) == 0 then
        local string_value_017 = ("-- Decompiled with Konstant%*, a fast Luau decompiler made in Luau by plusgiant5\n"):format("2.1");
        if type(param_224) ~= "string" and getscripthash_ref then
            string_value_017 = string_value_017 .. ("-- Script hash: %*\n"):format((string.upper(getscripthash_ref(param_224))));
        end;
        return (((string_value_017 .. ("-- Decompiled on %*\n"):format((os.date("%Y-%m-%d %H:%M:%S")))) .. ("-- Time taken: %* seconds\n"):format((string.format("%.6f", clock_ref() - local_symbol_008)))) .. "\n-- Target script didn't compile. Compilation error below:\n") .. "--[[\n" .. string.sub(2, #param_224) .. "\n]]";
    else
        local array_value_068, array_value_069, _, array_value_070 = deserialize_luau_bytecode(param_224);
        current_proto_context = array_value_069;
        local table_value_018 = {};
        local table_value_019 = {};
        local function _(param_226, param_227)
            table.insert(table_value_019, {
                type = param_226,
                content = param_227
            });
        end;
        local table_value_020 = {};
        local function _(param_228)
            while param_228.t == "name" do
                local cached_override_expr = param_228.name.override_expr;
                if cached_override_expr then
                    param_228 = cached_override_expr;
                else
                    break;
                end;
            end;
            return param_228;
        end;
        local function _(param_229, param_230)
            local cached_param_003 = param_229;
            while cached_param_003.t == "name" do
                local cached_override_expr_001 = cached_param_003.name.override_expr;
                if cached_override_expr_001 then
                    cached_param_003 = cached_override_expr_001;
                else
                    break;
                end;
            end;
            param_229 = cached_param_003;
            if param_229.t == "name" then
                return param_229.name == param_230;
            else
                return false;
            end;
        end;
        local function _(param_231)
            local cached_var_num_001 = param_231.var_num;
            assert(cached_var_num_001);
            return cached_var_num_001;
        end;
        local function _(param_232)
            local cached_var_list = param_232.var_list;
            assert(cached_var_list);
            return cached_var_list;
        end;
        local function _(param_233, param_234)
            for item_014 in pairs(param_234.contributors) do
                param_233.contributors[item_014] = true;
            end;
            param_233.contributors[param_234] = true;
        end;
        local function _(param_235, param_236)
            table.insert(param_235.reads, param_236);
            table.insert(param_236.reads, param_235);
        end;
        local function _(param_237, param_238)
            table.insert(param_237.writes, param_238);
            table.insert(param_238.writes, param_237);
        end;
        local function make_location_range(param_239, param_240)
            local array_value_071 = table.find(param_239.reads, param_240);
            assert(array_value_071);
            table.remove(param_239.reads, array_value_071);
            local local_symbol_010 = table.find(param_240.reads, param_239);
            assert(local_symbol_010);
            table.remove(param_240.reads, local_symbol_010);
        end;
        local function get_range_size(param_241, param_242)
            local local_symbol_011 = table.find(param_241.writes, param_242);
            assert(local_symbol_011);
            table.remove(param_241.writes, local_symbol_011);
            local local_symbol_012 = table.find(param_242.writes, param_241);
            assert(local_symbol_012);
            table.remove(param_242.writes, local_symbol_012);
        end;
        local function ranges_equal(param_243, param_244)
            for _, item_015 in ipairs(param_244.reads) do
                table.insert(param_243.reads, item_015);
                table.insert(item_015.reads, param_243);
            end;
            for _, item_016 in ipairs(param_244.writes) do
                table.insert(param_243.writes, item_016);
                table.insert(item_016.writes, param_243);
            end;
        end;
        local function format_range(param_245, param_246)
            for _, item_017 in ipairs(param_246.reads) do
                make_location_range(param_245, item_017);
            end;
            for _, item_018 in ipairs(param_246.writes) do
                get_range_size(param_245, item_018);
            end;
        end;
        local string_value_018 = 1;
        local table_value_021 = {
            [0] = "nil",
            [1] = "boolean",
            [2] = "number",
            [3] = "string",
            [4] = "table",
            [5] = "function",
            [6] = "thread",
            [7] = "userdata",
            [8] = "vector",
            [9] = "buffer",
            [15] = "any"
        };
        local function _(param_247)
            local bit_value_149 = bit32.band(param_247, 128) > 0;
            local bit_value_150 = table_value_021[param_247];
            if bit_value_150 then
                return {
                    type = bit_value_150,
                    optional = bit_value_149
                };
            else
                return {
                    type = "invalid",
                    optional = false
                };
            end;
        end;
        local function _(param_248)
            param_248.condition = INVERTED_CONDITION_OPERATOR[param_248.condition];
        end;
        local table_value_022 = {};
        local function is_point_in_range(param_249)
            return {
                t = "comment",
                lines = table_value_022,
                reads = {},
                writes = {},
                text = param_249,
                stack = 1
            };
        end;
        local table_value_023 = {};
        local local_symbol_013 = 1;
        local function _(param_250)
            return table_value_023[param_250];
        end;
        local function _(param_251)
            local local_symbol_014 = table_value_023[param_251];
            assert(local_symbol_014);
            return local_symbol_014;
        end;
        local table_value_024 = {};
        local function _(param_252)
            local local_symbol_015 = table_value_024[param_252];
            local cached_param_004 = param_252;
            local local_symbol_016 = local_symbol_015 or 1;
            while table_value_023[cached_param_004] or table_value_018[cached_param_004] do
                local_symbol_016 = local_symbol_016 + 1;
                cached_param_004 = param_252 .. "_" .. local_symbol_016;
            end;
            table_value_024[param_252] = local_symbol_016;
            return cached_param_004;
        end;
        local function is_point_in_named_range(param_253, param_254, param_255)
            if table_value_023[param_253] and param_253 ~= "_" then
                error((("[alloc] Variable %* already allocated"):format(param_253)));
            end;
            local table_value_025 = {
                name = param_253,
                attributes = {},
                reads = {},
                writes = {},
                registers = param_254,
                var_num = #param_255 + 1,
                var_list = param_255
            };
            table_value_023[param_253] = table_value_025;
            table.insert(param_255, table_value_025);
            return table_value_023[param_253];
        end;
        local function _(param_256)
            local range_value_004 = table_value_023[param_256];
            if range_value_004 then
                return range_value_004;
            else
                return (is_point_in_named_range(param_256, {
                    beginning = -1,
                    ending = -1
                }, {}));
            end;
        end;
        local function _(param_257, param_258, param_259)
            param_257.init_expr = param_258;
            param_257.var_num = param_259;
        end;
        local function _(param_260)
            local cached_name_001 = param_260.name;
            if not table_value_023[cached_name_001] then
                error((("[free] Variable %* not allocated"):format(param_260.name)));
            end;
            table_value_023[cached_name_001] = nil;
        end;
        local function _(param_261, param_262)
            local cached_name_002 = param_261.name;
            if not table_value_023[cached_name_002] then
                error((("[write] Variable %* not allocated"):format(param_261.name)));
            end;
            if table_value_023[cached_name_002].luau_type and table_value_023[cached_name_002].luau_type ~= param_262 then
                error((("[write] Attempt to retype %*: %* to %*: %*"):format(param_261.name, table_value_023[cached_name_002].luau_type, param_261, param_262)));
            end;
            table_value_023[cached_name_002].luau_type = param_262;
        end;
        local function _(param_263, param_264)
            local cached_name_003 = param_263.name;
            if not table_value_023[cached_name_003] then
                error((("[write] Variable %* not allocated"):format(cached_name_003)));
            end;
            table_value_023[cached_name_003] = nil;
            param_263.name = param_264;
            table_value_023[param_264] = param_263;
            param_263.attributes.renamed = true;
        end;
        local function _(param_265, param_266)
            local cached_name_004 = param_265.name;
            if not table_value_023[cached_name_004] then
                error((("[write] Variable %* not allocated"):format(cached_name_004)));
            end;
            table_value_023[cached_name_004] = nil;
            param_265.override_expr = param_266;
        end;
        local function _()
            local expression_value_001 = "var" .. tostring(string_value_018);
            local string_value_019 = table_value_024[expression_value_001];
            local cached_expression_value_001 = expression_value_001;
            local string_value_020 = string_value_019 or 1;
            while table_value_023[cached_expression_value_001] or table_value_018[cached_expression_value_001] do
                string_value_020 = string_value_020 + 1;
                cached_expression_value_001 = expression_value_001 .. "_" .. string_value_020;
            end;
            table_value_024[expression_value_001] = string_value_020;
            local cached_expression_value_002 = cached_expression_value_001;
            string_value_018 = string_value_018 + 1;
            return cached_expression_value_002;
        end;
        local function _(param_267, param_268)
            local cached_is_point_in_named_range = is_point_in_named_range;
            local string_value_021 = "var" .. tostring(string_value_018);
            local string_value_022 = table_value_024[string_value_021];
            local cached_string_value_003 = string_value_021;
            local string_value_023 = string_value_022 or 1;
            while table_value_023[cached_string_value_003] or table_value_018[cached_string_value_003] do
                string_value_023 = string_value_023 + 1;
                cached_string_value_003 = string_value_021 .. "_" .. string_value_023;
            end;
            table_value_024[string_value_021] = string_value_023;
            local cached_string_value_004 = cached_string_value_003;
            string_value_018 = string_value_018 + 1;
            return (cached_is_point_in_named_range(cached_string_value_004, param_267, param_268));
        end;
        local _ = function(param_269, _)
            local string_value_024 = "arg" .. tostring(local_symbol_013);
            if condition_value_015.exact_argument_names then
                string_value_024 = param_269 .. "_" .. string_value_024;
            end;
            local cached_string_value_005 = string_value_024;
            local local_symbol_017 = table_value_024[cached_string_value_005];
            local cached_string_value_006 = cached_string_value_005;
            local local_symbol_018 = local_symbol_017 or 1;
            while table_value_023[cached_string_value_006] or table_value_018[cached_string_value_006] do
                local_symbol_018 = local_symbol_018 + 1;
                cached_string_value_006 = cached_string_value_005 .. "_" .. local_symbol_018;
            end;
            table_value_024[cached_string_value_005] = local_symbol_018;
            string_value_024 = cached_string_value_006;
            local_symbol_013 = local_symbol_013 + 1;
            return string_value_024;
        end;
        local function _(param_270, param_271, param_272)
            local cached_is_point_in_named_range_001 = is_point_in_named_range;
            local cached_name_005 = param_270.name;
            local string_value_025 = "arg" .. tostring(local_symbol_013);
            if condition_value_015.exact_argument_names then
                string_value_025 = cached_name_005 .. "_" .. string_value_025;
            end;
            local cached_string_value_007 = string_value_025;
            local local_symbol_019 = table_value_024[cached_string_value_007];
            local cached_string_value_008 = cached_string_value_007;
            local local_symbol_020 = local_symbol_019 or 1;
            while table_value_023[cached_string_value_008] or table_value_018[cached_string_value_008] do
                local_symbol_020 = local_symbol_020 + 1;
                cached_string_value_008 = cached_string_value_007 .. "_" .. local_symbol_020;
            end;
            table_value_024[cached_string_value_007] = local_symbol_020;
            string_value_025 = cached_string_value_008;
            local_symbol_013 = local_symbol_013 + 1;
            cached_is_point_in_named_range_001 = cached_is_point_in_named_range_001(string_value_025, {
                beginning = param_271,
                ending = param_271
            }, param_272);
            cached_is_point_in_named_range_001.func_name = param_270;
            return cached_is_point_in_named_range_001;
        end;
        local table_value_026 = {};
        local function reverse_array_in_place()
            return {
                t = "nothing",
                lines = table_value_022,
                reads = {},
                writes = {}
            };
        end;
        local function conditional_not(param_273)
            if param_273 then
                return {
                    t = "nil",
                    reads = {},
                    writes = {},
                    contributors = {},
                    invisible = true
                };
            else
                return {
                    t = "nil",
                    reads = {},
                    writes = {},
                    contributors = {}
                };
            end;
        end;
        local function create_expression(param_274, param_275, _)
            local array_value_072 = table.clone(param_274.reads);
            local array_value_073 = table.clone(param_274.writes);
            local array_value_074 = table.clone(param_274.contributors);
            for _, item_019 in ipairs(param_275) do
                for _, item_020 in ipairs(item_019.reads) do
                    table.insert(array_value_072, item_020);
                end;
                for _, item_021 in ipairs(item_019.writes) do
                    table.insert(array_value_073, item_021);
                end;
                for item_022 in pairs(item_019.contributors) do
                    array_value_074[item_022] = true;
                end;
            end;
            return {
                t = "call",
                reads = array_value_072,
                writes = array_value_073,
                contributors = array_value_074,
                func = param_274,
                args = param_275
            };
        end;
        local function helper_function_001(param_276)
            return {
                t = "name",
                reads = {
                    param_276
                },
                writes = {},
                contributors = {},
                name = param_276
            };
        end;
        local function helper_function_002(param_277)
            return {
                t = "not",
                reads = table.clone(param_277.reads),
                writes = table.clone(param_277.writes),
                contributors = table.clone(param_277.contributors),
                precedence = 2,
                rhs = param_277
            };
        end;
        local function helper_function_003(param_278, param_279)
            local table_value_027 = {
                t = "and",
                reads = append_array_copy(param_278.reads, param_279.reads),
                writes = append_array_copy(param_278.writes, param_279.writes)
            };
            local cached_contributors = param_278.contributors;
            local cached_contributors_001 = param_279.contributors;
            local array_value_075 = table.clone(cached_contributors);
            for item_023 in pairs(cached_contributors_001) do
                array_value_075[item_023] = true;
            end;
            table_value_027.contributors = array_value_075;
            table_value_027.precedence = 7;
            table_value_027.lhs = param_278;
            table_value_027.rhs = param_279;
            return table_value_027;
        end;
        local function helper_function_004(param_280, param_281, param_282)
            if param_282 then
                local table_value_028 = {
                    t = "condition",
                    reads = append_array_copy(param_280.reads, param_282.reads),
                    writes = append_array_copy(param_280.writes, param_282.writes)
                };
                local cached_contributors_002 = param_280.contributors;
                local cached_contributors_003 = param_282.contributors;
                local array_value_076 = table.clone(cached_contributors_002);
                for item_024 in pairs(cached_contributors_003) do
                    array_value_076[item_024] = true;
                end;
                table_value_028.contributors = array_value_076;
                table_value_028.precedence = 6;
                table_value_028.condition = param_281;
                table_value_028.lhs = param_280;
                table_value_028.rhs = param_282;
                return table_value_028;
            else
                return {
                    t = "condition",
                    reads = table.clone(param_280.reads),
                    writes = table.clone(param_280.writes),
                    contributors = table.clone(param_280.contributors),
                    precedence = 2,
                    condition = param_281,
                    lhs = param_280
                };
            end;
        end;
        local function helper_function_005(param_283, param_284, param_285, param_286, param_287)
            local table_value_029 = {
                t = "define function",
                reads = {},
                writes = {},
                lines = param_283,
                func = param_284,
                func_name = param_285,
                define_function_type = param_286,
                path = param_287
            };
            ranges_equal(table_value_029, param_284);
            return table_value_029;
        end;
        local function helper_function_006(param_288, param_289)
            return {
                t = "return",
                lines = param_288,
                reads = {},
                writes = {},
                values = param_289
            };
        end;
        local function _(param_290)
            if param_290.t == "condition" then
                param_290.condition = INVERTED_CONDITION_OPERATOR[param_290.condition];
                return param_290;
            elseif param_290.t == "not" then
                return param_290.rhs;
            else
                return (helper_function_002(param_290));
            end;
        end;
        local table_value_030 = {};
        local table_value_031 = {};
        local table_value_032 = {};
        local table_value_033 = {};
        local table_value_034 = {};
        local local_symbol_021 = 0;
        local table_value_035 = {};
        local table_value_036 = {};
        local local_symbol_022 = 0;
        local function _(param_291)
            table_value_036[param_291] = true;
            local_symbol_022 = local_symbol_022 + 1;
        end;
        local function helper_function_007()
            return {
                global_failed_instructions_count = failed_instruction_count,
                notices = table.clone(table_value_019),
                lines = table.clone(table_value_022),
                variable_mapped_long_string_constants = table.clone(table_value_031),
                variable_mapped_long_string_constants_order = table.clone(table_value_032),
                long_string_usage_counts = table.clone(table_value_033),
                long_string_constant_already_used = table.clone(table_value_034),
                long_string_variable_count = local_symbol_021,
                lines_had_skipped_return = table.clone(table_value_035),
                condition_stop_points = table.clone(table_value_036),
                marked_condition_stop_points = local_symbol_022
            };
        end;
        local function _(param_292)
            failed_instruction_count = param_292.global_failed_instructions_count;
            table_value_019 = param_292.notices;
            table_value_022 = param_292.lines;
            table_value_031 = param_292.variable_mapped_long_string_constants;
            table_value_032 = param_292.variable_mapped_long_string_constants_order;
            table_value_033 = param_292.long_string_usage_counts;
            table_value_034 = param_292.long_string_constant_already_used;
            local_symbol_021 = param_292.long_string_variable_count;
            table_value_035 = param_292.lines_had_skipped_return;
            table_value_036 = param_292.condition_stop_points;
            local_symbol_022 = param_292.marked_condition_stop_points;
        end;
        local helper_function_008 = nil;
        local function helper_function_009(param_293, param_294)
            local local_symbol_023 = create_noop_benchmark();
            local_symbol_023:start_benchmark("Initialization");
            local cached_current_function_context = current_function_context;
            current_function_context = param_293;
            local_symbol_013 = 1;
            local proto_value_006 = 0;
            local cached_constants_001 = param_293.constants;
            local cached_protos_001 = param_293.protos;
            local cached_code_001 = param_293.code;
            local array_value_077 = #cached_code_001;
            local array_value_078 = nil;
            if param_293.stack_size > 0 then
                array_value_078 = table.create(param_293.stack_size - 1);
                array_value_078[0] = nil;
            else
                array_value_078 = {};
            end;
            local table_value_037 = {};
            local table_value_038 = {};
            local local_symbol_024 = 0;
            local local_symbol_025 = 0;
            local table_value_039 = {};
            local table_value_040 = {};
            local table_value_041 = {};
            local table_value_042 = {};
            local table_value_043 = {};
            local function helper_function_010()
                if table_value_042.t == "name" then
                    warn(debug.traceback());
                end;
                if not table_value_042.t then
                    error("messageWAHTTERSDGXCvlkhx d");
                end;
                table.insert(table_value_022, table_value_042);
                table_value_020[table_value_042] = table_value_043;
                table_value_042 = {
                    t = "Unknown",
                    lines = table_value_022,
                    reads = {},
                    writes = {}
                };
            end;
            local function helper_function_011(param_295, param_296)
                if table_value_042.t == "name" then
                    warn(debug.traceback());
                end;
                param_295 = math.max(param_295, 1);
                table_value_042.index = param_295;
                table.insert(param_296 or table_value_022, param_295, table_value_042);
                table_value_020[table_value_042] = table_value_043;
                table_value_042 = {
                    t = "Unknown",
                    lines = table_value_022,
                    reads = {},
                    writes = {}
                };
            end;
            local function helper_function_012(param_297)
                local string_value_026 = table_value_022[#table_value_022];
                if string_value_026 and string_value_026.t == "comment" and string.sub(string_value_026.text, 1, #param_297) == param_297 then
                    string_value_026.stack = string_value_026.stack + 1;
                    string_value_026.text = param_297 .. " (x" .. string_value_026.stack .. ")";
                    return;
                else
                    table_value_042 = is_point_in_range(param_297);
                    helper_function_010();
                    return;
                end;
            end;
            local function helper_function_013(param_298, param_299)
                table_value_042 = is_point_in_range(param_299);
                helper_function_011(param_298);
            end;
            local helper_function_014 = nil;
            local function helper_function_015(param_300, _)
                return helper_function_014(param_300, (conditional_not(true)));
            end;
            local function _()
                table_value_042 = {
                    t = "nothing",
                    lines = table_value_022,
                    reads = {},
                    writes = {}
                };
            end;
            local function helper_function_016(param_301, param_302)
                if param_302.varname then
                    assert(#param_301 == 1);
                    assert(param_301[1] == param_302.varname);
                end;
                assert(#param_301 > 0);
                table_value_042 = {
                    t = "define variable",
                    lines = table_value_022,
                    reads = {},
                    writes = {},
                    names = param_301,
                    value = param_302
                };
                if param_302.t == "nil" and param_302.invisible then
                    for expression_value_002, item_025 in ipairs(param_301) do
                        item_025.init_expr = param_302;
                        item_025.var_num = expression_value_002;
                    end;
                else
                    for expression_value_003, item_026 in ipairs(param_301) do
                        item_026.init_expr = param_302;
                        item_026.var_num = expression_value_003;
                        local cached_table_value_001 = table_value_042;
                        table.insert(cached_table_value_001.writes, item_026);
                        table.insert(item_026.writes, cached_table_value_001);
                    end;
                end;
                ranges_equal(table_value_042, param_302);
            end;
            local helper_function_017 = nil;
            local table_value_044 = {};
            local table_value_045 = {};
            local function _(param_303, param_304)
                table_value_044[param_303] = param_304;
            end;
            local function _(param_305)
                for index_021 = param_305.beginning, param_305.ending do
                    if table_value_044[index_021] then
                        table_value_044[index_021] = nil;
                    end;
                end;
            end;
            local function _(param_306)
                return table_value_044[param_306];
            end;
            local function _(param_307)
                table_value_045[param_307] = true;
            end;
            local function _(param_308)
                table_value_045[param_308] = nil;
            end;
            local function _(param_309)
                if table_value_045[param_309] then
                    return true;
                else
                    return false;
                end;
            end;
            local function _(param_310)
                local expression_value_004 = array_value_078[param_310];
                if not expression_value_004 then
                    helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_310) .. "]");
                    expression_value_004 = helper_function_014(param_310, (conditional_not(true)));
                end;
                return expression_value_004;
            end;
            local function helper_function_018(param_311)
                if table_value_044[param_311] then
                    return helper_function_017(param_311, table_value_044[param_311]);
                else
                    local expression_value_005 = array_value_078[param_311];
                    if not expression_value_005 then
                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_311) .. "]");
                        expression_value_005 = helper_function_014(param_311, (conditional_not(true)));
                    end;
                    return expression_value_005;
                end;
            end;
            local function helper_function_019(param_312, param_313, param_314)
                assert(#param_314 > 0);
                local range_value_005 = 0;
                for index_022 = param_312.beginning, param_312.ending do
                    range_value_005 = range_value_005 + 1;
                    local range_value_006 = param_314[range_value_005];
                    assert(range_value_006);
                    table_value_044[index_022] = range_value_006;
                end;
                helper_function_016(param_314, param_313);
                helper_function_010();
            end;
            local function helper_function_020(param_315, param_316)
                assert(#param_316 > 0);
                local cached_beginning = param_315.beginning;
                local range_value_007 = array_value_078[cached_beginning];
                assert(range_value_007);
                local range_value_008 = 0;
                for index_023 = cached_beginning, param_315.ending do
                    range_value_008 = range_value_008 + 1;
                    local range_value_009 = param_316[range_value_008];
                    assert(range_value_009);
                    table_value_044[index_023] = range_value_009;
                end;
                helper_function_016(param_316, range_value_007);
                helper_function_010();
            end;
            local local_symbol_026 = nil;
            local function _(param_317, param_318)
                array_value_078[param_317] = param_318;
            end;
            local function _(param_319)
                if table_value_030[param_319] then
                    helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    return param_319;
                else
                    table_value_030[param_319] = true;
                    return param_319;
                end;
            end;
            local function helper_function_021(param_320, param_321)
                local table_value_046 = {
                    t = "set variable",
                    reads = {},
                    writes = {},
                    lines = table_value_022,
                    name = param_320,
                    value = param_321
                };
                ranges_equal(table_value_046, param_321);
                table.insert(table_value_046.writes, param_320);
                table.insert(param_320.writes, table_value_046);
                table_value_042 = table_value_046;
            end;
            local_symbol_026 = helper_function_021;
            local function helper_function_022(param_322, param_323)
                local table_value_047 = {
                    t = "set global",
                    reads = {},
                    writes = {},
                    lines = table_value_022,
                    name = param_322,
                    value = param_323
                };
                ranges_equal(table_value_047, param_323);
                table_value_042 = table_value_047;
            end;
            local function helper_function_023(param_324, param_325, param_326)
                local local_symbol_027;
                if table_value_044[param_324] then
                    local_symbol_027 = helper_function_017(param_324, table_value_044[param_324]);
                else
                    local expression_value_006 = array_value_078[param_324];
                    if not expression_value_006 then
                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_324) .. "]");
                        expression_value_006 = helper_function_014(param_324, (conditional_not(true)));
                    end;
                    local_symbol_027 = expression_value_006;
                end;
                if table_value_030[local_symbol_027] then
                    helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                else
                    table_value_030[local_symbol_027] = true;
                end;
                local cached_local_symbol_001 = local_symbol_027;
                table_value_042 = {
                    t = "set table",
                    lines = table_value_022,
                    reads = {},
                    writes = {},
                    table = cached_local_symbol_001,
                    key = param_325,
                    value = param_326
                };
                ranges_equal(table_value_042, cached_local_symbol_001);
                ranges_equal(table_value_042, param_325);
                ranges_equal(table_value_042, param_326);
            end;
            local function helper_function_024(param_327, param_328)
                local table_value_048 = {};
                local condition_value_016 = helper_function_006(table_value_022, table_value_048);
                if param_328 == -1 then
                    for index_024 = param_327, current_instruction_index do
                        local condition_value_017;
                        if table_value_044[index_024] then
                            condition_value_017 = helper_function_017(index_024, table_value_044[index_024]);
                        else
                            local expression_value_007 = array_value_078[index_024];
                            if not expression_value_007 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(index_024) .. "]");
                                expression_value_007 = helper_function_014(index_024, (conditional_not(true)));
                            end;
                            condition_value_017 = expression_value_007;
                        end;
                        if table_value_030[condition_value_017] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[condition_value_017] = true;
                        end;
                        local cached_condition_value_001 = condition_value_017;
                        ranges_equal(condition_value_016, cached_condition_value_001);
                        table.insert(table_value_048, cached_condition_value_001);
                    end;
                else
                    for index_025 = param_327, param_327 + param_328 - 1 do
                        local local_symbol_028;
                        if table_value_044[index_025] then
                            local_symbol_028 = helper_function_017(index_025, table_value_044[index_025]);
                        else
                            local expression_value_008 = array_value_078[index_025];
                            if not expression_value_008 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(index_025) .. "]");
                                expression_value_008 = helper_function_014(index_025, (conditional_not(true)));
                            end;
                            local_symbol_028 = expression_value_008;
                        end;
                        if table_value_030[local_symbol_028] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_028] = true;
                        end;
                        local cached_local_symbol_002 = local_symbol_028;
                        ranges_equal(condition_value_016, cached_local_symbol_002);
                        table.insert(table_value_048, cached_local_symbol_002);
                    end;
                end;
                table_value_042 = condition_value_016;
            end;
            local function helper_function_025()
                table_value_042 = {
                    t = "break",
                    lines = table_value_022,
                    reads = {},
                    writes = {}
                };
            end;
            local function helper_function_026()
                table_value_042 = {
                    t = "continue",
                    lines = table_value_022,
                    reads = {},
                    writes = {}
                };
            end;
            local function helper_function_027(param_329)
                table_value_042 = {
                    t = "unknown jump",
                    lines = table_value_022,
                    reads = {},
                    writes = {},
                    destination = param_329
                };
            end;
            local function helper_function_028(param_330)
                local table_value_049 = {};
                local cached_var_reg_range = param_330.var_reg_range;
                local cached_beginning_001 = cached_var_reg_range.beginning;
                local cached_ending = cached_var_reg_range.ending;
                if cached_beginning_001 == cached_ending then
                    local table_value_050 = {};
                    local cached_is_point_in_named_range_002 = is_point_in_named_range;
                    local string_value_027 = "var" .. tostring(string_value_018);
                    local string_value_028 = table_value_024[string_value_027];
                    local cached_string_value_009 = string_value_027;
                    local local_symbol_029 = string_value_028 or 1;
                    while table_value_023[cached_string_value_009] or table_value_018[cached_string_value_009] do
                        local_symbol_029 = local_symbol_029 + 1;
                        cached_string_value_009 = string_value_027 .. "_" .. local_symbol_029;
                    end;
                    table_value_024[string_value_027] = local_symbol_029;
                    local cached_string_value_010 = cached_string_value_009;
                    string_value_018 = string_value_018 + 1;
                    table.insert(table_value_049, (cached_is_point_in_named_range_002(cached_string_value_010, cached_var_reg_range, table_value_050)));
                    return table_value_049;
                else
                    local table_value_051 = {};
                    for index_026 = cached_beginning_001, cached_ending do
                        local table_value_052 = {
                            beginning = index_026,
                            ending = index_026
                        };
                        local cached_is_point_in_named_range_003 = is_point_in_named_range;
                        local string_value_029 = "var" .. tostring(string_value_018);
                        local string_value_030 = table_value_024[string_value_029];
                        local cached_string_value_011 = string_value_029;
                        local local_symbol_030 = string_value_030 or 1;
                        while table_value_023[cached_string_value_011] or table_value_018[cached_string_value_011] do
                            local_symbol_030 = local_symbol_030 + 1;
                            cached_string_value_011 = string_value_029 .. "_" .. local_symbol_030;
                        end;
                        table_value_024[string_value_029] = local_symbol_030;
                        local cached_string_value_012 = cached_string_value_011;
                        string_value_018 = string_value_018 + 1;
                        local array_value_079 = cached_is_point_in_named_range_003(cached_string_value_012, table_value_052, table_value_051);
                        array_value_079.attributes.multireg = true;
                        table.insert(table_value_049, array_value_079);
                    end;
                    return table_value_049;
                end;
            end;
            local local_symbol_031 = true;
            local function helper_function_029()
                local condition_value_018 = table_value_038[local_symbol_024];
                assert(local_symbol_031);
                local_symbol_031 = false;
                if condition_value_018 then
                    for index_027 = #condition_value_018, 1, -1 do
                        local range_value_010 = condition_value_018[index_027];
                        local cached_type_001 = range_value_010.type;
                        if cached_type_001 == "lockvar" then
                            local cached_var_reg_range_001 = range_value_010.var_reg_range;
                            for index_028 = cached_var_reg_range_001.beginning, cached_var_reg_range_001.ending do
                                table_value_045[index_028] = true;
                            end;
                            table.remove(condition_value_018, index_027);
                        elseif cached_type_001 == "unlockvar" then
                            local cached_var_reg_range_002 = range_value_010.var_reg_range;
                            for index_029 = cached_var_reg_range_002.beginning, cached_var_reg_range_002.ending do
                                table_value_045[index_029] = nil;
                            end;
                            table.remove(condition_value_018, index_027);
                        end;
                    end;
                    if #condition_value_018 == 0 then
                        table_value_038[local_symbol_024] = nil;
                    end;
                end;
            end;
            local function helper_function_030(param_331, param_332)
                local local_symbol_032 = table_value_038[local_symbol_024];
                assert(not local_symbol_031);
                local_symbol_031 = true;
                local condition_value_019 = table_value_044[param_331];
                if condition_value_019 then
                    if table_value_045[param_331] and true or false then
                        local condition_value_020 = table_value_022[#table_value_022];
                        local condition_value_021 = nil;
                        if condition_value_020 and condition_value_020.t == "set variable" and condition_value_020.name == condition_value_019 then
                            local cached_value_001 = condition_value_020.value;
                            format_range(condition_value_020, cached_value_001);
                            local cached_t = param_332.t;
                            if cached_t == "constant index" then
                                if param_332.table.t == "name" and param_332.table.name == condition_value_019 then
                                    param_332.table = cached_value_001;
                                    condition_value_021 = true;
                                end;
                            elseif cached_t == "call" and param_332.func.t == "name" and param_332.func.name == condition_value_019 then
                                param_332.func = cached_value_001;
                                condition_value_021 = true;
                            end;
                            if condition_value_021 then
                                condition_value_020.value = param_332;
                                ranges_equal(condition_value_020, param_332);
                            end;
                        end;
                        if not condition_value_021 then
                            helper_function_021(condition_value_019, param_332);
                            helper_function_010();
                        end;
                    else
                        local cached_registers = condition_value_019.registers;
                        for index_030 = cached_registers.beginning, cached_registers.ending do
                            if table_value_044[index_030] then
                                table_value_044[index_030] = nil;
                            end;
                        end;
                    end;
                end;
                if local_symbol_032 then
                    for _, item_027 in ipairs(local_symbol_032) do
                        local cached_var_reg_range_003 = item_027.var_reg_range;
                        local cached_beginning_002 = cached_var_reg_range_003.beginning;
                        local cached_ending_001 = cached_var_reg_range_003.ending;
                        local range_value_011 = false;
                        if cached_beginning_002 <= param_331 then
                            range_value_011 = param_331 <= cached_ending_001;
                        end;
                        if not range_value_011 then

                        end;
                        if item_027.type == "defvar" then
                            range_value_011 = nil;
                            if not item_027.predef then
                                cached_beginning_002 = item_027.var_reg_range;
                                if cached_beginning_002.ending - cached_beginning_002.beginning + 1 == 1 then
                                    cached_beginning_002 = item_027.var_reg_range.beginning;
                                    if table_value_044[cached_beginning_002] then
                                        cached_var_reg_range_003 = helper_function_017(cached_beginning_002, table_value_044[cached_beginning_002]);
                                    else
                                        local range_value_012 = array_value_078[cached_beginning_002];
                                        if not range_value_012 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_beginning_002) .. "]");
                                            range_value_012 = helper_function_014(cached_beginning_002, (conditional_not(true)));
                                        end;
                                        cached_var_reg_range_003 = range_value_012;
                                    end;
                                    if cached_var_reg_range_003 and cached_var_reg_range_003.varname then
                                        range_value_011 = {
                                            cached_var_reg_range_003.varname
                                        };
                                    end;
                                end;
                            end;
                            range_value_011 = range_value_011 or helper_function_028(item_027);
                            if item_027.no_inline then
                                for _, item_028 in ipairs(range_value_011) do
                                    item_028.attributes.no_inline = true;
                                end;
                            end;
                            if item_027.predef then
                                helper_function_019(item_027.var_reg_range, helper_function_014(nil, (conditional_not(true))), range_value_011);
                            else
                                helper_function_020(item_027.var_reg_range, range_value_011);
                            end;
                        else
                            helper_function_012(cached_prefix_warning .. ": Skipped task `" .. item_027.type .. "` above");
                        end;
                    end;
                end;
            end;
            local function helper_function_031()
                local condition_value_022 = table_value_038[local_symbol_024];
                assert(not local_symbol_031);
                local_symbol_031 = true;
                if condition_value_022 then
                    for _, item_029 in ipairs(condition_value_022) do
                        if item_029.type == "defvar" and item_029.predef then
                            helper_function_019(item_029.var_reg_range, helper_function_014(nil, (conditional_not(true))), (helper_function_028(item_029)));
                        else
                            helper_function_012(cached_prefix_warning .. ": Skipped task `" .. item_029.type .. "` above");
                        end;
                    end;
                end;
            end;
            local local_symbol_033 = nil;
            local function _(param_333, param_334, param_335)
                local table_value_053 = {};
                local local_symbol_034;
                if table_value_044[param_333] then
                    local_symbol_034 = helper_function_017(param_333, table_value_044[param_333]);
                else
                    local expression_value_009 = array_value_078[param_333];
                    if not expression_value_009 then
                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_333) .. "]");
                        expression_value_009 = helper_function_014(param_333, (conditional_not(true)));
                    end;
                    local_symbol_034 = expression_value_009;
                end;
                if table_value_030[local_symbol_034] then
                    helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                else
                    table_value_030[local_symbol_034] = true;
                end;
                local cached_local_symbol_003 = local_symbol_034;
                local_symbol_034 = {
                    t = "call",
                    reads = {},
                    writes = {},
                    lines = table_value_022,
                    func = cached_local_symbol_003,
                    args = table_value_053,
                    namecall_method = param_335
                };
                ranges_equal(local_symbol_034, cached_local_symbol_003);
                local local_symbol_035 = param_335 and 2 or 1;
                for index_031 = local_symbol_035, param_334 do
                    local condition_value_023 = param_333 + index_031;
                    local local_symbol_036;
                    if table_value_044[condition_value_023] then
                        local_symbol_036 = helper_function_017(condition_value_023, table_value_044[condition_value_023]);
                    else
                        local expression_value_010 = array_value_078[condition_value_023];
                        if not expression_value_010 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(condition_value_023) .. "]");
                            expression_value_010 = helper_function_014(condition_value_023, (conditional_not(true)));
                        end;
                        local_symbol_036 = expression_value_010;
                    end;
                    if table_value_030[local_symbol_036] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_036] = true;
                    end;
                    local cached_local_symbol_004 = local_symbol_036;
                    table.insert(table_value_053, cached_local_symbol_004);
                    ranges_equal(local_symbol_034, cached_local_symbol_004);
                end;
                table_value_042 = local_symbol_034;
            end;
            helper_function_014 = function(param_336, param_337)
                if param_336 then
                    local condition_value_024 = array_value_078[param_336];
                    if condition_value_024 then
                        table_value_037[condition_value_024] = nil;
                    end;
                    array_value_078[param_336] = param_337;
                    table_value_037[param_337] = param_336;
                end;
                return param_337;
            end;
            local function helper_function_032(param_338)
                return helper_function_014(param_338, {
                    t = "varargs",
                    reads = {},
                    writes = {},
                    contributors = {}
                });
            end;
            local function helper_function_033(param_339, param_340)
                assert(param_340);
                return helper_function_014(param_339, {
                    t = "global",
                    reads = {},
                    writes = {},
                    contributors = {},
                    name = param_340
                });
            end;
            local function helper_function_034(param_341, param_342)
                if not param_342 then
                    error("Bad Konstant");
                end;
                if param_342.type == 3 then
                    local cached_value_002 = param_342.value;
                    if #cached_value_002 > 128 then
                        if table_value_031[cached_value_002] then
                            local cached_table_value_002 = table_value_033;
                            cached_table_value_002[cached_value_002] = cached_table_value_002[cached_value_002] + 1;
                        elseif table_value_034[cached_value_002] then
                            local_symbol_021 = local_symbol_021 + 1;
                            table_value_031[cached_value_002] = "longstring" .. local_symbol_021;
                            table_value_033[cached_value_002] = 2;
                            table.insert(table_value_032, cached_value_002);
                        else
                            table_value_034[cached_value_002] = true;
                        end;
                    end;
                end;
                return helper_function_014(param_341, {
                    t = "constant",
                    reads = {},
                    writes = {},
                    contributors = {},
                    const = param_342
                });
            end;
            local function helper_function_035(param_343)
                return helper_function_014(param_343, {
                    t = "new table",
                    reads = {},
                    writes = {},
                    contributors = {},
                    initializers = {},
                    initializers_order = {}
                });
            end;
            local function helper_function_036(param_344, param_345, param_346, param_347)
                return helper_function_014(param_344, {
                    t = "constant index",
                    reads = table.clone(param_345.reads),
                    writes = table.clone(param_345.writes),
                    contributors = table.clone(param_345.contributors),
                    table = param_345,
                    index = param_346,
                    namecall = param_347
                });
            end;
            helper_function_017 = function(param_348, param_349)
                return helper_function_014(param_348, (helper_function_001(param_349)));
            end;
            local function helper_function_037(param_350, param_351)
                return helper_function_014(param_350, {
                    t = "boolean",
                    reads = {},
                    writes = {},
                    contributors = {},
                    value = param_351
                });
            end;
            local function helper_function_038(param_352, param_353, param_354)
                local cached_helper_function_001 = helper_function_014;
                local cached_param_005 = param_352;
                local table_value_054 = {
                    t = "or",
                    reads = append_array_copy(param_353.reads, param_354.reads),
                    writes = append_array_copy(param_353.writes, param_354.writes)
                };
                local cached_contributors_004 = param_353.contributors;
                local cached_contributors_005 = param_354.contributors;
                local array_value_080 = table.clone(cached_contributors_004);
                for item_030 in pairs(cached_contributors_005) do
                    array_value_080[item_030] = true;
                end;
                table_value_054.contributors = array_value_080;
                table_value_054.precedence = 8;
                table_value_054.lhs = param_353;
                table_value_054.rhs = param_354;
                return cached_helper_function_001(cached_param_005, table_value_054);
            end;
            local function helper_function_039(param_355, param_356, param_357)
                return helper_function_014(param_355, (helper_function_003(param_356, param_357)));
            end;
            local function helper_function_040(param_358, param_359, param_360, param_361)
                return helper_function_014(param_358, (helper_function_004(param_359, param_360, param_361)));
            end;
            local function helper_function_041(param_362, param_363, param_364)
                local cached_helper_function_002 = helper_function_014;
                local cached_param_006 = param_362;
                local table_value_055 = {
                    t = "addition",
                    reads = append_array_copy(param_363.reads, param_364.reads),
                    writes = append_array_copy(param_363.writes, param_364.writes)
                };
                local cached_contributors_006 = param_363.contributors;
                local cached_contributors_007 = param_364.contributors;
                local array_value_081 = table.clone(cached_contributors_006);
                for item_031 in pairs(cached_contributors_007) do
                    array_value_081[item_031] = true;
                end;
                table_value_055.contributors = array_value_081;
                table_value_055.precedence = 4;
                table_value_055.lhs = param_363;
                table_value_055.rhs = param_364;
                return cached_helper_function_002(cached_param_006, table_value_055);
            end;
            local function helper_function_042(param_365, param_366, param_367)
                local cached_helper_function_003 = helper_function_014;
                local cached_param_007 = param_365;
                local table_value_056 = {
                    t = "subtraction",
                    reads = append_array_copy(param_366.reads, param_367.reads),
                    writes = append_array_copy(param_366.writes, param_367.writes)
                };
                local cached_contributors_008 = param_366.contributors;
                local cached_contributors_009 = param_367.contributors;
                local array_value_082 = table.clone(cached_contributors_008);
                for item_032 in pairs(cached_contributors_009) do
                    array_value_082[item_032] = true;
                end;
                table_value_056.contributors = array_value_082;
                table_value_056.precedence = 4;
                table_value_056.lhs = param_366;
                table_value_056.rhs = param_367;
                return cached_helper_function_003(cached_param_007, table_value_056);
            end;
            local function helper_function_043(param_368, param_369, param_370)
                local cached_helper_function_004 = helper_function_014;
                local cached_param_008 = param_368;
                local table_value_057 = {
                    t = "multiplication",
                    reads = append_array_copy(param_369.reads, param_370.reads),
                    writes = append_array_copy(param_369.writes, param_370.writes)
                };
                local cached_contributors_010 = param_369.contributors;
                local cached_contributors_011 = param_370.contributors;
                local array_value_083 = table.clone(cached_contributors_010);
                for item_033 in pairs(cached_contributors_011) do
                    array_value_083[item_033] = true;
                end;
                table_value_057.contributors = array_value_083;
                table_value_057.precedence = 3;
                table_value_057.lhs = param_369;
                table_value_057.rhs = param_370;
                return cached_helper_function_004(cached_param_008, table_value_057);
            end;
            local function helper_function_044(param_371, param_372, param_373)
                local cached_helper_function_005 = helper_function_014;
                local cached_param_009 = param_371;
                local table_value_058 = {
                    t = "division",
                    reads = append_array_copy(param_372.reads, param_373.reads),
                    writes = append_array_copy(param_372.writes, param_373.writes)
                };
                local cached_contributors_012 = param_372.contributors;
                local cached_contributors_013 = param_373.contributors;
                local array_value_084 = table.clone(cached_contributors_012);
                for item_034 in pairs(cached_contributors_013) do
                    array_value_084[item_034] = true;
                end;
                table_value_058.contributors = array_value_084;
                table_value_058.precedence = 3;
                table_value_058.lhs = param_372;
                table_value_058.rhs = param_373;
                return cached_helper_function_005(cached_param_009, table_value_058);
            end;
            local function helper_function_045(param_374, param_375, param_376)
                local cached_helper_function_006 = helper_function_014;
                local cached_param_010 = param_374;
                local table_value_059 = {
                    t = "floor division",
                    reads = append_array_copy(param_375.reads, param_376.reads),
                    writes = append_array_copy(param_375.writes, param_376.writes)
                };
                local cached_contributors_014 = param_375.contributors;
                local cached_contributors_015 = param_376.contributors;
                local array_value_085 = table.clone(cached_contributors_014);
                for item_035 in pairs(cached_contributors_015) do
                    array_value_085[item_035] = true;
                end;
                table_value_059.contributors = array_value_085;
                table_value_059.precedence = 3;
                table_value_059.lhs = param_375;
                table_value_059.rhs = param_376;
                return cached_helper_function_006(cached_param_010, table_value_059);
            end;
            local function helper_function_046(param_377, param_378, param_379)
                local cached_helper_function_007 = helper_function_014;
                local cached_param_011 = param_377;
                local table_value_060 = {
                    t = "modulus",
                    reads = append_array_copy(param_378.reads, param_379.reads),
                    writes = append_array_copy(param_378.writes, param_379.writes)
                };
                local cached_contributors_016 = param_378.contributors;
                local cached_contributors_017 = param_379.contributors;
                local array_value_086 = table.clone(cached_contributors_016);
                for item_036 in pairs(cached_contributors_017) do
                    array_value_086[item_036] = true;
                end;
                table_value_060.contributors = array_value_086;
                table_value_060.precedence = 3;
                table_value_060.lhs = param_378;
                table_value_060.rhs = param_379;
                return cached_helper_function_007(cached_param_011, table_value_060);
            end;
            local function helper_function_047(param_380, param_381)
                return helper_function_014(param_380, (helper_function_002(param_381)));
            end;
            local function helper_function_048(param_382, param_383)
                return helper_function_014(param_382, {
                    t = "negate",
                    reads = table.clone(param_383.reads),
                    writes = table.clone(param_383.writes),
                    contributors = table.clone(param_383.contributors),
                    precedence = 2,
                    rhs = param_383
                });
            end;
            local function helper_function_049(param_384, param_385)
                return helper_function_014(param_384, {
                    t = "length",
                    reads = table.clone(param_385.reads),
                    writes = table.clone(param_385.writes),
                    contributors = table.clone(param_385.contributors),
                    precedence = 2,
                    rhs = param_385
                });
            end;
            local function helper_function_050(param_386, param_387, param_388)
                local cached_helper_function_008 = helper_function_014;
                local cached_param_012 = param_386;
                local table_value_061 = {
                    t = "exponentiation",
                    reads = append_array_copy(param_387.reads, param_388.reads),
                    writes = append_array_copy(param_387.writes, param_388.writes)
                };
                local cached_contributors_018 = param_387.contributors;
                local cached_contributors_019 = param_388.contributors;
                local array_value_087 = table.clone(cached_contributors_018);
                for item_037 in pairs(cached_contributors_019) do
                    array_value_087[item_037] = true;
                end;
                table_value_061.contributors = array_value_087;
                table_value_061.precedence = 1;
                table_value_061.lhs = param_387;
                table_value_061.rhs = param_388;
                return cached_helper_function_008(cached_param_012, table_value_061);
            end;
            local function helper_function_051(param_389, param_390)
                local table_value_062 = {};
                local table_value_063 = {};
                local table_value_064 = {};
                for _, item_038 in ipairs(param_390) do
                    for _, item_039 in ipairs(item_038.reads) do
                        table.insert(table_value_062, item_039);
                    end;
                    for _, item_040 in ipairs(item_038.writes) do
                        table.insert(table_value_063, item_040);
                    end;
                    for item_041 in pairs(item_038.contributors) do
                        table_value_064[item_041] = true;
                    end;
                end;
                return helper_function_014(param_389, {
                    t = "concatenation",
                    reads = table_value_062,
                    writes = table_value_063,
                    contributors = table_value_064,
                    precedence = 0,
                    exprs = param_390
                });
            end;
            local function helper_function_052(param_391, param_392, param_393)
                local cached_helper_function_009 = helper_function_014;
                local cached_param_013 = param_391;
                local table_value_065 = {
                    t = "get table",
                    reads = append_array_copy(param_392.reads, param_393.reads),
                    writes = append_array_copy(param_392.writes, param_393.writes)
                };
                local cached_contributors_020 = param_392.contributors;
                local cached_contributors_021 = param_393.contributors;
                local array_value_088 = table.clone(cached_contributors_020);
                for item_042 in pairs(cached_contributors_021) do
                    array_value_088[item_042] = true;
                end;
                table_value_065.contributors = array_value_088;
                table_value_065.table = param_392;
                table_value_065.index = param_393;
                return cached_helper_function_009(cached_param_013, table_value_065);
            end;
            local function helper_function_053(param_394, param_395)
                local constant_value_049 = bit32.rrotate(bit32.band(param_395, 3221225472), 30);
                local constant_value_050 = cached_constants_001[bit32.rrotate(bit32.band(param_395, 1072693248), 20)];
                if constant_value_049 == 2 then
                    local constant_value_051 = cached_constants_001[bit32.rrotate(bit32.band(param_395, 1047552), 10)];
                    if param_394 then
                        return helper_function_036(param_394, helper_function_033(nil, constant_value_050), constant_value_051);
                    else
                        return helper_function_036(nil, helper_function_033(nil, constant_value_050), constant_value_051);
                    end;
                elseif constant_value_049 == 3 then
                    local constant_value_052 = cached_constants_001[bit32.rrotate(bit32.band(param_395, 1047552), 10)];
                    local constant_value_053 = cached_constants_001[bit32.band(param_395, 1023)];
                    if param_394 then
                        return helper_function_036(param_394, helper_function_036(nil, helper_function_033(nil, constant_value_050), constant_value_052), constant_value_053);
                    else
                        return helper_function_036(nil, helper_function_036(nil, helper_function_033(nil, constant_value_050), constant_value_052), constant_value_053);
                    end;
                elseif param_394 then
                    return helper_function_033(param_394, constant_value_050);
                else
                    return helper_function_033(nil, constant_value_050);
                end;
            end;
            local function helper_function_054(param_396, param_397, _, param_398)
                local table_value_066 = {};
                local local_symbol_037;
                if table_value_044[param_396] then
                    local_symbol_037 = helper_function_017(param_396, table_value_044[param_396]);
                else
                    local expression_value_011 = array_value_078[param_396];
                    if not expression_value_011 then
                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_396) .. "]");
                        expression_value_011 = helper_function_014(param_396, (conditional_not(true)));
                    end;
                    local_symbol_037 = expression_value_011;
                end;
                if table_value_030[local_symbol_037] then
                    helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                else
                    table_value_030[local_symbol_037] = true;
                end;
                local cached_local_symbol_005 = local_symbol_037;
                local_symbol_037 = table.clone(cached_local_symbol_005.reads);
                local _ = table.clone(cached_local_symbol_005.writes);
                local _ = table.clone(cached_local_symbol_005.contributors);
                local array_value_089 = param_398 and 2 or 1;
                for index_032 = array_value_089, param_397 do
                    local condition_value_025 = param_396 + index_032;
                    local local_symbol_038;
                    if table_value_044[condition_value_025] then
                        local_symbol_038 = helper_function_017(condition_value_025, table_value_044[condition_value_025]);
                    else
                        local expression_value_012 = array_value_078[condition_value_025];
                        if not expression_value_012 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(condition_value_025) .. "]");
                            expression_value_012 = helper_function_014(condition_value_025, (conditional_not(true)));
                        end;
                        local_symbol_038 = expression_value_012;
                    end;
                    if table_value_030[local_symbol_038] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_038] = true;
                    end;
                    table.insert(table_value_066, local_symbol_038);
                end;
                local array_value_090 = create_expression(cached_local_symbol_005, table_value_066, param_398 and true or false);
                return helper_function_014(param_396, array_value_090);
            end;
            local table_value_067 = {};
            local function _(param_399)
                table_value_045[param_399] = true;
                table_value_067[param_399] = true;
            end;
            local function _(param_400)
                table_value_045[param_400] = nil;
                table_value_067[param_400] = nil;
            end;
            local function helper_function_055(param_401, param_402)
                local table_value_068 = {};
                local proto_value_007 = nil;
                local proto_value_008 = nil;
                if param_402.debug_name and condition_value_015.use_proto_debugnames then
                    proto_value_007 = param_402.debug_name;
                    proto_value_008 = true;
                else
                    local string_value_031 = "var" .. tostring(string_value_018);
                    local string_value_032 = table_value_024[string_value_031];
                    local cached_string_value_013 = string_value_031;
                    local local_symbol_039 = string_value_032 or 1;
                    while table_value_023[cached_string_value_013] or table_value_018[cached_string_value_013] do
                        local_symbol_039 = local_symbol_039 + 1;
                        cached_string_value_013 = string_value_031 .. "_" .. local_symbol_039;
                    end;
                    table_value_024[string_value_031] = local_symbol_039;
                    local cached_string_value_014 = cached_string_value_013;
                    string_value_018 = string_value_018 + 1;
                    proto_value_007 = cached_string_value_014;
                end;
                local cached_is_point_in_named_range_004 = is_point_in_named_range;
                local cached_proto_value_001 = proto_value_007;
                local local_symbol_040 = table_value_024[cached_proto_value_001];
                local cached_proto_value_002 = cached_proto_value_001;
                local local_symbol_041 = local_symbol_040 or 1;
                while table_value_023[cached_proto_value_002] or table_value_018[cached_proto_value_002] do
                    local_symbol_041 = local_symbol_041 + 1;
                    cached_proto_value_002 = cached_proto_value_001 .. "_" .. local_symbol_041;
                end;
                table_value_024[cached_proto_value_001] = local_symbol_041;
                cached_is_point_in_named_range_004 = cached_is_point_in_named_range_004(cached_proto_value_002, {
                    beginning = param_401,
                    ending = param_401
                }, {});
                local range_value_013 = helper_function_014(param_401, {
                    t = "function",
                    reads = {},
                    writes = {},
                    contributors = table_value_068,
                    varname = cached_is_point_in_named_range_004
                });
                cached_proto_value_001 = table_value_022[#table_value_022];
                helper_function_030(param_401, range_value_013);
                if not table_value_044[param_401] then
                    helper_function_019({
                        beginning = param_401,
                        ending = param_401
                    }, range_value_013, {
                        cached_is_point_in_named_range_004
                    });
                end;
                local_symbol_040 = table_value_022[#table_value_022];
                cached_proto_value_002 = #table_value_022;
                local_symbol_031 = true;
                local_symbol_041 = false;
                local table_value_069 = {};
                for index_033 = local_symbol_025 + 1, #table_value_041 do
                    local opcode_value_009 = table_value_041[index_033];
                    local cached_inst = opcode_value_009.inst;
                    if opcode_value_009.opinfo.opname == "CAPTURE" then
                        local opcode_value_010 = bit32.band(bit32.rshift(cached_inst, 8), 255);
                        if opcode_value_010 == 2 then
                            if param_294 then
                                local instruction_value_019 = param_294.upvalues[bit32.band(bit32.rshift(cached_inst, 16), 255)];
                                assert(instruction_value_019.name.attributes.is_upvalue);
                                table.insert(table_value_069, {
                                    name = instruction_value_019.name,
                                    access = instruction_value_019.access == "readonly" and "copied, readonly" or instruction_value_019.access == "read and write" and "copied, read and write" or instruction_value_019.access
                                });
                            else
                                local number_value_001 = "UNK" .. math.random(1, 1000000000);
                                helper_function_012(cached_prefix_warning .. ": Malformed upref, replacing with `" .. number_value_001 .. "`");
                                table.insert(table_value_069, {
                                    name = is_point_in_named_range(number_value_001, {
                                        beginning = -1,
                                        ending = -1
                                    }, {}),
                                    access = "copied, unknown"
                                });
                            end;
                        elseif not (opcode_value_010 ~= 0) or opcode_value_010 == 1 then
                            local instruction_value_020 = bit32.band(bit32.rshift(cached_inst, 16), 255);
                            if instruction_value_020 == param_401 then
                                local_symbol_041 = true;
                                local condition_value_026;
                                if table_value_044[param_401] then
                                    condition_value_026 = helper_function_017(param_401, table_value_044[param_401]);
                                else
                                    local expression_value_013 = array_value_078[param_401];
                                    if not expression_value_013 then
                                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_401) .. "]");
                                        expression_value_013 = helper_function_014(param_401, (conditional_not(true)));
                                    end;
                                    condition_value_026 = expression_value_013;
                                end;
                                if condition_value_026.t ~= "name" then
                                    local cached_helper_function_010 = helper_function_019;
                                    local table_value_070 = {
                                        beginning = param_401,
                                        ending = param_401
                                    };
                                    local cached_range_value_001 = range_value_013;
                                    local table_value_071 = {};
                                    local table_value_072 = {
                                        beginning = param_401,
                                        ending = param_401
                                    };
                                    local table_value_073 = {};
                                    local cached_is_point_in_named_range_005 = is_point_in_named_range;
                                    local string_value_033 = "var" .. tostring(string_value_018);
                                    local string_value_034 = table_value_024[string_value_033];
                                    local cached_string_value_015 = string_value_033;
                                    local local_symbol_042 = string_value_034 or 1;
                                    while table_value_023[cached_string_value_015] or table_value_018[cached_string_value_015] do
                                        local_symbol_042 = local_symbol_042 + 1;
                                        cached_string_value_015 = string_value_033 .. "_" .. local_symbol_042;
                                    end;
                                    table_value_024[string_value_033] = local_symbol_042;
                                    local cached_string_value_016 = cached_string_value_015;
                                    string_value_018 = string_value_018 + 1;
                                    local local_symbol_043 = cached_is_point_in_named_range_005(cached_string_value_016, table_value_072, table_value_073);
                                    copy_varargs_into_array(table_value_071, 1, local_symbol_043);
                                    cached_helper_function_010(table_value_070, cached_range_value_001, table_value_071);
                                    if table_value_044[param_401] then
                                        condition_value_026 = helper_function_017(param_401, table_value_044[param_401]);
                                    else
                                        table_value_070 = array_value_078[param_401];
                                        if not table_value_070 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_401) .. "]");
                                            table_value_070 = helper_function_014(param_401, (conditional_not(true)));
                                        end;
                                        condition_value_026 = table_value_070;
                                    end;
                                    cached_helper_function_010 = table_value_038[local_symbol_024];
                                    if cached_helper_function_010 then
                                        for _ = #cached_helper_function_010, 1, -1 do
                                            error("message");
                                        end;
                                    end;
                                end;
                                table_value_045[param_401] = true;
                                table_value_067[param_401] = true;
                                local cached_name_006 = condition_value_026.name;
                                if opcode_value_010 == 0 then
                                    if not cached_name_006.attributes.is_upvalue then
                                        cached_name_006.attributes.is_upvalue = "read";
                                    end;
                                    table.insert(table_value_069, {
                                        name = cached_name_006,
                                        access = "readonly"
                                    });
                                else
                                    cached_name_006.attributes.is_upvalue = "write";
                                    table.insert(table_value_069, {
                                        name = cached_name_006,
                                        access = "read and write"
                                    });
                                end;
                            else
                                local local_symbol_044;
                                if table_value_044[instruction_value_020] then
                                    local_symbol_044 = helper_function_017(instruction_value_020, table_value_044[instruction_value_020]);
                                else
                                    local expression_value_014 = array_value_078[instruction_value_020];
                                    if not expression_value_014 then
                                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(instruction_value_020) .. "]");
                                        expression_value_014 = helper_function_014(instruction_value_020, (conditional_not(true)));
                                    end;
                                    local_symbol_044 = expression_value_014;
                                end;
                                if local_symbol_044.t ~= "name" then
                                    local cached_helper_function_011 = helper_function_020;
                                    local table_value_074 = {
                                        beginning = instruction_value_020,
                                        ending = instruction_value_020
                                    };
                                    local table_value_075 = {};
                                    local table_value_076 = {
                                        beginning = instruction_value_020,
                                        ending = instruction_value_020
                                    };
                                    local table_value_077 = {};
                                    local cached_is_point_in_named_range_006 = is_point_in_named_range;
                                    local string_value_035 = "var" .. tostring(string_value_018);
                                    local string_value_036 = table_value_024[string_value_035];
                                    local cached_string_value_017 = string_value_035;
                                    local local_symbol_045 = string_value_036 or 1;
                                    while table_value_023[cached_string_value_017] or table_value_018[cached_string_value_017] do
                                        local_symbol_045 = local_symbol_045 + 1;
                                        cached_string_value_017 = string_value_035 .. "_" .. local_symbol_045;
                                    end;
                                    table_value_024[string_value_035] = local_symbol_045;
                                    local cached_string_value_018 = cached_string_value_017;
                                    string_value_018 = string_value_018 + 1;
                                    local local_symbol_046 = cached_is_point_in_named_range_006(cached_string_value_018, table_value_076, table_value_077);
                                    copy_varargs_into_array(table_value_075, 1, local_symbol_046);
                                    cached_helper_function_011(table_value_074, table_value_075);
                                    if table_value_044[instruction_value_020] then
                                        local_symbol_044 = helper_function_017(instruction_value_020, table_value_044[instruction_value_020]);
                                    else
                                        table_value_074 = array_value_078[instruction_value_020];
                                        if not table_value_074 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(instruction_value_020) .. "]");
                                            table_value_074 = helper_function_014(instruction_value_020, (conditional_not(true)));
                                        end;
                                        local_symbol_044 = table_value_074;
                                    end;
                                end;
                                table_value_045[instruction_value_020] = true;
                                table_value_067[instruction_value_020] = true;
                                if local_symbol_044.name.init_expr then
                                    table_value_068[local_symbol_044.name.init_expr] = true;
                                end;
                                if opcode_value_010 == 0 then
                                    if not local_symbol_044.name.attributes.is_upvalue then
                                        local_symbol_044.name.attributes.is_upvalue = "read";
                                    end;
                                    table.insert(table_value_069, {
                                        name = local_symbol_044.name,
                                        access = "readonly"
                                    });
                                else
                                    local_symbol_044.name.attributes.is_upvalue = "write";
                                    table.insert(table_value_069, {
                                        name = local_symbol_044.name,
                                        access = "read and write"
                                    });
                                end;
                            end;
                        else
                            error((("Unknown LCT %*"):format(opcode_value_010)));
                        end;
                    else
                        local_symbol_025 = index_033 - 1;
                        break;
                    end;
                end;
                if #table_value_069 > 0 then
                    table.move(table_value_069, 1, #table_value_069, 0, table_value_069);
                    table.remove(table_value_069, #table_value_069);
                end;
                if cached_proto_value_001 ~= local_symbol_040 then
                    local cached_table_value_003 = table_value_022;
                    local array_value_091 = table.remove(table_value_022, cached_proto_value_002);
                    assert(array_value_091);
                    table.insert(cached_table_value_003, array_value_091);
                end;
                local cached_table_value_004 = table_value_022;
                table_value_022 = {};
                local table_value_078 = {};
                for index_034 = 0, param_402.params_count - 1 do
                    local cached_is_point_in_named_range_007 = is_point_in_named_range;
                    local cached_name_007 = cached_is_point_in_named_range_004.name;
                    local string_value_037 = "arg" .. tostring(local_symbol_013);
                    if condition_value_015.exact_argument_names then
                        string_value_037 = cached_name_007 .. "_" .. string_value_037;
                    end;
                    local cached_string_value_019 = string_value_037;
                    local local_symbol_047 = table_value_024[cached_string_value_019];
                    local cached_string_value_020 = cached_string_value_019;
                    local local_symbol_048 = local_symbol_047 or 1;
                    while table_value_023[cached_string_value_020] or table_value_018[cached_string_value_020] do
                        local_symbol_048 = local_symbol_048 + 1;
                        cached_string_value_020 = cached_string_value_019 .. "_" .. local_symbol_048;
                    end;
                    table_value_024[cached_string_value_019] = local_symbol_048;
                    string_value_037 = cached_string_value_020;
                    local_symbol_013 = local_symbol_013 + 1;
                    cached_is_point_in_named_range_007 = cached_is_point_in_named_range_007(string_value_037, {
                        beginning = index_034,
                        ending = index_034
                    }, table_value_078);
                    cached_is_point_in_named_range_007.func_name = cached_is_point_in_named_range_004;
                    local _ = cached_is_point_in_named_range_007;
                end;
                local_symbol_013 = 1;
                local cached_helper_function_012 = helper_function_008;
                local table_value_079 = {
                    t = "function",
                    reads = {},
                    writes = {},
                    contributors = table_value_068,
                    is_self_referencing = local_symbol_041,
                    name = proto_value_007,
                    varname = cached_is_point_in_named_range_004,
                    name_known = proto_value_008,
                    args = table_value_078,
                    is_vararg = param_402.is_vararg,
                    line_defined = param_402.line_defined,
                    upvalues_count = param_402.upvalues_count,
                    upvalues = table_value_069,
                    ast = cached_helper_function_012(param_402, {
                        args = table_value_078,
                        upvalues = table_value_069,
                        name = proto_value_007
                    })
                };
                table.clear(range_value_013);
                for local_symbol_049, item_043 in pairs(table_value_079) do
                    range_value_013[local_symbol_049] = item_043;
                end;
                for _, item_044 in ipairs(table_value_078) do
                    local cached_name_008 = item_044.name;
                    if not table_value_023[cached_name_008] then
                        error((("[free] Variable %* not allocated"):format(item_044.name)));
                    end;
                    table_value_023[cached_name_008] = nil;
                end;
                cached_is_point_in_named_range_004.init_expr = range_value_013;
                cached_is_point_in_named_range_004.var_num = 1;
                table_value_022 = cached_table_value_004;
                return range_value_013;
            end;
            if array_value_077 == 0 and not cached_code_001[0] then
                helper_function_012((("%*: Empty proto"):format(cached_prefix_warning)));
                current_function_context = cached_current_function_context;
                return table_value_022;
            else
                if param_294 and param_294.args then
                    for local_symbol_050, item_045 in ipairs(param_294.args) do
                        table_value_044[local_symbol_050 - 1] = item_045;
                    end;
                end;
                local function _(param_403)
                    local condition_value_027 = opcode_def_by_encoded_byte[param_403];
                    if not condition_value_027 then
                        local_symbol_024 = local_symbol_024 + 1;
                        return;
                    elseif condition_value_027.aux then
                        local_symbol_024 = local_symbol_024 + 2;
                        return;
                    else
                        local_symbol_024 = local_symbol_024 + 1;
                        return;
                    end;
                end;
                local function _()
                    local condition_value_028 = cached_code_001[local_symbol_024 + 1];
                    if not condition_value_028 then
                        error("Expected aux");
                    end;
                    return condition_value_028;
                end;
                local function _(param_404)
                    local cached_condition = param_404.condition;
                    assert(cached_condition);
                    param_404.condition = INVERTED_CONDITION_OPERATOR[cached_condition];
                end;
                local function _(param_405)
                    local cached_condition_001 = param_405.condition;
                    local cached_lhs = param_405.lhs;
                    local cached_rhs_001 = param_405.rhs;
                    assert(cached_condition_001);
                    assert(cached_lhs);
                    assert(cached_rhs_001);
                    param_405.lhs = cached_rhs_001;
                    param_405.rhs = cached_lhs;
                    param_405.condition = SWAPPED_CONDITION_OPERATOR[cached_condition_001];
                end;
                local table_value_080 = {};
                local table_value_081 = {};
                local _ = function(param_406, _, param_407)
                    table_value_081[param_406] = param_407;
                end;
                local function helper_function_056(param_408)
                    if param_408.condition then
                        local cached_code_002 = param_408.code;
                        local cached_opname_001 = cached_code_002.opname;
                        if not (cached_opname_001 ~= "JUMPXEQKNIL" and cached_opname_001 ~= "JUMPXEQKB" and cached_opname_001 ~= "JUMPXEQKN") or cached_opname_001 == "JUMPXEQKS" then
                            local cached_rhs_002 = param_408.rhs;
                            assert(cached_rhs_002);
                            return bit32.band(bit32.rshift(cached_code_002.inst, 8), 255), cached_rhs_002;
                        elseif not (cached_opname_001 ~= "JUMPIFEQ" and cached_opname_001 ~= "JUMPIFLE" and cached_opname_001 ~= "JUMPIFLT" and cached_opname_001 ~= "JUMPIFNOTEQ" and cached_opname_001 ~= "JUMPIFNOTLE") or cached_opname_001 == "JUMPIFNOTLT" then
                            local cached_aux = cached_code_002.aux;
                            assert(cached_aux);
                            local _ = param_408.rhs;
                            return bit32.band(bit32.rshift(cached_code_002.inst, 8), 255), cached_aux;
                        elseif not (cached_opname_001 ~= "JUMPIF") or cached_opname_001 == "JUMPIFNOT" then
                            return (bit32.band(bit32.rshift(cached_code_002.inst, 8), 255));
                        elseif not (cached_opname_001 ~= "JUMP" and cached_opname_001 ~= "JUMPBACK") or cached_opname_001 == "JUMPX" then
                            return;
                        else
                            error((("Unknown visitor %*"):format((tostring(cached_opname_001)))));
                            return;
                        end;
                    else
                        return;
                    end;
                end;
                local_symbol_023:end_benchmark("Initialization");
                local_symbol_023:start_benchmark("Initial Processing");
                local array_value_092 = 1;
                local array_value_093 = 0;
                local table_value_082 = {};
                local table_value_083 = {};
                local function _(param_409)
                    table.insert(table_value_041, param_409);
                    table_value_082[param_409.code_index] = param_409.actual_code_index;
                    table_value_083[param_409.index] = param_409.actual_index;
                end;
                while local_symbol_024 <= array_value_077 do
                    local bit_value_151 = cached_code_001[local_symbol_024];
                    local bit_value_152 = bit32.band(bit_value_151, 255);
                    local_symbol_025 = #table_value_041 + 1;
                    local opcode_value_011 = opcode_def_by_encoded_byte[bit_value_152];
                    if not opcode_value_011 then
                        local opcode_value_012 = ("Unknown opcode 0x%* (%* reversed: 0x%*)"):format(HEX_BYTE[bit32.band(bit_value_151, 255)], active_opcode_encoding, HEX_BYTE[decoded_opcode_by_encoded_byte[bit32.band(bit_value_151, 255)]]);
                        failed_instruction_count = failed_instruction_count + 1;
                        error(opcode_value_012);
                        local condition_value_029 = opcode_def_by_encoded_byte[bit_value_152];
                        if not condition_value_029 then
                            local_symbol_024 = local_symbol_024 + 1;
                        elseif condition_value_029.aux then
                            local_symbol_024 = local_symbol_024 + 2;
                        else
                            local_symbol_024 = local_symbol_024 + 1;
                        end;
                    else
                        local cached_opname_002 = opcode_value_011.opname;
                        local table_value_084 = {
                            index = local_symbol_025,
                            code_index = local_symbol_024,
                            actual_index = array_value_092,
                            actual_code_index = array_value_093,
                            opinfo = opcode_value_011,
                            opname = cached_opname_002,
                            opcode = bit_value_152,
                            inst = bit_value_151,
                            aux = if opcode_value_011.aux then cached_code_001[local_symbol_024 + 1] else nil,
                            size = opcode_value_011.aux and 2 or 1
                        };
                        table.insert(table_value_041, table_value_084);
                        table_value_082[table_value_084.code_index] = table_value_084.actual_code_index;
                        table_value_083[table_value_084.index] = table_value_084.actual_index;
                        table_value_039[local_symbol_024] = local_symbol_025;
                        table_value_040[local_symbol_025] = local_symbol_024;
                        if jump_opcode_bytes_set[bit_value_152] then
                            if not (cached_opname_002 ~= "JUMPXEQKNIL" and cached_opname_002 ~= "JUMPXEQKB" and cached_opname_002 ~= "JUMPXEQKN") or cached_opname_002 == "JUMPXEQKS" then
                                buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                local buffer_value_082 = buffer.readi16(scratch_buffer_u64, 0);
                                local buffer_value_083 = cached_code_001[local_symbol_024 + 1];
                                if not buffer_value_083 then
                                    error("Expected aux");
                                end;
                                local cached_buffer_value_012 = buffer_value_083;
                                buffer_value_083 = nil;
                                buffer_value_083 = if cached_opname_002 == "JUMPXEQKNIL" then helper_function_014(nil, (conditional_not(true))) else if cached_opname_002 == "JUMPXEQKB" then helper_function_037(nil, bit32.band(cached_buffer_value_012, 1) > 0) else helper_function_034(nil, cached_constants_001[bit32.band(cached_buffer_value_012, 16777215)]);
                                local constant_value_054 = false;
                                if bit32.band(cached_buffer_value_012, 2147483648) > 0 then
                                    constant_value_054 = true;
                                end;
                                table_value_081[local_symbol_025] = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + buffer_value_082 + 1,
                                    condition = constant_value_054 and "~=" or "==",
                                    lhs = nil,
                                    rhs = buffer_value_083
                                };
                            elseif not (cached_opname_002 ~= "JUMPIFEQ" and cached_opname_002 ~= "JUMPIFLE" and cached_opname_002 ~= "JUMPIFLT" and cached_opname_002 ~= "JUMPIFNOTEQ" and cached_opname_002 ~= "JUMPIFNOTLE") or cached_opname_002 == "JUMPIFNOTLT" then
                                buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                local buffer_value_084 = buffer.readi16(scratch_buffer_u64, 0);
                                local buffer_value_085 = nil;
                                local buffer_value_086 = string.sub(cached_opname_002, #cached_opname_002 - 1, #cached_opname_002);
                                buffer_value_085 = if string.match(cached_opname_002, "NOT") then buffer_value_086 == "EQ" and "~=" or buffer_value_086 == "LE" and ">" or ">=" else buffer_value_086 == "EQ" and "==" or buffer_value_086 == "LE" and "<=" or "<";
                                assert(buffer_value_085, cached_opname_002);
                                table_value_081[local_symbol_025] = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + buffer_value_084 + 1,
                                    condition = buffer_value_085
                                };
                            elseif not (cached_opname_002 ~= "JUMPIF") or cached_opname_002 == "JUMPIFNOT" then
                                buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                table_value_081[local_symbol_025] = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + buffer.readi16(scratch_buffer_u64, 0) + 1,
                                    condition = cached_opname_002 == "JUMPIFNOT" and "not exist" or "exist"
                                };
                            elseif not (cached_opname_002 ~= "JUMP" and cached_opname_002 ~= "JUMPBACK") or cached_opname_002 == "JUMPX" then
                                local opcode_value_013;
                                if cached_opname_002 == "JUMPX" then
                                    opcode_value_013 = bit32.arshift(bit_value_151, 8);
                                else
                                    buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                    opcode_value_013 = buffer.readi16(scratch_buffer_u64, 0);
                                end;
                                table_value_081[local_symbol_025] = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + opcode_value_013 + 1
                                };
                            elseif cached_opname_002 == "FORNLOOP" then
                                local buffer_value_087 = bit32.band(bit32.rshift(bit_value_151, 8), 255);
                                buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                local table_value_085 = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + buffer.readi16(scratch_buffer_u64, 0) + 1
                                };
                                local table_value_086 = {
                                    type = "numeric",
                                    variable_count = 1
                                };
                                local range_value_014 = buffer_value_087 + 2;
                                table_value_086.variables_reg_range = {
                                    beginning = range_value_014,
                                    ending = range_value_014
                                };
                                local table_value_087 = {};
                                local register_value_002 = buffer_value_087 + 2;
                                table_value_087.register_range = if register_value_002 then {
                                    beginning = buffer_value_087,
                                    ending = register_value_002
                                } else {
                                    beginning = buffer_value_087,
                                    ending = buffer_value_087
                                };
                                table_value_087.index_reg = buffer_value_087 + 2;
                                table_value_087.end_reg = buffer_value_087;
                                table_value_087.step_reg = buffer_value_087 + 1;
                                table_value_086.args = table_value_087;
                                table_value_085.for_info = table_value_086;
                                table_value_081[local_symbol_025] = table_value_085;
                            elseif cached_opname_002 == "FORGLOOP" then
                                local buffer_value_088 = bit32.band(bit32.rshift(bit_value_151, 8), 255);
                                buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(bit_value_151, 16), 65535)));
                                local buffer_value_089 = buffer.readi16(scratch_buffer_u64, 0);
                                local buffer_value_090 = cached_code_001[local_symbol_024 + 1];
                                if not buffer_value_090 then
                                    error("Expected aux");
                                end;
                                buffer_value_090 = bit32.band(buffer_value_090, 255);
                                assert(buffer_value_090 > 0);
                                local table_value_088 = {
                                    code = table_value_084,
                                    index = local_symbol_025,
                                    destination = local_symbol_024 + buffer_value_089 + 1
                                };
                                local table_value_089 = {
                                    type = "generic",
                                    variable_count = buffer_value_090
                                };
                                local range_value_015 = buffer_value_088 + 3;
                                local range_value_016 = buffer_value_088 + 2 + buffer_value_090;
                                table_value_089.variables_reg_range = if range_value_016 then {
                                    beginning = range_value_015,
                                    ending = range_value_016
                                } else {
                                    beginning = range_value_015,
                                    ending = range_value_015
                                };
                                local table_value_090 = {};
                                range_value_016 = buffer_value_088 + 2;
                                table_value_090.register_range = if range_value_016 then {
                                    beginning = buffer_value_088,
                                    ending = range_value_016
                                } else {
                                    beginning = buffer_value_088,
                                    ending = buffer_value_088
                                };
                                table_value_090.generator_reg = buffer_value_088;
                                table_value_090.state_reg = buffer_value_088 + 1;
                                table_value_090.index_reg = buffer_value_088 + 2;
                                table_value_089.args = table_value_090;
                                table_value_089.code = table_value_084;
                                table_value_088.for_info = table_value_089;
                                table_value_081[local_symbol_025] = table_value_088;
                            elseif cached_opname_002 == "LOADB" then
                                local opcode_value_014 = bit32.band(bit32.rshift(bit_value_151, 24), 255);
                                if opcode_value_014 ~= 0 then
                                    local table_value_091 = {
                                        index = local_symbol_025,
                                        code_index = local_symbol_024,
                                        actual_index = array_value_092,
                                        actual_code_index = array_value_093
                                    };
                                    local cached_JUMP = opcode_def_by_name.JUMP;
                                    if not cached_JUMP then
                                        error((("Unknown opname %*"):format("JUMP")));
                                    end;
                                    table_value_091.opinfo = cached_JUMP;
                                    table_value_091.opname = "JUMP";
                                    local cached_JUMP_001 = opcode_def_by_name.JUMP;
                                    if not cached_JUMP_001 then
                                        error((("Unknown opname %*"):format("JUMP")));
                                    end;
                                    table_value_091.opcode = cached_JUMP_001.opcode;
                                    local cached_JUMP_002 = opcode_def_by_name.JUMP;
                                    if not cached_JUMP_002 then
                                        error((("Unknown opname %*"):format("JUMP")));
                                    end;
                                    table_value_091.inst = bit32.bor(cached_JUMP_002.opcode, (bit32.lshift(opcode_value_014, 16)));
                                    table_value_091.size = 1;
                                    table.insert(table_value_041, table_value_091);
                                    local_symbol_025 = local_symbol_025 + 1;
                                    table_value_040[local_symbol_025] = local_symbol_024;
                                    table_value_081[local_symbol_025] = {
                                        code = table_value_091,
                                        index = local_symbol_025,
                                        destination = local_symbol_024 + opcode_value_014 + 1
                                    };
                                end;
                            end;
                        end;
                        array_value_092 = array_value_092 + 1;
                        array_value_093 = array_value_093 + table_value_084.size;
                        local condition_value_030 = opcode_def_by_encoded_byte[bit_value_152];
                        if not condition_value_030 then
                            local_symbol_024 = local_symbol_024 + 1;
                        elseif condition_value_030.aux then
                            local_symbol_024 = local_symbol_024 + 2;
                        else
                            local_symbol_024 = local_symbol_024 + 1;
                        end;
                    end;
                end;
                local_symbol_023:end_benchmark("Initial Processing");
                local_symbol_023:start_benchmark("Initial Labeling");
                for _, item_046 in pairs(table_value_081) do
                    table_value_026[item_046.code.code_index] = reverse_array_in_place();
                    assert(item_046.destination);
                    item_046.destination = table_value_039[item_046.destination];
                    assert(item_046.destination, "Broken control flow");
                    local array_value_094 = table_value_080[item_046.destination];
                    if array_value_094 then
                        table.insert(array_value_094, item_046);
                    else
                        table_value_080[item_046.destination] = {
                            item_046
                        };
                    end;
                end;
                local_symbol_023:end_benchmark("Initial Labeling");
                local_symbol_023:start_benchmark("Block Loading");
                local_symbol_025 = 0;
                local_symbol_024 = 0;
                local table_value_092 = {};
                local table_value_093 = {};
                local local_symbol_051 = false;
                local helper_function_057 = {};
                local helper_function_058 = {};
                local helper_function_059 = 1;
                for condition_value_031, item_047 in ipairs(table_value_041) do
                    local condition_value_032 = table_value_081[condition_value_031];
                    if condition_value_032 then
                        if helper_function_058[1] and helper_function_058[1] == item_047 then
                            table.remove(helper_function_058, 1);
                            error("Shouldn't happen");
                        end;
                        local condition_value_033 = table_value_080[condition_value_031];
                        if condition_value_033 and helper_function_059 ~= condition_value_031 then
                            assert(#condition_value_033 > 0);
                            assert(helper_function_059 < condition_value_031);
                            table.insert(helper_function_057, {
                                insts = helper_function_058,
                                index = helper_function_059
                            });
                            table.insert(helper_function_057, {
                                insts = {},
                                index = condition_value_031,
                                visitor = condition_value_032
                            });
                        else
                            table.insert(helper_function_057, {
                                insts = helper_function_058,
                                index = helper_function_059,
                                visitor = condition_value_032
                            });
                        end;
                        helper_function_059 = condition_value_031 + 1;
                        helper_function_058 = {};
                    elseif table_value_080[condition_value_031] then
                        local array_value_095 = false;
                        if #helper_function_058 == 0 then
                            array_value_095 = true;
                            table.insert(helper_function_058, item_047);
                        end;
                        table.insert(helper_function_057, {
                            insts = helper_function_058,
                            index = helper_function_059
                        });
                        if helper_function_059 == condition_value_031 then
                            if array_value_095 then
                                helper_function_059 = condition_value_031 + 1;
                                helper_function_058 = {};
                            else
                                helper_function_059 = condition_value_031 + 1;
                                helper_function_058 = {
                                    item_047
                                };
                            end;
                        else
                            helper_function_059 = condition_value_031;
                            helper_function_058 = {
                                item_047
                            };
                        end;
                    else
                        table.insert(helper_function_058, item_047);
                    end;
                end;
                if helper_function_059 <= #table_value_041 then
                    table.insert(helper_function_057, {
                        insts = helper_function_058,
                        index = helper_function_059
                    });
                end;
                local table_value_094 = {};
                local table_value_095 = {};
                local table_value_096 = {};
                for _, item_048 in ipairs(helper_function_057) do
                    local cached_visitor = item_048.visitor;
                    local local_symbol_052 = nil;
                    if cached_visitor then
                        local_symbol_052 = cached_visitor.condition;
                        table_value_096[item_048] = cached_visitor.destination;
                    end;
                    local table_value_097 = {
                        insts = item_048.insts,
                        index = item_048.index,
                        visitor = cached_visitor,
                        children = {}
                    };
                    table_value_094[item_048.index] = table_value_097;
                    table.insert(table_value_095, table_value_097);
                end;
                for array_value_096, item_049 in ipairs(helper_function_057) do
                    local condition_value_034 = table_value_096[item_049];
                    if condition_value_034 then
                        assert(item_049.visitor);
                        local local_symbol_053 = table_value_094[condition_value_034];
                        assert(local_symbol_053);
                        local array_value_097 = table_value_094[item_049.index];
                        local cached_children = array_value_097.children;
                        table.insert(cached_children, local_symbol_053);
                        if item_049.visitor.condition then
                            local condition_value_035 = helper_function_057[array_value_096 + 1];
                            if condition_value_035 then
                                local array_value_098 = table_value_094[condition_value_035.index];
                                if array_value_098 ~= array_value_097 and array_value_098 ~= local_symbol_053 then
                                    table.insert(cached_children, array_value_098);
                                end;
                            end;
                        end;
                    else
                        local array_value_099 = helper_function_057[array_value_096 + 1];
                        if array_value_099 then
                            table.insert(table_value_094[item_049.index].children, table_value_094[array_value_099.index]);
                        end;
                    end;
                end;
                local helper_function_060 = {};
                local array_value_100 = table.clone(table_value_043);
                local array_value_101 = table.clone(table_value_043);
                local table_value_098 = {};
                local function helper_function_061()

                end;
                local cached_table_value_005 = table_value_098 ;
                local function helper_function_062(param_410)
                    local cached_type_002 = param_410.type;
                    if cached_type_002 == "ifthen" then
                        if table_value_043[param_410.data.pass].jump then
                            cached_table_value_005[param_410] = true;
                            return;
                        end;
                    elseif cached_type_002 == "ifthenelse" then
                        local cached_else = param_410.data.else_;
                        assert(cached_else);
                        if table_value_043[cached_else].jump then
                            cached_table_value_005[param_410] = true;
                            return;
                        end;
                    end;
                    cached_table_value_005[param_410] = nil;
                end;
                local function helper_function_063(param_411, param_412)
                    if table_value_092[param_412.index] then
                        local array_value_102 = table_value_093[param_412.index];
                        if array_value_102 then
                            if not table.find(array_value_102, param_411) then
                                table.insert(array_value_102, param_411);
                                return;
                            else
                                error("TEMPORARY thing");
                                return;
                            end;
                        else
                            table_value_093[param_412.index] = {
                                param_411
                            };
                        end;
                    end;
                end;
                local cached_array_value_001 = array_value_100 ;
                local cached_helper_function_013 = helper_function_060 ;
                local cached_helper_function_014 = helper_function_063 ;
                local function helper_function_064(param_413, param_414)
                    table.insert(table_value_043, param_413);
                    table.insert(cached_array_value_001, param_413);
                    if param_413.index > 0 then
                        cached_helper_function_013[param_413.index] = param_413;
                    end;
                    if param_414 then
                        for _, item_050 in ipairs(param_414) do
                            cached_helper_function_014(param_413, item_050);
                        end;
                    end;
                end;
                local cached_helper_function_015 = helper_function_061 ;
                local function helper_function_065(param_415, param_416)
                    local cached_hl_index = param_415.hl_index;
                    assert(cached_hl_index == param_416.hl_index);
                    local cached_index = param_415.index;
                    assert(cached_index == param_416.index);
                    table_value_043[cached_hl_index] = param_416;
                    cached_array_value_001[cached_hl_index] = param_416;
                    if cached_index > 0 then
                        assert(cached_helper_function_013[cached_index]);
                        cached_helper_function_013[cached_index] = param_416;
                    end;
                    cached_helper_function_015();
                end;
                for _, item_051 in ipairs(table_value_095) do
                    assert(item_051.index == table_value_094[item_051.index].index);
                    local cached_insts = table_value_094[item_051.index].insts;
                    local table_value_099 = {
                        code_index = table_value_040[item_051.index],
                        index = item_051.index,
                        actual_code_index = table_value_082[table_value_040[item_051.index]],
                        actual_index = table_value_083[item_051.index],
                        hl_index = #table_value_043 + 1,
                        length = if item_051.visitor then #cached_insts + 1 else #cached_insts,
                        type = "single",
                        data = cached_insts,
                        parents = {},
                        children = {},
                        jumped_to_by = {},
                        _visitor = item_051.visitor
                    };
                    helper_function_064(table_value_099);
                    table.insert(array_value_101, table_value_099);
                    table_value_092[item_051.index] = table_value_099;
                end;
                local cached_helper_function_016 = helper_function_064 ;
                local function helper_function_066()
                    local table_value_100 = {
                        code_index = 0,
                        index = 0,
                        actual_code_index = 0,
                        actual_index = 0,
                        hl_index = #table_value_043 + 1,
                        length = 0,
                        type = "single",
                        data = {},
                        parents = {},
                        children = {},
                        jumped_to_by = {}
                    };
                    cached_helper_function_016(table_value_100);
                    return table_value_100;
                end;
                local function helper_function_067(param_417, param_418)
                    assert(not param_417.jump);
                    param_417.jump = {
                        type = "goto",
                        destination = param_418
                    };
                    local array_value_103 = table_value_043[param_418];
                    assert(array_value_103);
                    table.insert(table_value_092[array_value_103.index].jumped_to_by, param_417.hl_index);
                end;
                local function helper_function_068(param_419)
                    local cached_jump = param_419.jump;
                    assert(cached_jump);
                    local local_symbol_054 = table_value_043[cached_jump.destination];
                    assert(local_symbol_054);
                    local cached_hl_index_001 = param_419.hl_index;
                    local cached_jumped_to_by = table_value_092[local_symbol_054.index].jumped_to_by;
                    local local_symbol_055 = table.find(cached_jumped_to_by, cached_hl_index_001);
                    assert(local_symbol_055);
                    table.remove(cached_jumped_to_by, local_symbol_055);
                end;
                local function helper_function_069(param_420)
                    local cached_jump_001 = param_420.jump;
                    assert(cached_jump_001);
                    local local_symbol_056 = table_value_043[cached_jump_001.destination];
                    assert(local_symbol_056);
                    local cached_hl_index_002 = param_420.hl_index;
                    local cached_jumped_to_by_001 = table_value_092[local_symbol_056.index].jumped_to_by;
                    local local_symbol_057 = table.find(cached_jumped_to_by_001, cached_hl_index_002);
                    assert(local_symbol_057);
                    table.remove(cached_jumped_to_by_001, local_symbol_057);
                    param_420.jump = nil;
                end;
                local function helper_function_070(param_421, param_422)
                    local cached_jump_002 = param_421.jump;
                    assert(cached_jump_002);
                    local local_symbol_058 = table_value_043[cached_jump_002.destination];
                    assert(local_symbol_058);
                    local cached_hl_index_003 = param_421.hl_index;
                    local cached_jumped_to_by_002 = table_value_092[local_symbol_058.index].jumped_to_by;
                    local local_symbol_059 = table.find(cached_jumped_to_by_002, cached_hl_index_003);
                    assert(local_symbol_059);
                    table.remove(cached_jumped_to_by_002, local_symbol_059);
                    param_421.jump = nil;
                    assert(not param_421.jump);
                    param_421.jump = {
                        type = "goto",
                        destination = param_422
                    };
                    cached_jump_002 = table_value_043[param_422];
                    assert(cached_jump_002);
                    table.insert(table_value_092[cached_jump_002.index].jumped_to_by, param_421.hl_index);
                end;
                local cached_helper_function_017 = helper_function_066 ;
                local function helper_function_071(param_423)
                    local local_symbol_060 = cached_helper_function_017();
                    assert(not local_symbol_060.jump);
                    local_symbol_060.jump = {
                        type = "goto",
                        destination = param_423
                    };
                    local array_value_104 = table_value_043[param_423];
                    assert(array_value_104);
                    table.insert(table_value_092[array_value_104.index].jumped_to_by, local_symbol_060.hl_index);
                    return local_symbol_060;
                end;
                local function helper_function_072()
                    local local_symbol_061 = cached_helper_function_017();
                    local_symbol_061.jump = {
                        type = "break",
                        destination = 0
                    };
                    return local_symbol_061;
                end;
                local function helper_function_073(param_424, param_425)
                    if table.find(param_424.children, param_425.hl_index) then
                        return true;
                    else
                        return false;
                    end;
                end;
                local function helper_function_074(param_426, param_427)
                    if table.find(param_426.children, param_427.hl_index) and true or false then
                        if not (param_427.index == param_426.index + param_426.length) or param_427.index == 0 then
                            return true;
                        else
                            local l__visitor_0 = param_426._visitor;
                            if l__visitor_0 and l__visitor_0.condition then
                                return true;
                            end;
                        end;
                    end;
                end;
                local function helper_function_075(param_428, param_429)
                    assert(param_428);
                    assert(param_429);
                    assert(not table.find(table_value_043[param_429.hl_index].parents, param_428.hl_index));
                    assert(not table.find(table_value_043[param_428.hl_index].children, param_429.hl_index));
                    table.insert(param_428.children, param_429.hl_index);
                    table.insert(param_429.parents, param_428.hl_index);
                end;
                local function helper_function_076(param_430, param_431)
                    assert(param_430);
                    assert(param_431);
                    local local_symbol_062 = table.find(param_430.children, param_431.hl_index);
                    assert(local_symbol_062);
                    local local_symbol_063 = table.find(param_431.parents, param_430.hl_index);
                    assert(local_symbol_063);
                    table.remove(param_430.children, local_symbol_062);
                    table.remove(param_431.parents, local_symbol_063);
                end;
                local cached_helper_function_018 = helper_function_076 ;
                local function helper_function_077(param_432)
                    for _, item_052 in ipairs(table.clone(param_432.children)) do
                        cached_helper_function_018(param_432, table_value_043[item_052]);
                    end;
                end;
                local function helper_function_078(param_433)
                    for _, item_053 in ipairs(table.clone(param_433.parents)) do
                        cached_helper_function_018(table_value_043[item_053], param_433);
                    end;
                end;
                local cached_helper_function_019 = helper_function_078 ;
                local cached_helper_function_020 = helper_function_077 ;
                local function helper_function_079(param_434)
                    cached_helper_function_019(param_434);
                    cached_helper_function_020(param_434);
                end;
                local function helper_function_080(param_435, param_436, param_437)
                    assert(param_435);
                    assert(param_436);
                    assert(param_437);
                    local local_symbol_064 = table.find(param_435.children, param_436.hl_index);
                    assert(local_symbol_064);
                    local local_symbol_065 = table.find(param_436.parents, param_435.hl_index);
                    assert(local_symbol_065);
                    assert(not table.find(param_437.parents, param_435.hl_index));
                    table.remove(param_436.parents, local_symbol_065);
                    table.insert(param_437.parents, param_435.hl_index);
                    param_435.children[local_symbol_064] = param_437.hl_index;
                end;
                local function helper_function_081(param_438, param_439, param_440)
                    assert(param_438);
                    assert(param_439);
                    assert(param_440);
                    local local_symbol_066 = table.find(param_438.parents, param_439.hl_index);
                    assert(local_symbol_066);
                    local local_symbol_067 = table.find(param_439.children, param_438.hl_index);
                    assert(local_symbol_067);
                    assert(not table.find(param_440.children, param_438.hl_index));
                    table.remove(param_439.children, local_symbol_067);
                    table.insert(param_440.children, param_438.hl_index);
                    param_438.parents[local_symbol_066] = param_440.hl_index;
                end;
                local cached_helper_function_021 = helper_function_060 ;
                local function helper_function_082(param_441, param_442)
                    local l__visitor_1 = param_441._visitor;
                    if l__visitor_1 and l__visitor_1.destination then
                        assert(table.find(param_441.children, cached_helper_function_021[l__visitor_1.destination].hl_index));
                    end;
                    if param_442 then
                        local array_value_105 = table.create(#param_441.children);
                        for _, item_054 in ipairs(param_441.children) do
                            if table_value_043[item_054].index > param_441.index then
                                table.insert(array_value_105, item_054);
                            end;
                        end;
                        return array_value_105;
                    else
                        return (table.clone(param_441.children));
                    end;
                end;
                local cached_helper_function_022 = helper_function_082 ;
                local function helper_function_083(param_443)
                    local array_value_106 = cached_helper_function_022(param_443);
                    if param_443.type == "ifthen" then
                        table.insert(array_value_106, param_443.data.pass);
                        return array_value_106;
                    elseif param_443.type == "ifthenelse" then
                        table.insert(array_value_106, param_443.data.pass);
                        table.insert(array_value_106, param_443.data.else_);
                        return array_value_106;
                    elseif param_443.type == "oneblockwhile" then
                        table.insert(array_value_106, param_443.data.code);
                        return array_value_106;
                    else
                        if param_443.type == "sequential" then
                            for _, item_055 in ipairs(param_443.data) do
                                table.insert(array_value_106, item_055);
                            end;
                        end;
                        return array_value_106;
                    end;
                end;
                local function helper_function_084(param_444, param_445, param_446, param_447)
                    if param_444 == param_445 then
                        return true;
                    else
                        param_446 = param_446 or {};
                        assert(param_446);
                        for _, item_056 in ipairs((cached_helper_function_022(param_444, param_447))) do
                            if not param_446[item_056] then
                                param_446[item_056] = true;
                                if table.find(param_445.parents, item_056) then
                                    return true;
                                else
                                    return helper_function_084(table_value_043[item_056], param_445, param_446);
                                end;
                            end;
                        end;
                        return false;
                    end;
                end;
                local cached_helper_function_023 = helper_function_083 ;
                local function helper_function_085(param_448, param_449, param_450)
                    if param_448 == param_449 then
                        return true;
                    else
                        param_450 = param_450 or {};
                        assert(param_450);
                        for _, item_057 in ipairs((cached_helper_function_023(param_448))) do
                            if not param_450[item_057] then
                                param_450[item_057] = true;
                                if table.find(param_449.parents, item_057) then
                                    return true;
                                else
                                    return helper_function_085(table_value_043[item_057], param_449, param_450);
                                end;
                            end;
                        end;
                        return false;
                    end;
                end;
                local cached_helper_function_024 = helper_function_080 ;
                local function helper_function_086(param_451, param_452)
                    assert(param_451 ~= param_452);
                    assert(param_451.hl_index ~= param_452.hl_index);
                    local array_value_107 = table.clone(param_451.parents);
                    for item_058 in ipairs(array_value_107) do
                        local array_value_108 = array_value_107[item_058];
                        cached_helper_function_024(table_value_043[array_value_108], param_451, param_452);
                    end;
                end;
                local cached_helper_function_025 = helper_function_081 ;
                local function helper_function_087(param_453, param_454)
                    assert(param_453 ~= param_454);
                    assert(param_453.hl_index ~= param_454.hl_index);
                    local array_value_109 = table.clone(param_453.children);
                    for _, item_059 in ipairs(array_value_109) do
                        cached_helper_function_025(table_value_043[item_059], param_453, param_454);
                    end;
                end;
                local cached_helper_function_026 = helper_function_086 ;
                local cached_helper_function_027 = helper_function_087 ;
                local function helper_function_088(param_455, param_456)
                    cached_helper_function_026(param_455, param_456);
                    cached_helper_function_027(param_455, param_456);
                end;
                for _, item_060 in ipairs(table_value_095) do
                    local local_symbol_068 = helper_function_060[item_060.index];
                    assert(item_060);
                    for _, item_061 in ipairs(item_060.children) do
                        helper_function_075(local_symbol_068, helper_function_060[item_061.index]);
                    end;
                    table.clear(item_060.children);
                end;
                local function helper_function_089(param_457, param_458, param_459, param_460, param_461)
                    return {
                        is_full_condition_t = true,
                        type = param_457,
                        condition = param_458,
                        lhs = param_459,
                        rhs = param_460,
                        code = param_461
                    };
                end;
                local function helper_function_090(param_462, param_463, param_464)
                    return {
                        is_full_condition_t = true,
                        type = "and",
                        condition = param_464 and "not exist" or "exist",
                        lhs = param_462,
                        rhs = param_463,
                        code = nil
                    };
                end;
                local function helper_function_091(param_465, param_466, param_467)
                    return {
                        is_full_condition_t = true,
                        type = "or",
                        condition = param_467 and "not exist" or "exist",
                        lhs = param_465,
                        rhs = param_466,
                        code = nil
                    };
                end;
                local function helper_function_092(param_468, param_469)
                    local local_symbol_069 = false;
                    local local_symbol_070 = false;
                    local local_symbol_071 = nil;
                    for _, item_062 in ipairs(param_468.parents) do
                        if table.find(param_469.parents, item_062) then
                            local condition_value_036 = table_value_043[item_062];
                            local condition_value_037;
                            if table.find(condition_value_036.children, param_469.hl_index) and true or false then
                                if not (param_469.index == condition_value_036.index + condition_value_036.length) or param_469.index == 0 then
                                    condition_value_037 = true;
                                    local_symbol_069 = true;
                                else
                                    local l__visitor_2 = condition_value_036._visitor;
                                    if l__visitor_2 and l__visitor_2.condition then
                                        condition_value_037 = true;
                                        local_symbol_069 = true;
                                    end;
                                end;
                            end;
                            if not local_symbol_069 then
                                if not local_symbol_069 then
                                    condition_value_037 = nil;
                                end;
                            end;
                            local_symbol_069 = false;
                            if condition_value_037 then
                                if local_symbol_071 then
                                    if table_value_043[item_062].index > table_value_043[local_symbol_071].index then
                                        local_symbol_071 = item_062;
                                    end;
                                else
                                    local_symbol_071 = item_062;
                                end;
                            end;
                        end;
                    end;
                    local local_symbol_072 = nil;
                    if local_symbol_071 then
                        local_symbol_072 = false;
                    else
                        local_symbol_072 = true;
                        for _, item_063 in ipairs(param_469.parents) do
                            if table.find(param_468.parents, item_063) then
                                local condition_value_038 = table_value_043[item_063];
                                local condition_value_039;
                                if table.find(condition_value_038.children, param_468.hl_index) and true or false then
                                    if not (param_468.index == condition_value_038.index + condition_value_038.length) or param_468.index == 0 then
                                        condition_value_039 = true;
                                        local_symbol_070 = true;
                                    else
                                        local l__visitor_3 = condition_value_038._visitor;
                                        if l__visitor_3 and l__visitor_3.condition then
                                            condition_value_039 = true;
                                            local_symbol_070 = true;
                                        end;
                                    end;
                                end;
                                if not local_symbol_070 then
                                    if not local_symbol_070 then
                                        condition_value_039 = nil;
                                    end;
                                end;
                                local_symbol_070 = false;
                                if condition_value_039 then
                                    assert(not local_symbol_071);
                                    local_symbol_071 = item_063;
                                end;
                            end;
                        end;
                    end;
                    return table_value_043[local_symbol_071], local_symbol_072;
                end;
                local cached_helper_function_028 = helper_function_061 ;
                local cached_helper_function_029 = helper_function_092 ;
                local cached_helper_function_030 = helper_function_076 ;
                local function helper_function_093(param_470, param_471, param_472)
                    local local_symbol_073 = false;
                    cached_helper_function_028();
                    local local_symbol_074, local_symbol_075 = cached_helper_function_029(param_470, param_471);
                    assert(local_symbol_074);
                    local table_value_101 = {
                        local_symbol_074
                    };
                    local local_symbol_076 = nil;
                    local local_symbol_077 = table_value_101[#table_value_101];
                    local local_symbol_078 = 0;
                    local table_value_102 = {};
                    while true do
                        if table_value_036[local_symbol_074.index] then
                            local_symbol_077 = table_value_101[#table_value_101];
                            break;
                        elseif #local_symbol_074.parents ~= 1 then
                            local_symbol_077 = table_value_101[#table_value_101];
                            if #local_symbol_074.parents ~= 0 then
                                local condition_value_040 = table_value_101[#table_value_101];
                                if cached_helper_function_029(condition_value_040, param_470) then
                                    local local_symbol_079, local_symbol_080, local_symbol_081, local_symbol_082 = helper_function_093(condition_value_040, param_470, true);
                                    local_symbol_076 = local_symbol_079;
                                    local_symbol_077 = local_symbol_080;
                                    local_symbol_078 = local_symbol_078 + local_symbol_082;
                                    for item_064 in pairs(local_symbol_081) do
                                        table_value_102[item_064] = true;
                                    end;
                                    break;
                                elseif cached_helper_function_029(condition_value_040, param_471) then
                                    local local_symbol_083, local_symbol_084, local_symbol_085, local_symbol_086 = helper_function_093(condition_value_040, param_471);
                                    local_symbol_076 = local_symbol_083;
                                    local_symbol_077 = local_symbol_084;
                                    local_symbol_078 = local_symbol_078 + local_symbol_086;
                                    for item_065 in pairs(local_symbol_085) do
                                        table_value_102[item_065] = true;
                                    end;
                                    break;
                                else
                                    break;
                                end;
                            else
                                break;
                            end;
                        else
                            local condition_value_041 = table_value_043[local_symbol_074.parents[1]];
                            if #condition_value_041.children < 2 then
                                local_symbol_077 = table_value_101[#table_value_101];
                                break;
                            else
                                local condition_value_042 = condition_value_041.children[1];
                                if condition_value_042 ~= param_470.hl_index and condition_value_042 ~= param_471.hl_index then
                                    local_symbol_077 = table_value_101[#table_value_101];
                                    break;
                                else
                                    local_symbol_074 = condition_value_041;
                                    table.insert(table_value_101, local_symbol_074);
                                    table_value_102[local_symbol_074] = true;
                                end;
                            end;
                        end;
                    end;
                    local local_symbol_087 = nil;
                    local local_symbol_088 = nil;
                    for local_symbol_089, item_066 in ipairs(table_value_101) do
                        assert(item_066._visitor);
                        assert(item_066._visitor.condition);
                        local condition_value_043;
                        if table.find(item_066.children, param_471.hl_index) and true or false then
                            if not (param_471.index == item_066.index + item_066.length) or param_471.index == 0 then
                                condition_value_043 = true;
                                local_symbol_073 = true;
                            else
                                local l__visitor_4 = item_066._visitor;
                                if l__visitor_4 and l__visitor_4.condition then
                                    condition_value_043 = true;
                                    local_symbol_073 = true;
                                end;
                            end;
                        end;
                        if not local_symbol_073 then
                            if not local_symbol_073 then
                                condition_value_043 = nil;
                            end;
                        end;
                        local_symbol_073 = false;
                        local condition_value_044 = nil;
                        condition_value_044 = not condition_value_043 and local_symbol_089 == 1;
                        if param_472 then
                            condition_value_043 = not condition_value_043;
                        end;
                        if local_symbol_075 and local_symbol_089 == 1 then
                            condition_value_044 = not condition_value_044;
                        end;
                        local condition_value_045, local_symbol_090 = helper_function_056(item_066._visitor);
                        if condition_value_044 or condition_value_043 then
                            local l__visitor_5 = item_066._visitor;
                            local cached_condition_002 = l__visitor_5.condition;
                            assert(cached_condition_002);
                            l__visitor_5.condition = INVERTED_CONDITION_OPERATOR[cached_condition_002];
                        end;
                        if local_symbol_087 then
                            local table_value_103 = {
                                is_full_condition_t = true,
                                type = "reg",
                                condition = item_066._visitor.condition,
                                lhs = condition_value_045,
                                rhs = local_symbol_090,
                                code = item_066.hl_index
                            };
                            if condition_value_043 then
                                local_symbol_087 = {
                                    is_full_condition_t = true,
                                    type = "and",
                                    condition = condition_value_044 and "not exist" or "exist",
                                    lhs = table_value_103,
                                    rhs = local_symbol_087,
                                    code = nil
                                };
                            else
                                local_symbol_087 = {
                                    is_full_condition_t = true,
                                    type = "or",
                                    condition = condition_value_044 and "not exist" or "exist",
                                    lhs = table_value_103,
                                    rhs = local_symbol_087,
                                    code = nil
                                };
                            end;
                        else
                            local_symbol_087 = {
                                is_full_condition_t = true,
                                type = "reg",
                                condition = item_066._visitor.condition,
                                lhs = condition_value_045,
                                rhs = local_symbol_090,
                                code = item_066.hl_index
                            };
                        end;
                        local_symbol_078 = local_symbol_078 + item_066.length;
                        if local_symbol_088 then
                            cached_helper_function_030(item_066, local_symbol_088);
                            cached_helper_function_030(item_066, table_value_043[item_066.children[1]]);
                        end;
                        local_symbol_088 = item_066;
                    end;
                    if local_symbol_076 then
                        local_symbol_087 = {
                            is_full_condition_t = true,
                            type = "or",
                            condition = "exist",
                            lhs = local_symbol_076,
                            rhs = local_symbol_087,
                            code = nil
                        };
                    end;
                    local condition_value_046 = table_value_101[1];
                    cached_helper_function_030(condition_value_046, param_470);
                    if param_470.hl_index ~= param_471.hl_index then
                        cached_helper_function_030(condition_value_046, param_471);
                    end;
                    cached_helper_function_028();
                    return local_symbol_087, local_symbol_077, table_value_102, local_symbol_078;
                end;
                local local_symbol_091 = false;
                local_symbol_023:end_benchmark("Block Loading");
                local_symbol_023:start_benchmark("Control Flow Analysis");
                local function helper_function_094(param_473, param_474, param_475)
                    local cached_jump_003 = param_473.jump;
                    if cached_jump_003 then
                        local cached_index_001 = table_value_043[cached_jump_003.destination].index;
                        if param_474[cached_index_001] then
                            cached_jump_003.type = "break";
                            local cached_jump_004 = param_473.jump;
                            assert(cached_jump_004);
                            local local_symbol_092 = table_value_043[cached_jump_004.destination];
                            assert(local_symbol_092);
                            local cached_hl_index_004 = param_473.hl_index;
                            local cached_jumped_to_by_003 = table_value_092[local_symbol_092.index].jumped_to_by;
                            local local_symbol_093 = table.find(cached_jumped_to_by_003, cached_hl_index_004);
                            assert(local_symbol_093);
                            table.remove(cached_jumped_to_by_003, local_symbol_093);
                        elseif param_475[cached_index_001] then
                            cached_jump_003.type = "continue";
                            local cached_jump_005 = param_473.jump;
                            assert(cached_jump_005);
                            local local_symbol_094 = table_value_043[cached_jump_005.destination];
                            assert(local_symbol_094);
                            local cached_hl_index_005 = param_473.hl_index;
                            local cached_jumped_to_by_004 = table_value_092[local_symbol_094.index].jumped_to_by;
                            local local_symbol_095 = table.find(cached_jumped_to_by_004, cached_hl_index_005);
                            assert(local_symbol_095);
                            table.remove(cached_jumped_to_by_004, local_symbol_095);
                        end;
                    end;
                    local cached_type_003 = param_473.type;
                    if cached_type_003 == "sequential" then
                        for _, item_067 in ipairs(param_473.data) do
                            helper_function_094(table_value_043[item_067], param_474, param_475);
                        end;
                        return;
                    else
                        if not (cached_type_003 ~= "ifthen") or cached_type_003 == "ifthenelse" then
                            local cached_data = param_473.data;
                            helper_function_094(table_value_043[cached_data.pass], param_474, param_475);
                            local cached_else_001 = cached_data.else_;
                            if cached_else_001 then
                                helper_function_094(table_value_043[cached_else_001], param_474, param_475);
                            end;
                        end;
                        return;
                    end;
                end;
                local helper_function_095 = nil;
                local cached_array_value_002 = array_value_100 ;
                local cached_table_value_006 = table_value_098 ;
                local cached_helper_function_031 = helper_function_063 ;
                local cached_helper_function_032 = helper_function_087 ;
                local cached_helper_function_033 = helper_function_064 ;
                local cached_helper_function_034 = helper_function_086 ;
                do
                    local cached_helper_function_035 = helper_function_095;
                    local function helper_function_096()
                        local local_symbol_096 = false;
                        while true do
                            local local_symbol_097 = 0;
                            for index_035 = #cached_array_value_002, 1, -1 do
                                local condition_value_047 = table_value_043[index_035];
                                if #condition_value_047.children == 1 then
                                    local condition_value_048 = table_value_043[condition_value_047.children[1]];
                                    if condition_value_048 ~= condition_value_047 and not (table.find(condition_value_048.children, condition_value_048.hl_index) and true or false) and #condition_value_048.parents <= 1 and #condition_value_048.jumped_to_by <= 0 and condition_value_048.index >= condition_value_047.index then
                                        local condition_value_049 = if condition_value_047.type == "sequential" then table_value_043[condition_value_047.data[#condition_value_047.data]] else condition_value_047;
                                        if cached_table_value_006[condition_value_049] then
                                            local cached_data_001 = condition_value_049.data;
                                            local condition_value_050 = table_value_043[cached_data_001.pass];
                                            if condition_value_050 then
                                                local cached_jump_006 = condition_value_050.jump;
                                                assert(cached_jump_006);
                                                if not (not (cached_jump_006.type == "goto") or condition_value_050.index == 0) then
                                                    continue;
                                                end;
                                            end;
                                            if cached_data_001.else_ and table_value_043[cached_data_001.else_] then
                                                error("IDK");
                                            end;
                                        end;
                                        if table.find(condition_value_047.children, condition_value_048.hl_index) and true or false then
                                            if not (condition_value_048.index == condition_value_047.index + condition_value_047.length) or condition_value_048.index == 0 then
                                                condition_value_049 = true;
                                                local_symbol_096 = true;
                                            else
                                                local l__visitor_6 = condition_value_047._visitor;
                                                if l__visitor_6 and l__visitor_6.condition then
                                                    condition_value_049 = true;
                                                    local_symbol_096 = true;
                                                end;
                                            end;
                                        end;
                                        if not local_symbol_096 then
                                            if not local_symbol_096 then
                                                condition_value_049 = nil;
                                            end;
                                        end;
                                        local_symbol_096 = false;
                                        if condition_value_049 then

                                        end;
                                        assert(table.find(condition_value_048.parents, condition_value_047.hl_index));
                                        if condition_value_047.type == "sequential" then
                                            if not condition_value_047._visitor or not condition_value_047._visitor.condition then
                                                cached_helper_function_035 = cached_helper_function_035 + 1;
                                                local_symbol_097 = local_symbol_097 + 1;
                                                table.insert(condition_value_047.data, condition_value_048.hl_index);
                                                condition_value_047.length = condition_value_047.length + condition_value_048.length;
                                                cached_helper_function_031(condition_value_047, condition_value_048);
                                                cached_helper_function_030(condition_value_047, condition_value_048);
                                                cached_helper_function_032(condition_value_048, condition_value_047);
                                                condition_value_047._visitor = condition_value_048._visitor;
                                            else
                                                continue;
                                            end;
                                        elseif not condition_value_047._visitor or not condition_value_047._visitor.condition then
                                            cached_helper_function_035 = cached_helper_function_035 + 1;
                                            local_symbol_097 = local_symbol_097 + 1;
                                            condition_value_049 = #table_value_043 + 1;
                                            local table_value_104 = {
                                                code_index = table_value_040[condition_value_047.index],
                                                index = condition_value_047.index,
                                                actual_code_index = table_value_082[table_value_040[condition_value_047.index]],
                                                actual_index = table_value_083[condition_value_047.index],
                                                hl_index = condition_value_049,
                                                length = condition_value_047.length + condition_value_048.length,
                                                type = "sequential",
                                                data = {
                                                    condition_value_047.hl_index,
                                                    condition_value_048.hl_index
                                                },
                                                parents = {},
                                                children = {},
                                                jumped_to_by = {},
                                                _visitor = condition_value_048._visitor
                                            };
                                            cached_helper_function_033(table_value_104, {
                                                condition_value_047,
                                                condition_value_048
                                            });
                                            cached_helper_function_034(condition_value_047, table_value_104);
                                            cached_helper_function_030(condition_value_047, condition_value_048);
                                            cached_helper_function_032(condition_value_048, table_value_104);
                                        else
                                            continue;
                                        end;
                                        cached_helper_function_028();
                                    end;
                                end;
                            end;
                            if not (local_symbol_097 ~= 0) then
                                break;
                            end;
                        end;
                    end;
                    while true do
                        cached_helper_function_035 = 0;
                        helper_function_061();
                        for index_036 = #array_value_100, 1, -1 do
                            local condition_value_051 = table_value_043[index_036];
                            if not (#condition_value_051.children ~= 1) or #condition_value_051.children == 2 then
                                local condition_value_052 = false;
                                local l__visitor_7 = condition_value_051._visitor;
                                if l__visitor_7 and l__visitor_7.condition then
                                    assert(helper_function_074(condition_value_051, table_value_043[condition_value_051.children[1]]));
                                    local condition_value_053 = condition_value_051.children[1];
                                    assert(condition_value_053);
                                    if #table_value_043[condition_value_053].children <= 1 then
                                        local local_symbol_098 = condition_value_051.children[2];
                                        local local_symbol_099 = nil;
                                        local local_symbol_100 = nil;
                                        local local_symbol_101 = nil;
                                        if local_symbol_098 then
                                            assert(local_symbol_098);
                                            assert(condition_value_053 ~= local_symbol_098);
                                            if #table_value_043[local_symbol_098].children <= 1 then
                                                local cached_children_001 = table_value_043[condition_value_053].children;
                                                if #cached_children_001 <= 1 then
                                                    local _ = cached_children_001[1];
                                                    local local_symbol_102 = table_value_043[local_symbol_098].children[1];
                                                    local condition_value_054 = local_symbol_102 and helper_function_074(table_value_043[local_symbol_098], table_value_043[local_symbol_102]);
                                                    if condition_value_054 then
                                                        if local_symbol_091 then
                                                            local_symbol_101 = table_value_043[local_symbol_102];
                                                        else
                                                            continue;
                                                        end;
                                                    end;
                                                    local_symbol_099 = table_value_043[condition_value_053];
                                                    local_symbol_100 = table_value_043[local_symbol_098];
                                                    if local_symbol_099 ~= condition_value_051 then
                                                        if condition_value_054 then
                                                            if not (#local_symbol_099.parents >= 1) then
                                                                continue;
                                                            end;
                                                        elseif not (#local_symbol_099.parents >= 2) then
                                                            continue;
                                                        end;
                                                        if not local_symbol_100 or not local_symbol_099 then
                                                            error("Shouldn't happen...");
                                                        end;
                                                        if condition_value_054 or helper_function_073(local_symbol_100, local_symbol_099) then
                                                            local condition_value_055 = helper_function_060[local_symbol_100.index + local_symbol_100.length];
                                                            if condition_value_054 and condition_value_055 and condition_value_055 == local_symbol_099 then
                                                                assert(local_symbol_101);
                                                                if local_symbol_101.index <= local_symbol_099.index and not helper_function_084(local_symbol_099, local_symbol_100, {}, true) then
                                                                    local_symbol_101 = table_value_043[local_symbol_099.hl_index];
                                                                    local cached_local_symbol_006 = local_symbol_099;
                                                                    local_symbol_099 = local_symbol_100;
                                                                    local cached_local_symbol_007 = local_symbol_100;
                                                                    local_symbol_100 = helper_function_066();
                                                                    helper_function_080(condition_value_051, cached_local_symbol_007, local_symbol_100);
                                                                    helper_function_080(condition_value_051, cached_local_symbol_006, local_symbol_099);
                                                                    assert(local_symbol_101);
                                                                    helper_function_075(local_symbol_100, local_symbol_101);
                                                                end;
                                                            end;
                                                        else
                                                            continue;
                                                        end;
                                                    else
                                                        continue;
                                                    end;
                                                else
                                                    continue;
                                                end;
                                            else
                                                continue;
                                            end;
                                        else
                                            local_symbol_099 = table_value_043[condition_value_053];
                                            local_symbol_100 = helper_function_066();
                                            helper_function_075(local_symbol_100, local_symbol_099);
                                            condition_value_052 = true;
                                        end;
                                        local condition_value_056, condition_value_057, condition_value_058, condition_value_059 = helper_function_093(if condition_value_052 then local_symbol_099 else local_symbol_100, local_symbol_099, local_symbol_100.index == 0);
                                        local table_value_105 = {
                                            code_index = condition_value_057.code_index,
                                            index = condition_value_057.index,
                                            actual_code_index = condition_value_057.actual_code_index,
                                            actual_index = condition_value_057.actual_index,
                                            hl_index = #table_value_043 + 1,
                                            length = condition_value_059 + local_symbol_100.length,
                                            type = "ifthen",
                                            data = {
                                                pass = local_symbol_100.hl_index,
                                                condition = condition_value_056,
                                                condition_length = condition_value_059
                                            },
                                            parents = {},
                                            children = {},
                                            jumped_to_by = {}
                                        };
                                        local table_value_106 = {
                                            local_symbol_100
                                        };
                                        for item_068 in pairs(condition_value_058) do
                                            table.insert(table_value_106, item_068);
                                        end;
                                        helper_function_064(table_value_105, table_value_106);
                                        if local_symbol_101 then
                                            helper_function_076(local_symbol_100, local_symbol_101);
                                            helper_function_067(local_symbol_100, local_symbol_101.hl_index);
                                        else
                                            helper_function_076(local_symbol_100, local_symbol_099);
                                        end;
                                        helper_function_086(condition_value_057, table_value_105);
                                        helper_function_075(table_value_105, local_symbol_099);
                                        if helper_function_073(local_symbol_100, local_symbol_099) then
                                            helper_function_076(condition_value_051, local_symbol_100);
                                        end;
                                        helper_function_062(table_value_105);
                                        helper_function_061();
                                    end;
                                end;
                            end;
                        end;
                        for item_069 in pairs(table.clone(table_value_098)) do
                            if #item_069.children == 1 then
                                helper_function_061();
                                local condition_value_060 = table_value_043[item_069.children[1]];
                                if condition_value_060 and #condition_value_060.children == 1 then
                                    local cached_data_002 = item_069.data;
                                    local condition_value_061 = table_value_043[cached_data_002.pass];
                                    assert(condition_value_061.jump);
                                    local local_symbol_103 = table_value_043[condition_value_061.jump.destination];
                                    assert(local_symbol_103);
                                    local condition_value_062 = table_value_043[condition_value_060.children[1]];
                                    if local_symbol_103.hl_index == condition_value_062.hl_index then
                                        cached_helper_function_035 = cached_helper_function_035 + 1;
                                        helper_function_061();
                                        cached_data_002.else_ = condition_value_060.hl_index;
                                        item_069.type = "ifthenelse";
                                        item_069.length = item_069.length + condition_value_060.length;
                                        helper_function_069(condition_value_061);
                                        table_value_098[item_069] = nil;
                                        helper_function_075(item_069, local_symbol_103);
                                        helper_function_076(item_069, condition_value_060);
                                        helper_function_076(condition_value_060, local_symbol_103);
                                        helper_function_062(item_069);
                                        helper_function_061();
                                    end;
                                end;
                            end;
                        end;
                        while true do
                            local condition_value_063 = 0;
                            for index_037 = #array_value_100, 1, -1 do
                                local condition_value_064 = table_value_043[index_037];
                                if #condition_value_064.children == 1 then
                                    local l__visitor_8 = condition_value_064._visitor;
                                    if (not l__visitor_8 or not l__visitor_8.condition) and condition_value_064.children[1] == condition_value_064.hl_index and l__visitor_8 then
                                        assert(l__visitor_8);
                                        cached_helper_function_035 = cached_helper_function_035 + 1;
                                        condition_value_063 = condition_value_063 + 1;
                                        local table_value_107 = {
                                            code_index = condition_value_064.code_index,
                                            index = condition_value_064.index,
                                            actual_code_index = condition_value_064.actual_code_index,
                                            actual_index = condition_value_064.actual_index,
                                            hl_index = #table_value_043 + 1,
                                            length = condition_value_064.length,
                                            type = "oneblockwhile",
                                            data = {
                                                code = condition_value_064.hl_index,
                                                for_info = l__visitor_8.for_info
                                            },
                                            parents = {},
                                            children = {},
                                            jumped_to_by = {},
                                            _visitor = condition_value_064._visitor
                                        };
                                        helper_function_064(table_value_107, {
                                            condition_value_064
                                        });
                                        helper_function_088(condition_value_064, table_value_107);
                                        helper_function_076(table_value_107, table_value_107);
                                        local condition_value_065 = helper_function_060[table_value_107.index + table_value_107.length];
                                        local table_value_108 = {};
                                        if condition_value_065 then
                                            helper_function_075(table_value_107, condition_value_065);
                                            table_value_108[condition_value_065.index] = true;
                                        end;
                                        helper_function_094(condition_value_064, table_value_108, {
                                            [table_value_107.index] = true,
                                            [table_value_107.index + table_value_107.length - 1] = true
                                        });
                                    end;
                                end;
                            end;
                            if not (condition_value_063 ~= 0) then
                                break;
                            end;
                        end;
                        helper_function_096();
                        if not (cached_helper_function_035 == 0) then
                            local_symbol_091 = false;
                            continue;
                        end;
                        if not local_symbol_091 then
                            local_symbol_091 = true;
                        else
                            break;
                        end;
                    end;
                    local_symbol_023:end_benchmark("Control Flow Analysis");
                    local_symbol_023:start_benchmark("Control Flow Recovery");
                    cached_helper_function_035 = 0;
                    while true do
                        cached_helper_function_035 = 0;
                        for _, item_070 in ipairs(array_value_100) do
                            if #item_070.parents > 0 then
                                local array_value_110 = table.clone(item_070.parents);
                                table.insert(array_value_110, item_070.hl_index);
                                local _ = item_070.index;
                                local cached_length = item_070.length;
                                local cached_index_002 = item_070.index;
                                for _, item_071 in ipairs(item_070.parents) do
                                    local condition_value_066 = table_value_043[item_071];
                                    if #condition_value_066.parents <= 0 and #condition_value_066.children == 1 then
                                        assert(condition_value_066.children[1] == item_070.hl_index);
                                        cached_length = cached_length + condition_value_066.length;
                                        if condition_value_066.index < cached_index_002 and condition_value_066.index > 0 then
                                            cached_index_002 = condition_value_066.index;
                                        end;
                                        condition_value_066.analysis_failed = true;
                                    else
                                        break;
                                    end;
                                end;
                                for _, item_072 in ipairs(table.clone(item_070.parents)) do
                                    helper_function_076(table_value_043[item_072], item_070);
                                end;
                                helper_function_064({
                                    code_index = table_value_040[cached_index_002],
                                    index = cached_index_002,
                                    actual_code_index = table_value_082[table_value_040[cached_index_002]],
                                    actual_index = table_value_083[cached_index_002],
                                    hl_index = #table_value_043 + 1,
                                    length = cached_length,
                                    type = "sequential",
                                    data = array_value_110,
                                    parents = {},
                                    children = item_070.children,
                                    jumped_to_by = {}
                                });
                                item_070.analysis_failed = true;
                                helper_function_078(item_070);
                                cached_helper_function_035 = cached_helper_function_035 + 1;
                                local_symbol_051 = true;
                            end;
                        end;
                        if not (cached_helper_function_035 ~= 0) then
                            break;
                        end;
                    end;
                    helper_function_061();
                end;
                local_symbol_023:end_benchmark("Control Flow Recovery");
                local_symbol_023:start_benchmark("Stack Incantation");
                helper_function_057 = function()
                    for index_038 = #table_value_043, 1, -1 do
                        local condition_value_067 = table_value_043[index_038];
                        if condition_value_067.index == 1 then
                            if #table_value_043 > 1 then

                            end;
                            return condition_value_067;
                        end;
                    end;
                    error("Critical control flow failure: Failed to find entry point");
                end;
                helper_function_058 = function(param_476, param_477)
                    assert(param_477 < param_476.depth);
                    local cached_param_014 = param_476;
                    while cached_param_014.depth ~= param_477 do
                        cached_param_014 = cached_param_014.parent;
                        assert(cached_param_014);
                    end;
                    return cached_param_014;
                end;
                helper_function_059 = function(param_478, param_479)
                    if param_478.depth < param_479.depth then
                        return false;
                    else
                        local cached_param_015 = param_478;
                        while true do
                            if cached_param_015.depth ~= param_479.depth then
                                cached_param_015 = cached_param_015.parent;
                                if not cached_param_015 then
                                    return false;
                                end;
                            else
                                return cached_param_015.hl_index == param_479.hl_index;
                            end;
                        end;
                    end;
                end;
                table_value_094 = {};
                table_value_095 = {};
                table_value_096 = {};
                helper_function_060 = function(param_480, param_481)
                    local condition_value_068 = nil;
                    local cached_depth = param_480.depth;
                    local cached_depth_001 = param_481.depth;
                    if cached_depth == cached_depth_001 then
                        condition_value_068 = cached_depth;
                    elseif cached_depth < cached_depth_001 then
                        condition_value_068 = cached_depth;
                        local cached_param_016 = param_481;
                        local cached_condition_value_002 = condition_value_068;
                        assert(cached_condition_value_002 < cached_param_016.depth);
                        local cached_param_017 = cached_param_016;
                        while cached_param_017.depth ~= cached_condition_value_002 do
                            cached_param_017 = cached_param_017.parent;
                            assert(cached_param_017);
                        end;
                        param_481 = cached_param_017;
                    else
                        condition_value_068 = cached_depth_001;
                        local cached_param_018 = param_480;
                        local cached_condition_value_003 = condition_value_068;
                        assert(cached_condition_value_003 < cached_param_018.depth);
                        local cached_param_019 = cached_param_018;
                        while cached_param_019.depth ~= cached_condition_value_003 do
                            cached_param_019 = cached_param_019.parent;
                            assert(cached_param_019);
                        end;
                        param_480 = cached_param_019;
                    end;
                    assert(param_480.depth == param_481.depth);
                    while param_480.hl_index ~= param_481.hl_index do
                        param_480 = param_480.parent;
                        assert(param_480);
                        param_481 = param_481.parent;
                        assert(param_481);
                    end;
                    return param_480;
                end;
                array_value_100 = {};
                array_value_101 = {};
                table_value_098 = 0;
                helper_function_061 = {};
                helper_function_062 = function(param_482, param_483, param_484)
                    local cached_reg_reads_global = param_482.reg_reads_global;
                    local cached_reg_writes_global = param_482.reg_writes_global;
                    local local_symbol_104 = nil;
                    local local_symbol_105 = nil;
                    local condition_value_069 = cached_reg_reads_global[param_483];
                    local local_symbol_106;
                    if condition_value_069 then
                        local_symbol_106 = condition_value_069;
                    else
                        local table_value_109 = {};
                        cached_reg_reads_global[param_483] = table_value_109;
                        local_symbol_106 = table_value_109;
                    end;
                    if #local_symbol_106 > 0 then
                        for index_039 = #local_symbol_106, 1, -1 do
                            local condition_value_070 = local_symbol_106[index_039];
                            if condition_value_070.location.depth <= param_484 then
                                local_symbol_104 = condition_value_070;
                                break;
                            end;
                        end;
                    end;
                    local condition_value_071 = cached_reg_writes_global[param_483];
                    if condition_value_071 then
                        condition_value_069 = condition_value_071;
                    else
                        local table_value_110 = {};
                        cached_reg_writes_global[param_483] = table_value_110;
                        condition_value_069 = table_value_110;
                    end;
                    if #condition_value_069 > 0 then
                        for index_040 = #condition_value_069, 1, -1 do
                            local condition_value_072 = condition_value_069[index_040];
                            if condition_value_072.location.depth <= param_484 then
                                return local_symbol_104, condition_value_072;
                            end;
                        end;
                    end;
                    return local_symbol_104, local_symbol_105;
                end;
                helper_function_063 = function(param_485, param_486, _)
                    local condition_value_073, condition_value_074 = helper_function_062(param_485, param_486, proto_value_006);
                    local local_symbol_107 = if condition_value_073 then condition_value_073.code.index else -1;
                    if condition_value_074 then
                        return local_symbol_107, condition_value_074.code.index;
                    else
                        return local_symbol_107, -1;
                    end;
                end;
                helper_function_064 = function(param_487)
                    return param_487.index + param_487.length;
                end;
                helper_function_065 = function(param_488)
                    if param_488._visitor then
                        return param_488.index + param_488.length - 2;
                    else
                        return param_488.index + param_488.length - 1;
                    end;
                end;
                helper_function_066 = function(param_489, param_490, param_491)
                    local table_value_111 = {
                        hl_index = param_489.location.hl_index,
                        start_code = param_490,
                        register = param_491
                    };
                    if param_489.neglected[param_491] then

                    end;
                    local cached_neglected = param_489.neglected;
                    local condition_value_075 = cached_neglected[param_491];
                    local local_symbol_108;
                    if condition_value_075 then
                        local_symbol_108 = condition_value_075;
                    else
                        local table_value_112 = {};
                        cached_neglected[param_491] = table_value_112;
                        local_symbol_108 = table_value_112;
                    end;
                    table.insert(local_symbol_108, table_value_111);
                end;
                helper_function_067 = function(param_492, _, param_493)
                    local condition_value_076 = param_492.neglected[param_493];
                    if condition_value_076 then
                        for _ = #condition_value_076, 1, -1 do

                        end;
                    end;
                end;
                helper_function_068 = function(param_494, param_495)
                    local cached_type_004 = param_494.type;
                    if cached_type_004 == "single" then
                        local condition_value_077 = array_value_100[param_494.hl_index];
                        assert(condition_value_077);
                        local cached_reg_writes = condition_value_077.reg_writes;
                        for index_041 = param_495.beginning, param_495.ending do
                            if cached_reg_writes[index_041] then
                                return true;
                            end;
                        end;
                        return false;
                    elseif cached_type_004 == "sequential" then
                        for _, item_073 in ipairs(param_494.data) do
                            if helper_function_068(table_value_043[item_073], param_495) then
                                return true;
                            end;
                        end;
                        return false;
                    elseif cached_type_004 == "ifthen" then
                        assert(not param_494.data.else_);
                        return false;
                    elseif cached_type_004 == "ifthenelse" then
                        local cached_data_003 = param_494.data;
                        local cached_else_002 = cached_data_003.else_;
                        assert(cached_else_002);
                        return helper_function_068(table_value_043[cached_data_003.pass], param_495) and helper_function_068(table_value_043[cached_else_002], param_495);
                    elseif cached_type_004 == "oneblockwhile" then
                        local cached_data_004 = param_494.data;
                        return helper_function_068(table_value_043[cached_data_004.code], param_495);
                    else
                        error((("Unknown hl_block type %*"):format(cached_type_004)));
                        return;
                    end;
                end;
                helper_function_069 = function(param_496, param_497, param_498, param_499)
                    local local_symbol_109 = nil;
                    local local_symbol_110 = nil;
                    local local_symbol_111 = nil;
                    local local_symbol_112 = nil;
                    if param_498 then
                        assert(param_499);
                        local_symbol_112 = param_498;
                    else
                        assert(not param_499);
                        local _, register_value_003 = helper_function_062(param_496, param_497.register_range.beginning, param_496.location.depth);
                        local_symbol_112 = register_value_003;
                    end;
                    local opcode_value_015 = not local_symbol_112;
                    if not opcode_value_015 then
                        assert(local_symbol_112);
                        if local_symbol_112.code.opname == "NAMECALL" then
                            opcode_value_015 = true;
                        else
                            local cached_location_001 = local_symbol_112.location;
                            local cached_location_002 = param_497.location;
                            if cached_location_002.depth <= cached_location_001.depth then
                                opcode_value_015 = true;
                            else
                                while cached_location_002.depth ~= cached_location_001.depth + 1 do
                                    cached_location_002 = cached_location_002.parent;
                                    assert(cached_location_002);
                                end;
                                assert(cached_location_002.parent);
                                if table_value_043[(if param_499 then cached_location_002.parent.parent else cached_location_002.parent).hl_index].index ~= table_value_043[cached_location_001.hl_index].index then
                                    opcode_value_015 = true;
                                else
                                    local condition_value_078 = table_value_094[cached_location_002.hl_index];
                                    if condition_value_078 then
                                        local _ = condition_value_078;
                                    end;
                                    local_symbol_111 = local_symbol_112.location;
                                    local_symbol_110 = local_symbol_112.code.index;
                                end;
                            end;
                        end;
                    end;
                    if opcode_value_015 then
                        local cached_location_003 = param_496.location;
                        local cached_location_004 = param_497.location;
                        local_symbol_111 = helper_function_060(cached_location_003, cached_location_004);
                        local condition_value_079 = table_value_092[table_value_043[local_symbol_111.hl_index].index];
                        local_symbol_110 = if condition_value_079._visitor then condition_value_079.index + condition_value_079.length - 2 else condition_value_079.index + condition_value_079.length - 1;
                        local_symbol_109 = true;
                    end;
                    assert(local_symbol_110);
                    table.insert(param_496.observations, {
                        type = "scoped variable",
                        info = {
                            wanted_definition_point = local_symbol_110,
                            definition_location = local_symbol_111,
                            is_predefinition = local_symbol_109,
                            register_range = param_497.register_range
                        },
                        location = param_496.location
                    });
                end;
                helper_function_070 = function(param_500, param_501, param_502, param_503, param_504, param_505)
                    local table_value_113 = {
                        type = "define variable",
                        info = {
                            register_range = param_501,
                            definition_location = param_503,
                            is_predefinition = param_504,
                            no_definition = param_505,
                            start_of_use = param_502
                        }
                    };
                    local condition_value_080 = param_500[param_502];
                    if condition_value_080 then
                        local register_value_004 = false;
                        for _, item_074 in ipairs(condition_value_080) do
                            local cached_beginning_003 = param_501.beginning;
                            local cached_register_range = item_074.info.register_range;
                            local cached_beginning_004 = cached_register_range.beginning;
                            local cached_ending_002 = cached_register_range.ending;
                            local register_value_005 = false;
                            if cached_beginning_004 <= cached_beginning_003 then
                                register_value_005 = cached_beginning_003 <= cached_ending_002;
                            end;
                            if register_value_005 then
                                assert(not register_value_004);
                                item_074.info.definition_location = param_503;
                                register_value_004 = true;
                                error("messasdasdasdasdasdasdasdasdasdasdage");
                            end;
                        end;
                        if not register_value_004 then
                            table.insert(condition_value_080, table_value_113);
                            return;
                        end;
                    else
                        param_500[param_502] = {
                            table_value_113
                        };
                    end;
                end;
                helper_function_071 = function(param_506, param_507, param_508, param_509)
                    local table_value_114 = {
                        hl_index = param_506,
                        depth = if param_508 then param_507.depth + 1 else param_507.depth,
                        parent = if param_508 then param_507 else param_507.parent,
                        last_loop = param_507.last_loop
                    };
                    if param_509 then
                        table_value_114.last_loop = table_value_114;
                    end;
                    return table_value_114;
                end;
                helper_function_072 = function(param_510, param_511, param_512, param_513, param_514, param_515)
                    table_value_098 = table_value_098 + 1;
                    param_510.preprocess_task_index = table_value_098;
                    helper_function_061[table_value_098] = param_511;
                    local table_value_115 = {
                        type = param_512,
                        var_reg_range = param_513,
                        predef = param_514,
                        no_inline = param_515
                    };
                    local condition_value_081 = table_value_038[param_511];
                    if condition_value_081 then
                        for _, item_075 in ipairs(condition_value_081) do
                            if item_075.type == param_512 then
                                local cached_beginning_005 = param_513.beginning;
                                local cached_var_reg_range_004 = item_075.var_reg_range;
                                local cached_beginning_006 = cached_var_reg_range_004.beginning;
                                local cached_ending_003 = cached_var_reg_range_004.ending;
                                local range_value_017 = false;
                                if cached_beginning_006 <= cached_beginning_005 then
                                    range_value_017 = cached_beginning_005 <= cached_ending_003;
                                end;
                                if range_value_017 then
                                    return item_075;
                                end;
                            end;
                        end;
                        table.insert(condition_value_081, table_value_115);
                        return table_value_115;
                    else
                        table_value_038[param_511] = {
                            table_value_115
                        };
                        return table_value_115;
                    end;
                end;
                helper_function_073 = function(param_516, param_517, param_518)
                    helper_function_072(param_516, param_518, "lockvar", param_517);
                end;
                helper_function_074 = function(param_519, param_520, param_521)
                    helper_function_072(param_519, param_521, "unlockvar", param_520);
                end;
                helper_function_075 = function(param_522, param_523, param_524, _)
                    local cached_register_range_001 = param_523.register_range;
                    for index_042 = cached_register_range_001.beginning, cached_register_range_001.ending do
                        local array_value_111 = param_522.reg_forced_var[index_042];
                        if array_value_111 then
                            table.insert(array_value_111, param_523);
                        else
                            param_522.reg_forced_var[index_042] = {
                                param_523
                            };
                        end;
                        param_522.reg_has_var[index_042] = cached_register_range_001;
                    end;
                    helper_function_072(param_522, param_524, "lockvar", cached_register_range_001);
                end;
                helper_function_076 = function(param_525, param_526, param_527)
                    local register_value_006 = param_525.reg_forced_var[param_526];
                    if register_value_006 then
                        for index_043 = #register_value_006, 1, -1 do
                            local register_value_007 = register_value_006[index_043];
                            local cached_register_range_002 = register_value_007.register_range;
                            local cached_beginning_007 = cached_register_range_002.beginning;
                            local cached_ending_004 = cached_register_range_002.ending;
                            local register_value_008 = false;
                            if cached_beginning_007 <= param_526 then
                                register_value_008 = param_526 <= cached_ending_004;
                            end;
                            if register_value_008 then
                                if not (param_525.location.depth <= register_value_007.definition_location.depth) or param_525.location.hl_index == register_value_007.definition_location.hl_index then
                                    return register_value_007;
                                else
                                    register_value_008 = register_value_007.register_range;
                                    helper_function_072(param_525, param_527, "unlockvar", register_value_008);
                                    register_value_006[index_043] = nil;
                                end;
                            end;
                        end;
                        if #register_value_006 == 0 then
                            param_525.reg_forced_var[param_526] = nil;
                        end;
                    end;
                    return nil;
                end;
                helper_function_077 = function(param_528, param_529, param_530, param_531, param_532)
                    if param_531 then
                        assert(param_530);
                        helper_function_072(param_528, param_530, "defvar", param_529, true, param_532);
                    elseif param_530 then
                        helper_function_072(param_528, param_530, "defvar", param_529, nil, param_532);
                    else
                        local range_value_018 = param_528.reg_writes_global[param_529.beginning];
                        local range_value_019 = range_value_018[#range_value_018];
                        helper_function_072(param_528, range_value_019.code.code_index, "defvar", param_529, nil, param_532);
                    end;
                    for index_044 = param_529.beginning, param_529.ending do
                        param_528.reg_has_var[index_044] = param_529;
                    end;
                end;
                helper_function_078 = function(param_533, param_534)
                    local range_value_020 = param_533.reg_has_var[param_534];
                    for index_045 = range_value_020.beginning, range_value_020.ending do
                        param_533.reg_has_var[index_045] = nil;
                    end;
                end;
                helper_function_079 = function(param_535, param_536, param_537)
                    local cached_reg_reads = param_535.reg_reads;
                    local condition_value_082 = cached_reg_reads[param_536];
                    local local_symbol_113;
                    if condition_value_082 then
                        local_symbol_113 = condition_value_082;
                    else
                        local table_value_116 = {};
                        cached_reg_reads[param_536] = table_value_116;
                        local_symbol_113 = table_value_116;
                    end;
                    table.insert(local_symbol_113, param_537);
                    cached_reg_reads = param_535.reg_reads_global;
                    condition_value_082 = cached_reg_reads[param_536];
                    if condition_value_082 then
                        local_symbol_113 = condition_value_082;
                    else
                        local table_value_117 = {};
                        cached_reg_reads[param_536] = table_value_117;
                        local_symbol_113 = table_value_117;
                    end;
                    table.insert(local_symbol_113, param_537);
                    local _ = param_537.code;
                    local_symbol_113 = param_535.neglected[param_536];
                    if local_symbol_113 then
                        for _ = #local_symbol_113, 1, -1 do

                        end;
                    end;
                end;
                helper_function_080 = function(param_538, param_539, param_540)
                    local cached_reg_writes_001 = param_538.reg_writes;
                    local condition_value_083 = cached_reg_writes_001[param_539];
                    local local_symbol_114;
                    if condition_value_083 then
                        local_symbol_114 = condition_value_083;
                    else
                        local table_value_118 = {};
                        cached_reg_writes_001[param_539] = table_value_118;
                        local_symbol_114 = table_value_118;
                    end;
                    table.insert(local_symbol_114, param_540);
                    cached_reg_writes_001 = param_538.reg_writes_global;
                    condition_value_083 = cached_reg_writes_001[param_539];
                    if condition_value_083 then
                        local_symbol_114 = condition_value_083;
                    else
                        local table_value_119 = {};
                        cached_reg_writes_001[param_539] = table_value_119;
                        local_symbol_114 = table_value_119;
                    end;
                    table.insert(local_symbol_114, param_540);
                    local_symbol_114 = {
                        hl_index = param_538.location.hl_index,
                        start_code = param_540.code,
                        register = param_539
                    };
                    if param_538.neglected[param_539] then

                    end;
                    local cached_neglected_001 = param_538.neglected;
                    local condition_value_084 = cached_neglected_001[param_539];
                    if condition_value_084 then
                        condition_value_083 = condition_value_084;
                    else
                        local table_value_120 = {};
                        cached_neglected_001[param_539] = table_value_120;
                        condition_value_083 = table_value_120;
                    end;
                    table.insert(condition_value_083, local_symbol_114);
                end;
                helper_function_081 = {};
                helper_function_082 = function(param_541, param_542, param_543, param_544)
                    local cached_reg_has_var = param_541.reg_has_var;
                    if param_544 and not helper_function_081[param_543] then
                        table.insert(param_543, param_544.code);
                        helper_function_081[param_543] = true;
                    end;
                    local table_value_121 = {};
                    for _, item_076 in ipairs(param_543) do
                        array_value_101[item_076.index] = param_542;
                        local table_value_122 = {};
                        local condition_value_085 = param_541.demands[item_076.index];
                        if condition_value_085 then
                            for index_046 = #condition_value_085, 1, -1 do
                                local register_value_009 = condition_value_085[index_046];
                                if register_value_009.type == "define variable" then
                                    local cached_register_range_003 = register_value_009.info.register_range;
                                    for index_047 = cached_register_range_003.beginning, cached_register_range_003.ending do
                                        local register_value_010 = param_541.reg_forced_var[index_047];
                                        local table_value_123 = {
                                            register_range = cached_register_range_003,
                                            beginning = item_076.index,
                                            definition_location = register_value_009.info.definition_location,
                                            start_of_use = register_value_009.info.start_of_use
                                        };
                                        if register_value_010 then
                                            table.insert(register_value_010, table_value_123);
                                        elseif register_value_009.info.is_predefinition then
                                            assert(not register_value_009.info.no_definition);
                                            helper_function_077(param_541, cached_register_range_003, item_076.code_index, true, true);
                                            helper_function_075(param_541, table_value_123, item_076.code_index);
                                        elseif register_value_009.info.no_definition then
                                            helper_function_075(param_541, table_value_123, item_076.code_index);
                                        else
                                            table.insert(table_value_122, table_value_123);
                                        end;
                                    end;
                                else
                                    error((("Unknown demand %*"):format(register_value_009.type)));
                                end;
                            end;
                            param_541.demands[item_076.index] = nil;
                        end;
                        local local_symbol_115, local_symbol_116, _ = analyze_register_usage(item_076);
                        local table_value_124 = {};
                        local table_value_125 = {};
                        for _, item_077 in ipairs(local_symbol_115) do
                            table_value_125[item_077] = true;
                            local condition_value_086 = helper_function_076(param_541, item_077, item_076.code_index);
                            if condition_value_086 then
                                table_value_124[item_077] = condition_value_086;
                                cached_reg_has_var[item_077] = condition_value_086.register_range;
                            end;
                        end;
                        for _, item_078 in ipairs(local_symbol_116) do
                            if not table_value_125[item_078] then
                                local condition_value_087 = helper_function_076(param_541, item_078, item_076.code_index);
                                if condition_value_087 then
                                    table_value_124[item_078] = condition_value_087;
                                    cached_reg_has_var[item_078] = condition_value_087.register_range;
                                end;
                            end;
                        end;
                        for item_079 in pairs(table_value_121) do
                            if not table_value_124[item_079] then

                            end;
                        end;
                        table_value_121 = table.clone(table_value_124);
                        table_value_125 = nil;
                        if #local_symbol_116 > 1 then
                            local local_symbol_117 = true;
                            local condition_value_088 = local_symbol_116[1];
                            for index_048 = 2, #local_symbol_116 do
                                condition_value_088 = condition_value_088 + 1;
                                if local_symbol_116[index_048] ~= condition_value_088 then
                                    local_symbol_117 = nil;
                                    break;
                                end;
                            end;
                            if local_symbol_117 then
                                local range_value_021 = local_symbol_116[1];
                                local range_value_022 = local_symbol_116[#local_symbol_116];
                                table_value_125 = if range_value_022 then {
                                    beginning = range_value_021,
                                    ending = range_value_022
                                } else {
                                    beginning = range_value_021,
                                    ending = range_value_021
                                };
                            end;
                        elseif #local_symbol_116 == 1 then
                            local range_value_023 = local_symbol_116[1];
                            table_value_125 = {
                                beginning = range_value_023,
                                ending = range_value_023
                            };
                        end;
                        if #local_symbol_115 == 0 then
                            for _, item_080 in ipairs(local_symbol_116) do
                                if cached_reg_has_var[item_080] and not table_value_124[item_080] then
                                    local range_value_024 = param_541.reg_has_var[item_080];
                                    for index_049 = range_value_024.beginning, range_value_024.ending do
                                        param_541.reg_has_var[index_049] = nil;
                                    end;
                                end;
                                param_541.uncertain_regs[item_080] = nil;
                                local table_value_126 = {
                                    code = item_076,
                                    location = param_541.location,
                                    reg_range = table_value_125
                                };
                                local cached_reg_writes_002 = param_541.reg_writes;
                                local condition_value_089 = cached_reg_writes_002[item_080];
                                local local_symbol_118;
                                if condition_value_089 then
                                    local_symbol_118 = condition_value_089;
                                else
                                    local table_value_127 = {};
                                    cached_reg_writes_002[item_080] = table_value_127;
                                    local_symbol_118 = table_value_127;
                                end;
                                table.insert(local_symbol_118, table_value_126);
                                cached_reg_writes_002 = param_541.reg_writes_global;
                                condition_value_089 = cached_reg_writes_002[item_080];
                                if condition_value_089 then
                                    local_symbol_118 = condition_value_089;
                                else
                                    local table_value_128 = {};
                                    cached_reg_writes_002[item_080] = table_value_128;
                                    local_symbol_118 = table_value_128;
                                end;
                                table.insert(local_symbol_118, table_value_126);
                                local_symbol_118 = {
                                    hl_index = param_541.location.hl_index,
                                    start_code = table_value_126.code,
                                    register = item_080
                                };
                                if param_541.neglected[item_080] then

                                end;
                                local cached_neglected_002 = param_541.neglected;
                                local condition_value_090 = cached_neglected_002[item_080];
                                if condition_value_090 then
                                    condition_value_089 = condition_value_090;
                                else
                                    local table_value_129 = {};
                                    cached_neglected_002[item_080] = table_value_129;
                                    condition_value_089 = table_value_129;
                                end;
                                table.insert(condition_value_089, local_symbol_118);
                            end;
                        else
                            for _, item_081 in ipairs(local_symbol_115) do
                                if not table_value_124[item_081] then
                                    local condition_value_091 = param_541.uncertain_regs[item_081];
                                    if condition_value_091 then
                                        local cached_location_005 = param_541.location;
                                        local cached_location_006 = condition_value_091.location;
                                        local local_symbol_119;
                                        if cached_location_005.depth < cached_location_006.depth then
                                            local_symbol_119 = false;
                                        else
                                            local cached_location = cached_location_005;
                                            while true do
                                                if cached_location.depth ~= cached_location_006.depth then
                                                    cached_location = cached_location.parent;
                                                    if not cached_location then
                                                        local_symbol_119 = false;
                                                        break;
                                                    end;
                                                else
                                                    local_symbol_119 = cached_location.hl_index == cached_location_006.hl_index;
                                                    break;
                                                end;
                                            end;
                                        end;
                                        if not local_symbol_119 then
                                            helper_function_069(param_541, condition_value_091);
                                        end;
                                    else
                                        local condition_value_092 = param_541.reg_writes_global[item_081];
                                        if condition_value_092 and #condition_value_092 > 0 then
                                            local local_symbol_120 = condition_value_092[#condition_value_092];
                                            local cached_last_loop = param_541.location.last_loop;
                                            if cached_last_loop then
                                                local cached_location_007 = param_541.location;
                                                local local_symbol_121;
                                                if cached_location_007.depth < cached_last_loop.depth then
                                                    local_symbol_121 = false;
                                                else
                                                    local cached_location_008 = cached_location_007;
                                                    while true do
                                                        if cached_location_008.depth ~= cached_last_loop.depth then
                                                            cached_location_008 = cached_location_008.parent;
                                                            if not cached_location_008 then
                                                                local_symbol_121 = false;
                                                                break;
                                                            end;
                                                        else
                                                            local_symbol_121 = cached_location_008.hl_index == cached_last_loop.hl_index;
                                                            break;
                                                        end;
                                                    end;
                                                end;
                                                if local_symbol_121 then
                                                    local cached_location_009 = local_symbol_120.location;
                                                    if cached_location_009.depth < cached_last_loop.depth then
                                                        local_symbol_121 = false;
                                                    else
                                                        local cached_location_010 = cached_location_009;
                                                        while true do
                                                            if cached_location_010.depth ~= cached_last_loop.depth then
                                                                cached_location_010 = cached_location_010.parent;
                                                                if not cached_location_010 then
                                                                    local_symbol_121 = false;
                                                                    break;
                                                                end;
                                                            else
                                                                local_symbol_121 = cached_location_010.hl_index == cached_last_loop.hl_index;
                                                                break;
                                                            end;
                                                        end;
                                                    end;
                                                    if not local_symbol_121 then
                                                        local_symbol_121 = {
                                                            index = item_076.index,
                                                            location = cached_location_007,
                                                            register_range = {
                                                                beginning = item_081,
                                                                ending = item_081
                                                            }
                                                        };
                                                        helper_function_069(param_541, local_symbol_121, local_symbol_120, true);
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                                if not cached_reg_has_var[item_081] and not table_value_124[item_081] then
                                    local cached_reg_reads_global_001 = param_541.reg_reads_global;
                                    local condition_value_093 = cached_reg_reads_global_001[item_081];
                                    local local_symbol_122;
                                    if condition_value_093 then
                                        local_symbol_122 = condition_value_093;
                                    else
                                        local table_value_130 = {};
                                        cached_reg_reads_global_001[item_081] = table_value_130;
                                        local_symbol_122 = table_value_130;
                                    end;
                                    if #local_symbol_122 > 0 then
                                        condition_value_093 = param_541.reg_writes_global;
                                        local condition_value_094 = condition_value_093[item_081];
                                        if condition_value_094 then
                                            cached_reg_reads_global_001 = condition_value_094;
                                        else
                                            local table_value_131 = {};
                                            condition_value_093[item_081] = table_value_131;
                                            cached_reg_reads_global_001 = table_value_131;
                                        end;
                                        condition_value_093 = local_symbol_122[#local_symbol_122];
                                        condition_value_094 = cached_reg_reads_global_001[#cached_reg_reads_global_001];
                                        if condition_value_094 and condition_value_094.code.opname ~= "NAMECALL" and condition_value_093.code.index > condition_value_094.code.index then
                                            helper_function_077(param_541, condition_value_094.reg_range, condition_value_094.code.code_index);
                                        end;
                                    end;
                                end;
                                local table_value_132 = {
                                    code = item_076,
                                    location = param_541.location,
                                    reg_range = {
                                        beginning = item_081,
                                        ending = item_081
                                    }
                                };
                                local cached_reg_reads_001 = param_541.reg_reads;
                                local condition_value_095 = cached_reg_reads_001[item_081];
                                local local_symbol_123;
                                if condition_value_095 then
                                    local_symbol_123 = condition_value_095;
                                else
                                    local table_value_133 = {};
                                    cached_reg_reads_001[item_081] = table_value_133;
                                    local_symbol_123 = table_value_133;
                                end;
                                table.insert(local_symbol_123, table_value_132);
                                cached_reg_reads_001 = param_541.reg_reads_global;
                                condition_value_095 = cached_reg_reads_001[item_081];
                                if condition_value_095 then
                                    local_symbol_123 = condition_value_095;
                                else
                                    local table_value_134 = {};
                                    cached_reg_reads_001[item_081] = table_value_134;
                                    local_symbol_123 = table_value_134;
                                end;
                                table.insert(local_symbol_123, table_value_132);
                                local _ = table_value_132.code;
                                local_symbol_123 = param_541.neglected[item_081];
                                if local_symbol_123 then
                                    for _ = #local_symbol_123, 1, -1 do

                                    end;
                                end;
                            end;
                            for _, item_082 in ipairs(local_symbol_116) do
                                if cached_reg_has_var[item_082] and not table_value_124[item_082] then
                                    local range_value_025 = param_541.reg_has_var[item_082];
                                    for index_050 = range_value_025.beginning, range_value_025.ending do
                                        param_541.reg_has_var[index_050] = nil;
                                    end;
                                end;
                                param_541.uncertain_regs[item_082] = nil;
                                local table_value_135 = {
                                    code = item_076,
                                    location = param_541.location,
                                    reg_range = table_value_125
                                };
                                local cached_reg_writes_003 = param_541.reg_writes;
                                local condition_value_096 = cached_reg_writes_003[item_082];
                                local local_symbol_124;
                                if condition_value_096 then
                                    local_symbol_124 = condition_value_096;
                                else
                                    local table_value_136 = {};
                                    cached_reg_writes_003[item_082] = table_value_136;
                                    local_symbol_124 = table_value_136;
                                end;
                                table.insert(local_symbol_124, table_value_135);
                                cached_reg_writes_003 = param_541.reg_writes_global;
                                condition_value_096 = cached_reg_writes_003[item_082];
                                if condition_value_096 then
                                    local_symbol_124 = condition_value_096;
                                else
                                    local table_value_137 = {};
                                    cached_reg_writes_003[item_082] = table_value_137;
                                    local_symbol_124 = table_value_137;
                                end;
                                table.insert(local_symbol_124, table_value_135);
                                local_symbol_124 = {
                                    hl_index = param_541.location.hl_index,
                                    start_code = table_value_135.code,
                                    register = item_082
                                };
                                if param_541.neglected[item_082] then

                                end;
                                local cached_neglected_003 = param_541.neglected;
                                local condition_value_097 = cached_neglected_003[item_082];
                                if condition_value_097 then
                                    condition_value_096 = condition_value_097;
                                else
                                    local table_value_138 = {};
                                    cached_neglected_003[item_082] = table_value_138;
                                    condition_value_096 = table_value_138;
                                end;
                                table.insert(condition_value_096, local_symbol_124);
                            end;
                        end;
                        if #local_symbol_116 > 1 and item_076.opname ~= "NAMECALL" then
                            helper_function_077(param_541, table_value_125);
                        end;
                        for _, item_083 in ipairs(local_symbol_116) do
                            if #table_value_122 > 0 then
                                for _, item_084 in ipairs(table_value_122) do
                                    local cached_register_range_004 = item_084.register_range;
                                    local cached_beginning_008 = cached_register_range_004.beginning;
                                    local cached_ending_005 = cached_register_range_004.ending;
                                    local register_value_011 = false;
                                    if cached_beginning_008 <= item_083 then
                                        register_value_011 = item_083 <= cached_ending_005;
                                    end;
                                    if register_value_011 then
                                        helper_function_077(param_541, item_084.register_range, item_076.code_index, nil, true);
                                    end;
                                    helper_function_075(param_541, item_084, item_076.code_index);
                                end;
                                table.clear(table_value_122);
                            elseif not table_value_124[item_083] then

                            end;
                        end;
                        if #table_value_122 > 0 then
                            error("Failed to handle forcedef");
                        end;
                    end;
                end;
                helper_function_083 = function(param_545)
                    local array_value_112 = shallow_clone_nested_tables(param_545.reg_reads);
                    local array_value_113 = shallow_clone_nested_tables(param_545.reg_reads_global);
                    return {
                        reg_has_var = table.clone(param_545.reg_has_var),
                        reg_forced_var = param_545.reg_forced_var,
                        reg_reads = array_value_112,
                        reg_reads_global = array_value_113,
                        reg_writes = {},
                        reg_writes_global = param_545.reg_writes_global,
                        demands = param_545.demands,
                        observations = param_545.observations,
                        uncertain_regs = param_545.uncertain_regs,
                        preprocess_task_index = param_545.preprocess_task_index,
                        neglected = {},
                        location = param_545.location
                    };
                end;
                helper_function_084 = function(param_546, param_547)
                    for local_symbol_125, item_085 in pairs(param_547.neglected) do
                        param_546.neglected[local_symbol_125] = item_085;
                    end;
                    for condition_value_098, item_086 in pairs(param_547.reg_writes) do
                        if #item_086 > 0 and not param_547.reg_has_var[condition_value_098] then
                            param_546.uncertain_regs[condition_value_098] = {
                                register_range = {
                                    beginning = condition_value_098,
                                    ending = condition_value_098
                                },
                                index = item_086[1].code.index,
                                location = param_547.location
                            };
                        end;
                    end;
                    for local_symbol_126, item_087 in pairs(param_547.reg_reads) do
                        local cached_reg_reads_global_002 = param_546.reg_reads_global;
                        local condition_value_099 = cached_reg_reads_global_002[local_symbol_126];
                        local local_symbol_127;
                        if condition_value_099 then
                            local_symbol_127 = condition_value_099;
                        else
                            local table_value_139 = {};
                            cached_reg_reads_global_002[local_symbol_126] = table_value_139;
                            local_symbol_127 = table_value_139;
                        end;
                        for _, item_088 in ipairs(item_087) do
                            table.insert(local_symbol_127, item_088);
                        end;
                    end;
                end;
                helper_function_085 = nil;
                helper_function_086 = 0;
                helper_function_087 = 0;
                helper_function_088 = #table_value_043;
                helper_function_089 = {};
                helper_function_090 = function(param_548, param_549, param_550, param_551, param_552)
                    helper_function_087 = helper_function_087 + 1;
                    yield_if_needed(helper_function_087, helper_function_088, "<VarAnalysisCycle" .. helper_function_086 .. ">");
                    local cached_hl_index_006 = param_549.hl_index;
                    local cached_location_011 = param_548.location;
                    local table_value_140 = {
                        hl_index = cached_hl_index_006,
                        depth = if param_551 then cached_location_011.depth + 1 else cached_location_011.depth,
                        parent = if param_551 then cached_location_011 else cached_location_011.parent,
                        last_loop = cached_location_011.last_loop
                    };
                    if param_552 then
                        table_value_140.last_loop = table_value_140;
                    end;
                    param_548.location = table_value_140;
                    if param_550 then
                        table_value_095[param_549.hl_index] = param_550.hl_index;
                    end;
                    if not table_value_096[param_549.hl_index] then
                        table_value_096[param_549.hl_index] = param_548.location;
                    end;
                    if param_549.type == "sequential" then
                        for _, item_089 in ipairs(param_549.data) do
                            table_value_094[item_089] = table_value_094[param_549.hl_index];
                            helper_function_090(param_548, table_value_043[item_089], param_550);
                        end;
                    elseif param_549.type == "single" then
                        helper_function_082(param_548, param_549.hl_index, param_549.data, param_549._visitor);
                    elseif not (param_549.type ~= "ifthen") or param_549.type == "ifthenelse" then
                        local cached_data_005 = param_549.data;
                        param_548.location = helper_function_085(param_548, cached_data_005.condition, param_549);
                        cached_hl_index_006 = helper_function_083(param_548);
                        cached_location_011 = nil;
                        if cached_data_005.else_ then
                            cached_location_011 = helper_function_083(param_548);
                            table_value_094[cached_data_005.else_] = param_549.hl_index;
                            cached_location_011.neglected = {};
                            helper_function_090(cached_location_011, table_value_043[cached_data_005.else_], param_549, true);
                        end;
                        table_value_094[cached_data_005.pass] = param_549.hl_index;
                        cached_hl_index_006.neglected = {};
                        helper_function_090(cached_hl_index_006, table_value_043[cached_data_005.pass], param_549, true);
                        helper_function_084(param_548, cached_hl_index_006);
                        if cached_data_005.else_ then
                            helper_function_084(param_548, cached_location_011);
                        end;
                    elseif param_549.type == "oneblockwhile" then
                        local condition_value_100 = helper_function_083(param_548);
                        condition_value_100.neglected = {};
                        cached_hl_index_006 = param_549.data;
                        table_value_094[cached_hl_index_006.code] = param_549.hl_index;
                        cached_location_011 = cached_hl_index_006.for_info;
                        if cached_location_011 and not cached_location_011.variables then
                            table_value_140 = nil;
                            if cached_location_011.type == "numeric" then
                                local cached_index_reg = cached_location_011.args.index_reg;
                                local table_value_141 = {
                                    beginning = cached_index_reg,
                                    ending = cached_index_reg
                                };
                                cached_index_reg = {};
                                local table_value_142 = {};
                                local cached_is_point_in_named_range_008 = is_point_in_named_range;
                                local string_value_038 = "var" .. tostring(string_value_018);
                                local string_value_039 = table_value_024[string_value_038];
                                local cached_string_value_021 = string_value_038;
                                local local_symbol_128 = string_value_039 or 1;
                                while table_value_023[cached_string_value_021] or table_value_018[cached_string_value_021] do
                                    local_symbol_128 = local_symbol_128 + 1;
                                    cached_string_value_021 = string_value_038 .. "_" .. local_symbol_128;
                                end;
                                table_value_024[string_value_038] = local_symbol_128;
                                local cached_string_value_022 = cached_string_value_021;
                                string_value_018 = string_value_018 + 1;
                                local local_symbol_129 = cached_is_point_in_named_range_008(cached_string_value_022, table_value_141, table_value_142);
                                copy_varargs_into_array(cached_index_reg, 1, local_symbol_129);
                                table_value_140 = cached_index_reg;
                            elseif cached_location_011.type == "generic" then
                                local _ = cached_location_011.args;
                                local table_value_143 = {};
                                local cached_variable_count = cached_location_011.variable_count;
                                table_value_140 = table.create(cached_variable_count);
                                for _ = 1, cached_variable_count do
                                    local cached_variables_reg_range = cached_location_011.variables_reg_range;
                                    local cached_is_point_in_named_range_009 = is_point_in_named_range;
                                    local range_value_026 = "var" .. tostring(string_value_018);
                                    local string_value_040 = table_value_024[range_value_026];
                                    local cached_range_value_002 = range_value_026;
                                    local local_symbol_130 = string_value_040 or 1;
                                    while table_value_023[cached_range_value_002] or table_value_018[cached_range_value_002] do
                                        local_symbol_130 = local_symbol_130 + 1;
                                        cached_range_value_002 = range_value_026 .. "_" .. local_symbol_130;
                                    end;
                                    table_value_024[range_value_026] = local_symbol_130;
                                    local cached_range_value_003 = cached_range_value_002;
                                    string_value_018 = string_value_018 + 1;
                                    table.insert(table_value_140, (cached_is_point_in_named_range_009(cached_range_value_003, cached_variables_reg_range, table_value_143)));
                                end;
                            else
                                error((("Unknown for_info type \"%*\""):format(cached_location_011.type)));
                            end;
                            cached_location_011.variables = table_value_140;
                            helper_function_089[cached_location_011] = true;
                            helper_function_070(condition_value_100.demands, cached_location_011.variables_reg_range, param_549.index, param_548.location, nil, true);
                        end;
                        helper_function_090(condition_value_100, table_value_043[cached_hl_index_006.code], param_549, true, true);
                        helper_function_084(param_548, condition_value_100);
                    else
                        error((("Unknown hl_block type %*"):format(param_549.type)));
                    end;
                    array_value_100[param_549.hl_index] = param_548;
                end;
                helper_function_091 = function(param_553, param_554, param_555, param_556)
                    local condition_value_101 = nil;
                    if param_554.type == "reg" then
                        assert(param_554.code);
                        local condition_value_102 = table_value_043[param_554.code];
                        local cached_hl_index_007 = condition_value_102.hl_index;
                        local cached_location_012 = param_553.location;
                        condition_value_101 = {
                            hl_index = cached_hl_index_007,
                            depth = if param_556 then cached_location_012.depth + 1 else cached_location_012.depth,
                            parent = if param_556 then cached_location_012 else cached_location_012.parent,
                            last_loop = cached_location_012.last_loop
                        };
                        param_553.location = condition_value_101;
                        helper_function_090(param_553, condition_value_102, param_555, nil);
                        return condition_value_101;
                    else
                        local cached_hl_index_008 = param_553.location.hl_index;
                        local cached_location_013 = param_553.location;
                        condition_value_101 = {
                            hl_index = cached_hl_index_008,
                            depth = if param_556 then cached_location_013.depth + 1 else cached_location_013.depth,
                            parent = if param_556 then cached_location_013 else cached_location_013.parent,
                            last_loop = cached_location_013.last_loop
                        };
                        param_553.location = condition_value_101;
                        cached_hl_index_008 = param_554.lhs;
                        if type(cached_hl_index_008) == "table" then
                            if cached_hl_index_008.is_full_condition_t then
                                helper_function_091(param_553, cached_hl_index_008, param_555, param_554.type == "and");
                            end;
                            cached_location_013 = param_554.rhs;
                            if type(cached_location_013) == "table" and cached_location_013.is_full_condition_t then
                                if param_554.type == "and" then
                                    local condition_value_103 = helper_function_083(param_553);
                                    condition_value_101 = helper_function_091(condition_value_103, cached_location_013, param_555, nil);
                                    helper_function_084(param_553, condition_value_103);
                                    return condition_value_101;
                                else
                                    helper_function_091(param_553, cached_location_013, param_555);
                                end;
                            end;
                        end;
                        return condition_value_101;
                    end;
                end;
                helper_function_085 = helper_function_091;
                helper_function_092 = helper_function_057();
                helper_function_093 = false;
                local_symbol_091 = {};
                helper_function_094 = {};
                while true do
                    helper_function_095 = {};
                    helper_function_086 = helper_function_086 + 1;
                    helper_function_087 = 0;
                    if helper_function_086 > 1 then
                        table_value_038 = {};
                    end;
                    array_value_100 = {};
                    table_value_094 = {};
                    table_value_095 = {};
                    table_value_096 = {};
                    array_value_101 = {};
                    table_value_098 = 0;
                    helper_function_061 = {};
                    helper_function_094 = {};
                    for item_090 in pairs(helper_function_089) do
                        item_090.variables = nil;
                    end;
                    helper_function_089 = {};
                    local table_value_144 = {
                        hl_index = helper_function_092.hl_index,
                        depth = 0,
                        parent = nil
                    };
                    helper_function_090({
                        reg_src = {},
                        reg_all_src = {},
                        reg_has_var = {},
                        reg_forced_var = {},
                        reg_reads = {},
                        reg_reads_global = {},
                        reg_writes = {},
                        reg_writes_global = {},
                        demands = local_symbol_091,
                        observations = helper_function_094,
                        uncertain_regs = {},
                        preprocess_task_index = table_value_098,
                        neglected = helper_function_095,
                        location = table_value_144
                    }, helper_function_092, helper_function_092, true);
                    if not next(local_symbol_091) then
                        for _, item_091 in ipairs(helper_function_094) do
                            local _ = item_091.location.parent.hl_index;
                            if not local_symbol_091[item_091.info.wanted_definition_point] then
                                helper_function_070(local_symbol_091, item_091.info.register_range, item_091.info.wanted_definition_point, item_091.info.definition_location, item_091.info.is_predefinition);
                            end;
                        end;
                        if helper_function_086 >= 4 then
                            helper_function_093 = true;
                            break;
                        elseif not (#helper_function_094 ~= 0) then
                            break;
                        end;
                    else
                        break;
                    end;
                end;
                if helper_function_093 then
                    helper_function_013(1, cached_prefix_warning .. ": Variable analysis failed. Output will have some incorrect variable assignments");
                end;
                for array_value_114, item_092 in pairs(table_value_038) do
                    assert(#item_092 > 0);
                    local array_value_115 = table.create(#item_092);
                    local table_value_145 = {};
                    local table_value_146 = {};
                    local table_value_147 = {};
                    for index_051 = #item_092, 1, -1 do
                        local array_value_116 = item_092[index_051];
                        local cached_type_005 = array_value_116.type;
                        if cached_type_005 == "defvar" then
                            table.insert(table_value_145, array_value_116);
                        elseif cached_type_005 == "lockvar" then
                            table.insert(table_value_146, array_value_116);
                        else
                            table.insert(table_value_147, array_value_116);
                        end;
                    end;
                    for _, item_093 in ipairs(table_value_145) do
                        table.insert(array_value_115, item_093);
                    end;
                    for _, item_094 in ipairs(table_value_146) do
                        table.insert(array_value_115, item_094);
                    end;
                    for _, item_095 in ipairs(table_value_147) do
                        table.insert(array_value_115, item_095);
                    end;
                    table_value_038[array_value_114] = array_value_115;
                end;
                local_symbol_023:end_benchmark("Stack Incantation");
                local_symbol_023:start_benchmark("AST Generation");
                helper_function_095 = function(param_557, param_558)
                    local local_symbol_131;
                    if table_value_044[param_558] then
                        local_symbol_131 = helper_function_017(param_558, table_value_044[param_558]);
                    else
                        local expression_value_015 = array_value_078[param_558];
                        if not expression_value_015 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(param_558) .. "]");
                            expression_value_015 = helper_function_014(param_558, (conditional_not(true)));
                        end;
                        local_symbol_131 = expression_value_015;
                    end;
                    array_value_078[param_557] = local_symbol_131;
                    table_value_037[local_symbol_131] = param_557;
                end;
                local function helper_function_097(_)
                    helper_function_031();
                end;
                local function helper_function_098(_)
                    local_symbol_031 = true;
                end;
                local local_symbol_132 = nil;
                local_symbol_132 = {
                    FASTCALL = helper_function_097,
                    FASTCALL1 = helper_function_097,
                    FASTCALL2 = helper_function_097,
                    FASTCALL2K = helper_function_097,
                    FASTCALL3 = helper_function_097,
                    FORNPREP = helper_function_097,
                    FORGPREP = helper_function_097,
                    FORGPREP_NEXT = helper_function_097,
                    FORGPREP_INEXT = helper_function_097,
                    PREPVARARGS = helper_function_097,
                    JUMP = helper_function_098,
                    JUMPBACK = helper_function_098,
                    JUMPX = helper_function_098,
                    JUMPIF = helper_function_098,
                    JUMPIFNOT = helper_function_098,
                    JUMPIFEQ = helper_function_098,
                    JUMPIFLE = helper_function_098,
                    JUMPIFLT = helper_function_098,
                    JUMPIFNOTEQ = helper_function_098,
                    JUMPIFNOTLE = helper_function_098,
                    JUMPIFNOTLT = helper_function_098,
                    JUMPXEQKNIL = helper_function_098,
                    JUMPXEQKB = helper_function_098,
                    JUMPXEQKN = helper_function_098,
                    JUMPXEQKS = helper_function_098,
                    FORNLOOP = helper_function_098,
                    FORGLOOP = helper_function_098,
                    GETVARARGS = function(param_559)
                        local bit_value_153 = bit32.band(bit32.rshift(param_559, 8), 255);
                        local bit_value_154 = bit32.band(bit32.rshift(param_559, 16), 255) - 1;
                        if bit_value_154 == 0 then
                            helper_function_012(cached_prefix_warning .. ": Malformed varargs");
                            return;
                        else
                            if bit_value_154 == -1 then
                                current_instruction_index = bit_value_153;
                            end;
                            helper_function_030(bit_value_153, helper_function_032(bit_value_153));
                            return;
                        end;
                    end,
                    MOVE = function(param_560)
                        local bit_value_155 = bit32.band(bit32.rshift(param_560, 8), 255);
                        local bit_value_156 = bit32.band(bit32.rshift(param_560, 16), 255);
                        local bit_value_157;
                        if table_value_044[bit_value_156] then
                            bit_value_157 = helper_function_017(bit_value_156, table_value_044[bit_value_156]);
                        else
                            local expression_value_016 = array_value_078[bit_value_156];
                            if not expression_value_016 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_156) .. "]");
                                expression_value_016 = helper_function_014(bit_value_156, (conditional_not(true)));
                            end;
                            bit_value_157 = expression_value_016;
                        end;
                        array_value_078[bit_value_155] = bit_value_157;
                        table_value_037[bit_value_157] = bit_value_155;
                        helper_function_030(bit_value_155, helper_function_018(bit_value_156));
                    end,
                    LOADK = function(param_561)
                        local constant_value_055 = bit32.band(bit32.rshift(param_561, 8), 255);
                        local constant_value_056 = cached_constants_001[bit32.band(bit32.rshift(param_561, 16), 65535)];
                        helper_function_030(constant_value_055, helper_function_034(constant_value_055, constant_value_056));
                    end,
                    LOADKX = function(param_562)
                        local bit_value_158 = bit32.band(bit32.rshift(param_562, 8), 255);
                        local bit_value_159 = cached_code_001[local_symbol_024 + 1];
                        if not bit_value_159 then
                            error("Expected aux");
                        end;
                        bit_value_159 = cached_constants_001[bit_value_159];
                        helper_function_030(bit_value_158, helper_function_034(bit_value_158, bit_value_159));
                    end,
                    LOADN = function(param_563)
                        local buffer_value_091 = bit32.band(bit32.rshift(param_563, 8), 255);
                        buffer.writeu16(scratch_buffer_u64, 0, (bit32.band(bit32.rshift(param_563, 16), 65535)));
                        helper_function_030(buffer_value_091, helper_function_034(buffer_value_091, {
                            type = 2,
                            value = buffer.readi16(scratch_buffer_u64, 0)
                        }));
                    end,
                    LOADNIL = function(param_564)
                        local bit_value_160 = bit32.band(bit32.rshift(param_564, 8), 255);
                        helper_function_030(bit_value_160, helper_function_015(bit_value_160));
                    end,
                    LOADB = function(param_565)
                        local bit_value_161 = bit32.band(bit32.rshift(param_565, 8), 255);
                        local bit_value_162 = bit32.band(bit32.rshift(param_565, 16), 255);
                        assert(bit_value_162 <= 1);
                        helper_function_030(bit_value_161, helper_function_037(bit_value_161, bit_value_162 == 1));
                    end,
                    NEWTABLE = function(param_566)
                        local bit_value_163 = bit32.band(bit32.rshift(param_566, 8), 255);
                        helper_function_030(bit_value_163, helper_function_035(bit_value_163));
                    end,
                    DUPTABLE = function(param_567)
                        local bit_value_164 = bit32.band(bit32.rshift(param_567, 8), 255);
                        helper_function_030(bit_value_164, helper_function_035(bit_value_164));
                    end,
                    SETTABLE = function(param_568)
                        local bit_value_165 = bit32.band(bit32.rshift(param_568, 8), 255);
                        local bit_value_166 = bit32.band(bit32.rshift(param_568, 16), 255);
                        local bit_value_167 = bit32.band(bit32.rshift(param_568, 24), 255);
                        local cached_helper_function_036 = helper_function_023;
                        local cached_bit_value_012 = bit_value_166;
                        local local_symbol_133;
                        if table_value_044[bit_value_167] then
                            local_symbol_133 = helper_function_017(bit_value_167, table_value_044[bit_value_167]);
                        else
                            local expression_value_017 = array_value_078[bit_value_167];
                            if not expression_value_017 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_167) .. "]");
                                expression_value_017 = helper_function_014(bit_value_167, (conditional_not(true)));
                            end;
                            local_symbol_133 = expression_value_017;
                        end;
                        if table_value_030[local_symbol_133] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_133] = true;
                        end;
                        local cached_local_symbol_008 = local_symbol_133;
                        local local_symbol_134;
                        if table_value_044[bit_value_165] then
                            local_symbol_134 = helper_function_017(bit_value_165, table_value_044[bit_value_165]);
                        else
                            local expression_value_018 = array_value_078[bit_value_165];
                            if not expression_value_018 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_165) .. "]");
                                expression_value_018 = helper_function_014(bit_value_165, (conditional_not(true)));
                            end;
                            local_symbol_134 = expression_value_018;
                        end;
                        if table_value_030[local_symbol_134] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_134] = true;
                        end;
                        cached_helper_function_036(cached_bit_value_012, cached_local_symbol_008, local_symbol_134);
                        helper_function_010();
                        helper_function_031();
                    end,
                    SETTABLEKS = function(param_569)
                        local constant_value_057 = bit32.band(bit32.rshift(param_569, 8), 255);
                        local constant_value_058 = bit32.band(bit32.rshift(param_569, 16), 255);
                        local cached_constants_002 = cached_constants_001;
                        local constant_value_059 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_059 then
                            error("Expected aux");
                        end;
                        local constant_value_060 = cached_constants_002[constant_value_059];
                        cached_constants_002 = helper_function_023;
                        local cached_constant_value_001 = constant_value_058;
                        constant_value_059 = helper_function_034(nil, constant_value_060);
                        local local_symbol_135;
                        if table_value_044[constant_value_057] then
                            local_symbol_135 = helper_function_017(constant_value_057, table_value_044[constant_value_057]);
                        else
                            local expression_value_019 = array_value_078[constant_value_057];
                            if not expression_value_019 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_057) .. "]");
                                expression_value_019 = helper_function_014(constant_value_057, (conditional_not(true)));
                            end;
                            local_symbol_135 = expression_value_019;
                        end;
                        if table_value_030[local_symbol_135] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_135] = true;
                        end;
                        cached_constants_002(cached_constant_value_001, constant_value_059, local_symbol_135);
                        helper_function_010();
                        helper_function_031();
                    end,
                    SETUDATAKS = function(param_569)
                        local constant_value_057 = bit32.band(bit32.rshift(param_569, 8), 255);
                        local constant_value_058 = bit32.band(bit32.rshift(param_569, 16), 255);
                        local cached_constants_002 = cached_constants_001;
                        local constant_value_059 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_059 then
                            error("Expected aux");
                        end;
                        local constant_value_060 = cached_constants_002[constant_value_059];
                        cached_constants_002 = helper_function_023;
                        local cached_constant_value_001 = constant_value_058;
                        constant_value_059 = helper_function_034(nil, constant_value_060);
                        local local_symbol_135;
                        if table_value_044[constant_value_057] then
                            local_symbol_135 = helper_function_017(constant_value_057, table_value_044[constant_value_057]);
                        else
                            local expression_value_019 = array_value_078[constant_value_057];
                            if not expression_value_019 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_057) .. "]");
                                expression_value_019 = helper_function_014(constant_value_057, (conditional_not(true)));
                            end;
                            local_symbol_135 = expression_value_019;
                        end;
                        if table_value_030[local_symbol_135] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_135] = true;
                        end;
                        cached_constants_002(cached_constant_value_001, constant_value_059, local_symbol_135);
                        helper_function_010();
                        helper_function_031();
                    end,
                    SETTABLEN = function(param_570)
                        local bit_value_168 = bit32.band(bit32.rshift(param_570, 8), 255);
                        local bit_value_169 = bit32.band(bit32.rshift(param_570, 16), 255);
                        local bit_value_170 = bit32.band(bit32.rshift(param_570, 24), 255) + 1;
                        local cached_helper_function_037 = helper_function_023;
                        local cached_bit_value_013 = bit_value_169;
                        local local_symbol_136 = helper_function_034(nil, {
                            type = 2,
                            value = bit_value_170
                        });
                        local local_symbol_137;
                        if table_value_044[bit_value_168] then
                            local_symbol_137 = helper_function_017(bit_value_168, table_value_044[bit_value_168]);
                        else
                            local expression_value_020 = array_value_078[bit_value_168];
                            if not expression_value_020 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_168) .. "]");
                                expression_value_020 = helper_function_014(bit_value_168, (conditional_not(true)));
                            end;
                            local_symbol_137 = expression_value_020;
                        end;
                        if table_value_030[local_symbol_137] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_137] = true;
                        end;
                        cached_helper_function_037(cached_bit_value_013, local_symbol_136, local_symbol_137);
                        helper_function_010();
                        helper_function_031();
                    end,
                    GETTABLE = function(param_571)
                        local bit_value_171 = bit32.band(bit32.rshift(param_571, 8), 255);
                        local bit_value_172 = bit32.band(bit32.rshift(param_571, 16), 255);
                        local bit_value_173;
                        if table_value_044[bit_value_172] then
                            bit_value_173 = helper_function_017(bit_value_172, table_value_044[bit_value_172]);
                        else
                            local expression_value_021 = array_value_078[bit_value_172];
                            if not expression_value_021 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_172) .. "]");
                                expression_value_021 = helper_function_014(bit_value_172, (conditional_not(true)));
                            end;
                            bit_value_173 = expression_value_021;
                        end;
                        if table_value_030[bit_value_173] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[bit_value_173] = true;
                        end;
                        local cached_bit_value_014 = bit_value_173;
                        local bit_value_174 = bit32.band(bit32.rshift(param_571, 24), 255);
                        if table_value_044[bit_value_174] then
                            bit_value_172 = helper_function_017(bit_value_174, table_value_044[bit_value_174]);
                        else
                            local expression_value_022 = array_value_078[bit_value_174];
                            if not expression_value_022 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_174) .. "]");
                                expression_value_022 = helper_function_014(bit_value_174, (conditional_not(true)));
                            end;
                            bit_value_172 = expression_value_022;
                        end;
                        if table_value_030[bit_value_172] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[bit_value_172] = true;
                        end;
                        helper_function_030(bit_value_171, helper_function_052(bit_value_171, cached_bit_value_014, bit_value_172));
                    end,
                    GETTABLEKS = function(param_572)
                        local bit_value_175 = bit32.band(bit32.rshift(param_572, 8), 255);
                        local bit_value_176 = bit32.band(bit32.rshift(param_572, 16), 255);
                        local bit_value_177;
                        if table_value_044[bit_value_176] then
                            bit_value_177 = helper_function_017(bit_value_176, table_value_044[bit_value_176]);
                        else
                            local expression_value_023 = array_value_078[bit_value_176];
                            if not expression_value_023 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_176) .. "]");
                                expression_value_023 = helper_function_014(bit_value_176, (conditional_not(true)));
                            end;
                            bit_value_177 = expression_value_023;
                        end;
                        if table_value_030[bit_value_177] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[bit_value_177] = true;
                        end;
                        local cached_bit_value_015 = bit_value_177;
                        bit_value_176 = cached_constants_001;
                        local constant_value_061 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_061 then
                            error("Expected aux");
                        end;
                        bit_value_177 = bit_value_176[constant_value_061];
                        helper_function_030(bit_value_175, helper_function_052(bit_value_175, cached_bit_value_015, helper_function_034(nil, bit_value_177)));
                    end,
                    GETUDATAKS = function(param_572)
                        local bit_value_175 = bit32.band(bit32.rshift(param_572, 8), 255);
                        local bit_value_176 = bit32.band(bit32.rshift(param_572, 16), 255);
                        local bit_value_177;
                        if table_value_044[bit_value_176] then
                            bit_value_177 = helper_function_017(bit_value_176, table_value_044[bit_value_176]);
                        else
                            local expression_value_023 = array_value_078[bit_value_176];
                            if not expression_value_023 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_176) .. "]");
                                expression_value_023 = helper_function_014(bit_value_176, (conditional_not(true)));
                            end;
                            bit_value_177 = expression_value_023;
                        end;
                        if table_value_030[bit_value_177] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[bit_value_177] = true;
                        end;
                        local cached_bit_value_015 = bit_value_177;
                        bit_value_176 = cached_constants_001;
                        local constant_value_061 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_061 then
                            error("Expected aux");
                        end;
                        bit_value_177 = bit_value_176[constant_value_061];
                        helper_function_030(bit_value_175, helper_function_052(bit_value_175, cached_bit_value_015, helper_function_034(nil, bit_value_177)));
                    end,
                    GETTABLEN = function(param_573)
                        local bit_value_178 = bit32.band(bit32.rshift(param_573, 8), 255);
                        local bit_value_179 = bit32.band(bit32.rshift(param_573, 16), 255);
                        local bit_value_180;
                        if table_value_044[bit_value_179] then
                            bit_value_180 = helper_function_017(bit_value_179, table_value_044[bit_value_179]);
                        else
                            local expression_value_024 = array_value_078[bit_value_179];
                            if not expression_value_024 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_179) .. "]");
                                expression_value_024 = helper_function_014(bit_value_179, (conditional_not(true)));
                            end;
                            bit_value_180 = expression_value_024;
                        end;
                        if table_value_030[bit_value_180] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[bit_value_180] = true;
                        end;
                        local cached_bit_value_016 = bit_value_180;
                        bit_value_180 = bit32.band(bit32.rshift(param_573, 24), 255) + 1;
                        helper_function_030(bit_value_178, helper_function_052(bit_value_178, cached_bit_value_016, helper_function_034(nil, {
                            type = 2,
                            value = bit_value_180
                        })));
                    end,
                    SETLIST = function(param_574)
                        local bit_value_181 = bit32.band(bit32.rshift(param_574, 8), 255);
                        local bit_value_182 = bit32.band(bit32.rshift(param_574, 16), 255);
                        local bit_value_183 = bit32.band(bit32.rshift(param_574, 24), 255) - 1;
                        local bit_value_184 = cached_code_001[local_symbol_024 + 1];
                        if not bit_value_184 then
                            error("Expected aux");
                        end;
                        local cached_bit_value_017 = bit_value_184;
                        if table_value_044[bit_value_181] then
                            bit_value_184 = helper_function_017(bit_value_181, table_value_044[bit_value_181]);
                        else
                            local expression_value_025 = array_value_078[bit_value_181];
                            if not expression_value_025 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_181) .. "]");
                                expression_value_025 = helper_function_014(bit_value_181, (conditional_not(true)));
                            end;
                            bit_value_184 = expression_value_025;
                        end;
                        local cached_bit_value_018 = bit_value_182;
                        local condition_value_104 = if bit_value_183 == -1 then current_instruction_index else bit_value_182 + bit_value_183 - 1;
                        for index_052 = cached_bit_value_018, condition_value_104 do
                            local cached_helper_function_038 = helper_function_023;
                            local cached_bit_value_019 = bit_value_181;
                            local local_symbol_138 = helper_function_034(nil, {
                                type = 2,
                                value = cached_bit_value_017
                            });
                            local local_symbol_139;
                            if table_value_044[index_052] then
                                local_symbol_139 = helper_function_017(index_052, table_value_044[index_052]);
                            else
                                local expression_value_026 = array_value_078[index_052];
                                if not expression_value_026 then
                                    helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(index_052) .. "]");
                                    expression_value_026 = helper_function_014(index_052, (conditional_not(true)));
                                end;
                                local_symbol_139 = expression_value_026;
                            end;
                            if table_value_030[local_symbol_139] then
                                helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                            else
                                table_value_030[local_symbol_139] = true;
                            end;
                            cached_helper_function_038(cached_bit_value_019, local_symbol_138, local_symbol_139);
                            helper_function_010();
                            cached_bit_value_017 = cached_bit_value_017 + 1;
                        end;
                        helper_function_014(bit_value_181, bit_value_184);
                        helper_function_031();
                    end,
                    GETUPVAL = function(param_575)
                        local bit_value_185 = bit32.band(bit32.rshift(param_575, 8), 255);
                        local register_value_012 = bit32.band(bit32.rshift(param_575, 16), 255);
                        assert(param_294);
                        local register_value_013 = param_294.upvalues[register_value_012];
                        helper_function_030(bit_value_185, helper_function_017(bit_value_185, register_value_013.name));
                    end,
                    SETUPVAL = function(param_576)
                        local bit_value_186 = bit32.band(bit32.rshift(param_576, 8), 255);
                        local register_value_014 = bit32.band(bit32.rshift(param_576, 16), 255);
                        assert(param_294);
                        local register_value_015 = param_294.upvalues[register_value_014];
                        local cached_helper_function_039 = helper_function_021;
                        local cached_name_009 = register_value_015.name;
                        local local_symbol_140;
                        if table_value_044[bit_value_186] then
                            local_symbol_140 = helper_function_017(bit_value_186, table_value_044[bit_value_186]);
                        else
                            local expression_value_027 = array_value_078[bit_value_186];
                            if not expression_value_027 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_186) .. "]");
                                expression_value_027 = helper_function_014(bit_value_186, (conditional_not(true)));
                            end;
                            local_symbol_140 = expression_value_027;
                        end;
                        if table_value_030[local_symbol_140] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_140] = true;
                        end;
                        cached_helper_function_039(cached_name_009, local_symbol_140);
                        helper_function_010();
                        helper_function_031();
                    end,
                    GETIMPORT = function(param_577)
                        local bit_value_187 = bit32.band(bit32.rshift(param_577, 8), 255);
                        local bit_value_188 = cached_code_001[local_symbol_024 + 1];
                        if not bit_value_188 then
                            error("Expected aux");
                        end;
                        bit_value_188 = helper_function_053(bit_value_187, bit_value_188);
                        assert(bit_value_188);
                        helper_function_030(bit_value_187, bit_value_188);
                    end,
                    GETGLOBAL = function(param_578)
                        local constant_value_062 = bit32.band(bit32.rshift(param_578, 8), 255);
                        local cached_constants_003 = cached_constants_001;
                        local constant_value_063 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_063 then
                            error("Expected aux");
                        end;
                        local constant_value_064 = cached_constants_003[constant_value_063];
                        helper_function_030(constant_value_062, helper_function_033(constant_value_062, constant_value_064));
                    end,
                    SETGLOBAL = function(param_579)
                        local constant_value_065 = bit32.band(bit32.rshift(param_579, 8), 255);
                        local cached_constants_004 = cached_constants_001;
                        local constant_value_066 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_066 then
                            error("Expected aux");
                        end;
                        local constant_value_067 = cached_constants_004[constant_value_066];
                        cached_constants_004 = helper_function_022;
                        local cached_constant_value_002 = constant_value_067;
                        local constant_value_068;
                        if table_value_044[constant_value_065] then
                            constant_value_068 = helper_function_017(constant_value_065, table_value_044[constant_value_065]);
                        else
                            local expression_value_028 = array_value_078[constant_value_065];
                            if not expression_value_028 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_065) .. "]");
                                expression_value_028 = helper_function_014(constant_value_065, (conditional_not(true)));
                            end;
                            constant_value_068 = expression_value_028;
                        end;
                        if table_value_030[constant_value_068] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[constant_value_068] = true;
                        end;
                        cached_constants_004(cached_constant_value_002, constant_value_068);
                        helper_function_010();
                        helper_function_031();
                    end,
                    NAMECALL = function(param_580)
                        local constant_value_069 = bit32.band(bit32.rshift(param_580, 8), 255);
                        local constant_value_070 = bit32.band(bit32.rshift(param_580, 16), 255);
                        local cached_constants_005 = cached_constants_001;
                        local constant_value_071 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_071 then
                            error("Expected aux");
                        end;
                        local_symbol_033 = cached_constants_005[constant_value_071] or {
                            type = 3,
                            value = "<UNK>"
                        };
                        assert(local_symbol_033);
                        local local_symbol_141;
                        if table_value_044[constant_value_070] then
                            local_symbol_141 = helper_function_017(constant_value_070, table_value_044[constant_value_070]);
                        else
                            local expression_value_029 = array_value_078[constant_value_070];
                            if not expression_value_029 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_070) .. "]");
                                expression_value_029 = helper_function_014(constant_value_070, (conditional_not(true)));
                            end;
                            local_symbol_141 = expression_value_029;
                        end;
                        array_value_078[constant_value_069] = local_symbol_141;
                        table_value_037[local_symbol_141] = constant_value_069;
                        if table_value_044[constant_value_070] then
                            local_symbol_141 = helper_function_017(constant_value_070, table_value_044[constant_value_070]);
                        else
                            local expression_value_030 = array_value_078[constant_value_070];
                            if not expression_value_030 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_070) .. "]");
                                expression_value_030 = helper_function_014(constant_value_070, (conditional_not(true)));
                            end;
                            local_symbol_141 = expression_value_030;
                        end;
                        cached_constants_005 = helper_function_036(constant_value_069, local_symbol_141, local_symbol_033, true);
                        assert(cached_constants_005);
                        helper_function_030(constant_value_069, cached_constants_005);
                    end,
                    NAMECALLUDATA = function(param_580)
                        local constant_value_069 = bit32.band(bit32.rshift(param_580, 8), 255);
                        local constant_value_070 = bit32.band(bit32.rshift(param_580, 16), 255);
                        local cached_constants_005 = cached_constants_001;
                        local constant_value_071 = cached_code_001[local_symbol_024 + 1];
                        if not constant_value_071 then
                            error("Expected aux");
                        end;
                        local_symbol_033 = cached_constants_005[constant_value_071] or {
                            type = 3,
                            value = "<UNK>"
                        };
                        assert(local_symbol_033);
                        local local_symbol_141;
                        if table_value_044[constant_value_070] then
                            local_symbol_141 = helper_function_017(constant_value_070, table_value_044[constant_value_070]);
                        else
                            local expression_value_029 = array_value_078[constant_value_070];
                            if not expression_value_029 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_070) .. "]");
                                expression_value_029 = helper_function_014(constant_value_070, (conditional_not(true)));
                            end;
                            local_symbol_141 = expression_value_029;
                        end;
                        array_value_078[constant_value_069] = local_symbol_141;
                        table_value_037[local_symbol_141] = constant_value_069;
                        if table_value_044[constant_value_070] then
                            local_symbol_141 = helper_function_017(constant_value_070, table_value_044[constant_value_070]);
                        else
                            local expression_value_030 = array_value_078[constant_value_070];
                            if not expression_value_030 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_070) .. "]");
                                expression_value_030 = helper_function_014(constant_value_070, (conditional_not(true)));
                            end;
                            local_symbol_141 = expression_value_030;
                        end;
                        cached_constants_005 = helper_function_036(constant_value_069, local_symbol_141, local_symbol_033, true);
                        assert(cached_constants_005);
                        helper_function_030(constant_value_069, cached_constants_005);
                    end,
                    RETURN = function(param_581)
                        local constant_value_072 = bit32.band(bit32.rshift(param_581, 8), 255);
                        local bit_value_189 = bit32.band(bit32.rshift(param_581, 16), 255) - 1;
                        if bit_value_189 == 0 and local_symbol_025 == #table_value_041 then
                            table_value_035[table_value_022] = true;
                            helper_function_031();
                            return;
                        else
                            helper_function_024(constant_value_072, bit_value_189);
                            helper_function_010();
                            helper_function_031();
                            return;
                        end;
                    end,
                    CALL = function(param_582)
                        local bit_value_190 = bit32.band(bit32.rshift(param_582, 8), 255);
                        local bit_value_191 = bit32.band(bit32.rshift(param_582, 16), 255) - 1;
                        local bit_value_192 = bit32.band(bit32.rshift(param_582, 24), 255) - 1;
                        if bit_value_191 == -1 then
                            bit_value_191 = current_instruction_index - bit_value_190;
                        end;
                        local condition_value_105 = helper_function_054(bit_value_190, bit_value_191, bit_value_192, local_symbol_033 and local_symbol_033.value);
                        local_symbol_033 = nil;
                        if bit_value_192 == -1 then
                            current_instruction_index = bit_value_190;
                        end;
                        if bit_value_192 ~= 0 then
                            helper_function_030(bit_value_190, condition_value_105);
                            return;
                        else
                            if condition_value_105.t == "name" then
                            else
                                local table_value_148 = {
                                    t = "call",
                                    lines = table_value_022,
                                    reads = {},
                                    writes = {},
                                    func = condition_value_105.func,
                                    args = condition_value_105.args
                                };
                                ranges_equal(table_value_148, condition_value_105.func);
                                for _, item_096 in ipairs(condition_value_105.args) do
                                    ranges_equal(table_value_148, item_096);
                                end;
                                table_value_042 = table_value_148;
                                helper_function_010();
                            end;
                            helper_function_031();
                            return;
                        end;
                    end,
                    CLOSEUPVALS = function(param_583)
                        local array_value_117 = bit32.band(bit32.rshift(param_583, 8), 255);
                        for item_097 in pairs(table.clone(table_value_067)) do
                            if array_value_117 <= item_097 then
                                table_value_045[item_097] = nil;
                                table_value_067[item_097] = nil;
                            end;
                        end;
                        helper_function_031();
                    end,
                    DUPCLOSURE = function(param_584)
                        local constant_value_073 = bit32.band(bit32.rshift(param_584, 8), 255);
                        local constant_value_074 = cached_constants_001[bit32.band(bit32.rshift(param_584, 16), 65535)];
                        if constant_value_074.type ~= 6 then
                            failed_instruction_count = failed_instruction_count + 1;
                            error("Invalid DUPCLOSURE");
                        end;
                        local diagnostic_value_001 = array_value_069[constant_value_074.value];
                        helper_function_055(constant_value_073, diagnostic_value_001);
                    end,
                    NEWCLOSURE = function(param_585)
                        local proto_value_009 = bit32.band(bit32.rshift(param_585, 8), 255);
                        local proto_value_010 = cached_protos_001[bit32.band(bit32.rshift(param_585, 16), 65535)];
                        helper_function_055(proto_value_009, proto_value_010);
                    end,
                    ADD = function(param_586)
                        local bit_value_193 = bit32.band(bit32.rshift(param_586, 8), 255);
                        local bit_value_194 = bit32.band(bit32.rshift(param_586, 16), 255);
                        local bit_value_195 = bit32.band(bit32.rshift(param_586, 24), 255);
                        local cached_helper_function_040 = helper_function_030;
                        local cached_bit_value_020 = bit_value_193;
                        local cached_helper_function_041 = helper_function_041;
                        local cached_bit_value_021 = bit_value_193;
                        local local_symbol_142;
                        if table_value_044[bit_value_194] then
                            local_symbol_142 = helper_function_017(bit_value_194, table_value_044[bit_value_194]);
                        else
                            local expression_value_031 = array_value_078[bit_value_194];
                            if not expression_value_031 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_194) .. "]");
                                expression_value_031 = helper_function_014(bit_value_194, (conditional_not(true)));
                            end;
                            local_symbol_142 = expression_value_031;
                        end;
                        if table_value_030[local_symbol_142] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_142] = true;
                        end;
                        local cached_local_symbol_009 = local_symbol_142;
                        local local_symbol_143;
                        if table_value_044[bit_value_195] then
                            local_symbol_143 = helper_function_017(bit_value_195, table_value_044[bit_value_195]);
                        else
                            local expression_value_032 = array_value_078[bit_value_195];
                            if not expression_value_032 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_195) .. "]");
                                expression_value_032 = helper_function_014(bit_value_195, (conditional_not(true)));
                            end;
                            local_symbol_143 = expression_value_032;
                        end;
                        if table_value_030[local_symbol_143] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_143] = true;
                        end;
                        cached_helper_function_040(cached_bit_value_020, cached_helper_function_041(cached_bit_value_021, cached_local_symbol_009, local_symbol_143));
                    end,
                    ADDK = function(param_587)
                        local constant_value_075 = bit32.band(bit32.rshift(param_587, 8), 255);
                        local constant_value_076 = bit32.band(bit32.rshift(param_587, 16), 255);
                        local constant_value_077 = cached_constants_001[bit32.band(bit32.rshift(param_587, 24), 255)];
                        if constant_value_077.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed ADDK (constant wasn't a number)");
                        end;
                        local cached_helper_function_042 = helper_function_030;
                        local cached_constant_value_003 = constant_value_075;
                        local cached_helper_function_043 = helper_function_041;
                        local cached_constant_value_004 = constant_value_075;
                        local local_symbol_144;
                        if table_value_044[constant_value_076] then
                            local_symbol_144 = helper_function_017(constant_value_076, table_value_044[constant_value_076]);
                        else
                            local expression_value_033 = array_value_078[constant_value_076];
                            if not expression_value_033 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_076) .. "]");
                                expression_value_033 = helper_function_014(constant_value_076, (conditional_not(true)));
                            end;
                            local_symbol_144 = expression_value_033;
                        end;
                        if table_value_030[local_symbol_144] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_144] = true;
                        end;
                        cached_helper_function_042(cached_constant_value_003, cached_helper_function_043(cached_constant_value_004, local_symbol_144, helper_function_034(nil, constant_value_077)));
                    end,
                    SUB = function(param_588)
                        local bit_value_196 = bit32.band(bit32.rshift(param_588, 8), 255);
                        local bit_value_197 = bit32.band(bit32.rshift(param_588, 16), 255);
                        local bit_value_198 = bit32.band(bit32.rshift(param_588, 24), 255);
                        local cached_helper_function_044 = helper_function_030;
                        local cached_bit_value_022 = bit_value_196;
                        local cached_helper_function_045 = helper_function_042;
                        local cached_bit_value_023 = bit_value_196;
                        local local_symbol_145;
                        if table_value_044[bit_value_197] then
                            local_symbol_145 = helper_function_017(bit_value_197, table_value_044[bit_value_197]);
                        else
                            local expression_value_034 = array_value_078[bit_value_197];
                            if not expression_value_034 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_197) .. "]");
                                expression_value_034 = helper_function_014(bit_value_197, (conditional_not(true)));
                            end;
                            local_symbol_145 = expression_value_034;
                        end;
                        if table_value_030[local_symbol_145] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_145] = true;
                        end;
                        local cached_local_symbol_010 = local_symbol_145;
                        local local_symbol_146;
                        if table_value_044[bit_value_198] then
                            local_symbol_146 = helper_function_017(bit_value_198, table_value_044[bit_value_198]);
                        else
                            local expression_value_035 = array_value_078[bit_value_198];
                            if not expression_value_035 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_198) .. "]");
                                expression_value_035 = helper_function_014(bit_value_198, (conditional_not(true)));
                            end;
                            local_symbol_146 = expression_value_035;
                        end;
                        if table_value_030[local_symbol_146] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_146] = true;
                        end;
                        cached_helper_function_044(cached_bit_value_022, cached_helper_function_045(cached_bit_value_023, cached_local_symbol_010, local_symbol_146));
                    end,
                    SUBK = function(param_589)
                        local constant_value_078 = bit32.band(bit32.rshift(param_589, 8), 255);
                        local constant_value_079 = bit32.band(bit32.rshift(param_589, 16), 255);
                        local constant_value_080 = cached_constants_001[bit32.band(bit32.rshift(param_589, 24), 255)];
                        if constant_value_080.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed SUBK (constant wasn't a number)");
                        end;
                        local cached_helper_function_046 = helper_function_030;
                        local cached_constant_value_005 = constant_value_078;
                        local cached_helper_function_047 = helper_function_042;
                        local cached_constant_value_006 = constant_value_078;
                        local local_symbol_147;
                        if table_value_044[constant_value_079] then
                            local_symbol_147 = helper_function_017(constant_value_079, table_value_044[constant_value_079]);
                        else
                            local expression_value_036 = array_value_078[constant_value_079];
                            if not expression_value_036 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_079) .. "]");
                                expression_value_036 = helper_function_014(constant_value_079, (conditional_not(true)));
                            end;
                            local_symbol_147 = expression_value_036;
                        end;
                        if table_value_030[local_symbol_147] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_147] = true;
                        end;
                        cached_helper_function_046(cached_constant_value_005, cached_helper_function_047(cached_constant_value_006, local_symbol_147, helper_function_034(nil, constant_value_080)));
                    end,
                    MUL = function(param_590)
                        local bit_value_199 = bit32.band(bit32.rshift(param_590, 8), 255);
                        local bit_value_200 = bit32.band(bit32.rshift(param_590, 16), 255);
                        local bit_value_201 = bit32.band(bit32.rshift(param_590, 24), 255);
                        local cached_helper_function_048 = helper_function_030;
                        local cached_bit_value_024 = bit_value_199;
                        local cached_helper_function_049 = helper_function_043;
                        local cached_bit_value_025 = bit_value_199;
                        local local_symbol_148;
                        if table_value_044[bit_value_200] then
                            local_symbol_148 = helper_function_017(bit_value_200, table_value_044[bit_value_200]);
                        else
                            local expression_value_037 = array_value_078[bit_value_200];
                            if not expression_value_037 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_200) .. "]");
                                expression_value_037 = helper_function_014(bit_value_200, (conditional_not(true)));
                            end;
                            local_symbol_148 = expression_value_037;
                        end;
                        if table_value_030[local_symbol_148] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_148] = true;
                        end;
                        local cached_local_symbol_011 = local_symbol_148;
                        local local_symbol_149;
                        if table_value_044[bit_value_201] then
                            local_symbol_149 = helper_function_017(bit_value_201, table_value_044[bit_value_201]);
                        else
                            local expression_value_038 = array_value_078[bit_value_201];
                            if not expression_value_038 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_201) .. "]");
                                expression_value_038 = helper_function_014(bit_value_201, (conditional_not(true)));
                            end;
                            local_symbol_149 = expression_value_038;
                        end;
                        if table_value_030[local_symbol_149] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_149] = true;
                        end;
                        cached_helper_function_048(cached_bit_value_024, cached_helper_function_049(cached_bit_value_025, cached_local_symbol_011, local_symbol_149));
                    end,
                    MULK = function(param_591)
                        local constant_value_081 = bit32.band(bit32.rshift(param_591, 8), 255);
                        local constant_value_082 = bit32.band(bit32.rshift(param_591, 16), 255);
                        local constant_value_083 = cached_constants_001[bit32.band(bit32.rshift(param_591, 24), 255)];
                        if constant_value_083.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed MULK (constant wasn't a number)");
                        end;
                        local cached_helper_function_050 = helper_function_030;
                        local cached_constant_value_007 = constant_value_081;
                        local cached_helper_function_051 = helper_function_043;
                        local cached_constant_value_008 = constant_value_081;
                        local local_symbol_150;
                        if table_value_044[constant_value_082] then
                            local_symbol_150 = helper_function_017(constant_value_082, table_value_044[constant_value_082]);
                        else
                            local expression_value_039 = array_value_078[constant_value_082];
                            if not expression_value_039 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_082) .. "]");
                                expression_value_039 = helper_function_014(constant_value_082, (conditional_not(true)));
                            end;
                            local_symbol_150 = expression_value_039;
                        end;
                        if table_value_030[local_symbol_150] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_150] = true;
                        end;
                        cached_helper_function_050(cached_constant_value_007, cached_helper_function_051(cached_constant_value_008, local_symbol_150, helper_function_034(nil, constant_value_083)));
                    end,
                    DIV = function(param_592)
                        local bit_value_202 = bit32.band(bit32.rshift(param_592, 8), 255);
                        local bit_value_203 = bit32.band(bit32.rshift(param_592, 16), 255);
                        local bit_value_204 = bit32.band(bit32.rshift(param_592, 24), 255);
                        local cached_helper_function_052 = helper_function_030;
                        local cached_bit_value_026 = bit_value_202;
                        local cached_helper_function_053 = helper_function_044;
                        local cached_bit_value_027 = bit_value_202;
                        local local_symbol_151;
                        if table_value_044[bit_value_203] then
                            local_symbol_151 = helper_function_017(bit_value_203, table_value_044[bit_value_203]);
                        else
                            local expression_value_040 = array_value_078[bit_value_203];
                            if not expression_value_040 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_203) .. "]");
                                expression_value_040 = helper_function_014(bit_value_203, (conditional_not(true)));
                            end;
                            local_symbol_151 = expression_value_040;
                        end;
                        if table_value_030[local_symbol_151] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_151] = true;
                        end;
                        local cached_local_symbol_012 = local_symbol_151;
                        local local_symbol_152;
                        if table_value_044[bit_value_204] then
                            local_symbol_152 = helper_function_017(bit_value_204, table_value_044[bit_value_204]);
                        else
                            local expression_value_041 = array_value_078[bit_value_204];
                            if not expression_value_041 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_204) .. "]");
                                expression_value_041 = helper_function_014(bit_value_204, (conditional_not(true)));
                            end;
                            local_symbol_152 = expression_value_041;
                        end;
                        if table_value_030[local_symbol_152] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_152] = true;
                        end;
                        cached_helper_function_052(cached_bit_value_026, cached_helper_function_053(cached_bit_value_027, cached_local_symbol_012, local_symbol_152));
                    end,
                    DIVK = function(param_593)
                        local constant_value_084 = bit32.band(bit32.rshift(param_593, 8), 255);
                        local constant_value_085 = bit32.band(bit32.rshift(param_593, 16), 255);
                        local constant_value_086 = cached_constants_001[bit32.band(bit32.rshift(param_593, 24), 255)];
                        if constant_value_086.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed DIVK (constant wasn't a number)");
                        end;
                        local cached_helper_function_054 = helper_function_030;
                        local cached_constant_value_009 = constant_value_084;
                        local cached_helper_function_055 = helper_function_044;
                        local cached_constant_value_010 = constant_value_084;
                        local local_symbol_153;
                        if table_value_044[constant_value_085] then
                            local_symbol_153 = helper_function_017(constant_value_085, table_value_044[constant_value_085]);
                        else
                            local expression_value_042 = array_value_078[constant_value_085];
                            if not expression_value_042 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_085) .. "]");
                                expression_value_042 = helper_function_014(constant_value_085, (conditional_not(true)));
                            end;
                            local_symbol_153 = expression_value_042;
                        end;
                        if table_value_030[local_symbol_153] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_153] = true;
                        end;
                        cached_helper_function_054(cached_constant_value_009, cached_helper_function_055(cached_constant_value_010, local_symbol_153, helper_function_034(nil, constant_value_086)));
                    end,
                    SUBRK = function(param_594)
                        local constant_value_087 = bit32.band(bit32.rshift(param_594, 8), 255);
                        local constant_value_088 = cached_constants_001[bit32.band(bit32.rshift(param_594, 16), 255)];
                        local constant_value_089 = bit32.band(bit32.rshift(param_594, 24), 255);
                        if constant_value_088.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed SUBRK (constant wasn't a number)");
                        end;
                        local cached_helper_function_056 = helper_function_030;
                        local cached_constant_value_011 = constant_value_087;
                        local cached_helper_function_057 = helper_function_042;
                        local cached_constant_value_012 = constant_value_087;
                        local local_symbol_154 = helper_function_034(nil, constant_value_088);
                        local local_symbol_155;
                        if table_value_044[constant_value_089] then
                            local_symbol_155 = helper_function_017(constant_value_089, table_value_044[constant_value_089]);
                        else
                            local expression_value_043 = array_value_078[constant_value_089];
                            if not expression_value_043 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_089) .. "]");
                                expression_value_043 = helper_function_014(constant_value_089, (conditional_not(true)));
                            end;
                            local_symbol_155 = expression_value_043;
                        end;
                        if table_value_030[local_symbol_155] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_155] = true;
                        end;
                        cached_helper_function_056(cached_constant_value_011, cached_helper_function_057(cached_constant_value_012, local_symbol_154, local_symbol_155));
                    end,
                    DIVRK = function(param_595)
                        local constant_value_090 = bit32.band(bit32.rshift(param_595, 8), 255);
                        local constant_value_091 = cached_constants_001[bit32.band(bit32.rshift(param_595, 16), 255)];
                        local constant_value_092 = bit32.band(bit32.rshift(param_595, 24), 255);
                        if constant_value_091.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed DIVRK (constant wasn't a number)");
                        end;
                        local cached_helper_function_058 = helper_function_030;
                        local cached_constant_value_013 = constant_value_090;
                        local cached_helper_function_059 = helper_function_044;
                        local cached_constant_value_014 = constant_value_090;
                        local local_symbol_156 = helper_function_034(nil, constant_value_091);
                        local local_symbol_157;
                        if table_value_044[constant_value_092] then
                            local_symbol_157 = helper_function_017(constant_value_092, table_value_044[constant_value_092]);
                        else
                            local expression_value_044 = array_value_078[constant_value_092];
                            if not expression_value_044 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_092) .. "]");
                                expression_value_044 = helper_function_014(constant_value_092, (conditional_not(true)));
                            end;
                            local_symbol_157 = expression_value_044;
                        end;
                        if table_value_030[local_symbol_157] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_157] = true;
                        end;
                        cached_helper_function_058(cached_constant_value_013, cached_helper_function_059(cached_constant_value_014, local_symbol_156, local_symbol_157));
                    end,
                    IDIV = function(param_596)
                        local bit_value_205 = bit32.band(bit32.rshift(param_596, 8), 255);
                        local bit_value_206 = bit32.band(bit32.rshift(param_596, 16), 255);
                        local bit_value_207 = bit32.band(bit32.rshift(param_596, 24), 255);
                        local cached_helper_function_060 = helper_function_030;
                        local cached_bit_value_028 = bit_value_205;
                        local cached_helper_function_061 = helper_function_045;
                        local cached_bit_value_029 = bit_value_205;
                        local local_symbol_158;
                        if table_value_044[bit_value_206] then
                            local_symbol_158 = helper_function_017(bit_value_206, table_value_044[bit_value_206]);
                        else
                            local expression_value_045 = array_value_078[bit_value_206];
                            if not expression_value_045 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_206) .. "]");
                                expression_value_045 = helper_function_014(bit_value_206, (conditional_not(true)));
                            end;
                            local_symbol_158 = expression_value_045;
                        end;
                        if table_value_030[local_symbol_158] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_158] = true;
                        end;
                        local cached_local_symbol_013 = local_symbol_158;
                        local local_symbol_159;
                        if table_value_044[bit_value_207] then
                            local_symbol_159 = helper_function_017(bit_value_207, table_value_044[bit_value_207]);
                        else
                            local expression_value_046 = array_value_078[bit_value_207];
                            if not expression_value_046 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_207) .. "]");
                                expression_value_046 = helper_function_014(bit_value_207, (conditional_not(true)));
                            end;
                            local_symbol_159 = expression_value_046;
                        end;
                        if table_value_030[local_symbol_159] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_159] = true;
                        end;
                        cached_helper_function_060(cached_bit_value_028, cached_helper_function_061(cached_bit_value_029, cached_local_symbol_013, local_symbol_159));
                    end,
                    IDIVK = function(param_597)
                        local constant_value_093 = bit32.band(bit32.rshift(param_597, 8), 255);
                        local constant_value_094 = bit32.band(bit32.rshift(param_597, 16), 255);
                        local constant_value_095 = cached_constants_001[bit32.band(bit32.rshift(param_597, 24), 255)];
                        if constant_value_095.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed DIVK (constant wasn't a number)");
                        end;
                        local cached_helper_function_062 = helper_function_030;
                        local cached_constant_value_015 = constant_value_093;
                        local cached_helper_function_063 = helper_function_045;
                        local cached_constant_value_016 = constant_value_093;
                        local local_symbol_160;
                        if table_value_044[constant_value_094] then
                            local_symbol_160 = helper_function_017(constant_value_094, table_value_044[constant_value_094]);
                        else
                            local expression_value_047 = array_value_078[constant_value_094];
                            if not expression_value_047 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_094) .. "]");
                                expression_value_047 = helper_function_014(constant_value_094, (conditional_not(true)));
                            end;
                            local_symbol_160 = expression_value_047;
                        end;
                        if table_value_030[local_symbol_160] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_160] = true;
                        end;
                        cached_helper_function_062(cached_constant_value_015, cached_helper_function_063(cached_constant_value_016, local_symbol_160, helper_function_034(nil, constant_value_095)));
                    end,
                    POW = function(param_598)
                        local bit_value_208 = bit32.band(bit32.rshift(param_598, 8), 255);
                        local bit_value_209 = bit32.band(bit32.rshift(param_598, 16), 255);
                        local bit_value_210 = bit32.band(bit32.rshift(param_598, 24), 255);
                        local cached_helper_function_064 = helper_function_030;
                        local cached_bit_value_030 = bit_value_208;
                        local cached_helper_function_065 = helper_function_050;
                        local cached_bit_value_031 = bit_value_208;
                        local local_symbol_161;
                        if table_value_044[bit_value_209] then
                            local_symbol_161 = helper_function_017(bit_value_209, table_value_044[bit_value_209]);
                        else
                            local expression_value_048 = array_value_078[bit_value_209];
                            if not expression_value_048 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_209) .. "]");
                                expression_value_048 = helper_function_014(bit_value_209, (conditional_not(true)));
                            end;
                            local_symbol_161 = expression_value_048;
                        end;
                        if table_value_030[local_symbol_161] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_161] = true;
                        end;
                        local cached_local_symbol_014 = local_symbol_161;
                        local local_symbol_162;
                        if table_value_044[bit_value_210] then
                            local_symbol_162 = helper_function_017(bit_value_210, table_value_044[bit_value_210]);
                        else
                            local expression_value_049 = array_value_078[bit_value_210];
                            if not expression_value_049 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_210) .. "]");
                                expression_value_049 = helper_function_014(bit_value_210, (conditional_not(true)));
                            end;
                            local_symbol_162 = expression_value_049;
                        end;
                        if table_value_030[local_symbol_162] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_162] = true;
                        end;
                        cached_helper_function_064(cached_bit_value_030, cached_helper_function_065(cached_bit_value_031, cached_local_symbol_014, local_symbol_162));
                    end,
                    POWK = function(param_599)
                        local constant_value_096 = bit32.band(bit32.rshift(param_599, 8), 255);
                        local constant_value_097 = bit32.band(bit32.rshift(param_599, 16), 255);
                        local constant_value_098 = cached_constants_001[bit32.band(bit32.rshift(param_599, 24), 255)];
                        if constant_value_098.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed POWK (constant wasn't a number)");
                        end;
                        local cached_helper_function_066 = helper_function_030;
                        local cached_constant_value_017 = constant_value_096;
                        local cached_helper_function_067 = helper_function_050;
                        local cached_constant_value_018 = constant_value_096;
                        local local_symbol_163;
                        if table_value_044[constant_value_097] then
                            local_symbol_163 = helper_function_017(constant_value_097, table_value_044[constant_value_097]);
                        else
                            local expression_value_050 = array_value_078[constant_value_097];
                            if not expression_value_050 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_097) .. "]");
                                expression_value_050 = helper_function_014(constant_value_097, (conditional_not(true)));
                            end;
                            local_symbol_163 = expression_value_050;
                        end;
                        if table_value_030[local_symbol_163] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_163] = true;
                        end;
                        cached_helper_function_066(cached_constant_value_017, cached_helper_function_067(cached_constant_value_018, local_symbol_163, helper_function_034(nil, constant_value_098)));
                    end,
                    MOD = function(param_600)
                        local bit_value_211 = bit32.band(bit32.rshift(param_600, 8), 255);
                        local bit_value_212 = bit32.band(bit32.rshift(param_600, 16), 255);
                        local bit_value_213 = bit32.band(bit32.rshift(param_600, 24), 255);
                        local cached_helper_function_068 = helper_function_030;
                        local cached_bit_value_032 = bit_value_211;
                        local cached_helper_function_069 = helper_function_046;
                        local cached_bit_value_033 = bit_value_211;
                        local local_symbol_164;
                        if table_value_044[bit_value_212] then
                            local_symbol_164 = helper_function_017(bit_value_212, table_value_044[bit_value_212]);
                        else
                            local expression_value_051 = array_value_078[bit_value_212];
                            if not expression_value_051 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_212) .. "]");
                                expression_value_051 = helper_function_014(bit_value_212, (conditional_not(true)));
                            end;
                            local_symbol_164 = expression_value_051;
                        end;
                        if table_value_030[local_symbol_164] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_164] = true;
                        end;
                        local cached_local_symbol_015 = local_symbol_164;
                        local local_symbol_165;
                        if table_value_044[bit_value_213] then
                            local_symbol_165 = helper_function_017(bit_value_213, table_value_044[bit_value_213]);
                        else
                            local expression_value_052 = array_value_078[bit_value_213];
                            if not expression_value_052 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_213) .. "]");
                                expression_value_052 = helper_function_014(bit_value_213, (conditional_not(true)));
                            end;
                            local_symbol_165 = expression_value_052;
                        end;
                        if table_value_030[local_symbol_165] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_165] = true;
                        end;
                        cached_helper_function_068(cached_bit_value_032, cached_helper_function_069(cached_bit_value_033, cached_local_symbol_015, local_symbol_165));
                    end,
                    MODK = function(param_601)
                        local constant_value_099 = bit32.band(bit32.rshift(param_601, 8), 255);
                        local constant_value_100 = bit32.band(bit32.rshift(param_601, 16), 255);
                        local constant_value_101 = cached_constants_001[bit32.band(bit32.rshift(param_601, 24), 255)];
                        if constant_value_101.type ~= 2 then
                            helper_function_012(cached_prefix_warning .. ": Malformed MODK (constant wasn't a number)");
                        end;
                        local cached_helper_function_070 = helper_function_030;
                        local cached_constant_value_019 = constant_value_099;
                        local cached_helper_function_071 = helper_function_046;
                        local cached_constant_value_020 = constant_value_099;
                        local local_symbol_166;
                        if table_value_044[constant_value_100] then
                            local_symbol_166 = helper_function_017(constant_value_100, table_value_044[constant_value_100]);
                        else
                            local expression_value_053 = array_value_078[constant_value_100];
                            if not expression_value_053 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_100) .. "]");
                                expression_value_053 = helper_function_014(constant_value_100, (conditional_not(true)));
                            end;
                            local_symbol_166 = expression_value_053;
                        end;
                        if table_value_030[local_symbol_166] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_166] = true;
                        end;
                        cached_helper_function_070(cached_constant_value_019, cached_helper_function_071(cached_constant_value_020, local_symbol_166, helper_function_034(nil, constant_value_101)));
                    end,
                    AND = function(param_602)
                        local bit_value_214 = bit32.band(bit32.rshift(param_602, 8), 255);
                        local bit_value_215 = bit32.band(bit32.rshift(param_602, 16), 255);
                        local bit_value_216 = bit32.band(bit32.rshift(param_602, 24), 255);
                        local cached_helper_function_072 = helper_function_030;
                        local cached_bit_value_034 = bit_value_214;
                        local cached_helper_function_073 = helper_function_039;
                        local cached_bit_value_035 = bit_value_214;
                        local local_symbol_167;
                        if table_value_044[bit_value_215] then
                            local_symbol_167 = helper_function_017(bit_value_215, table_value_044[bit_value_215]);
                        else
                            local expression_value_054 = array_value_078[bit_value_215];
                            if not expression_value_054 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_215) .. "]");
                                expression_value_054 = helper_function_014(bit_value_215, (conditional_not(true)));
                            end;
                            local_symbol_167 = expression_value_054;
                        end;
                        if table_value_030[local_symbol_167] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_167] = true;
                        end;
                        local cached_local_symbol_016 = local_symbol_167;
                        local local_symbol_168;
                        if table_value_044[bit_value_216] then
                            local_symbol_168 = helper_function_017(bit_value_216, table_value_044[bit_value_216]);
                        else
                            local expression_value_055 = array_value_078[bit_value_216];
                            if not expression_value_055 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_216) .. "]");
                                expression_value_055 = helper_function_014(bit_value_216, (conditional_not(true)));
                            end;
                            local_symbol_168 = expression_value_055;
                        end;
                        if table_value_030[local_symbol_168] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_168] = true;
                        end;
                        cached_helper_function_072(cached_bit_value_034, cached_helper_function_073(cached_bit_value_035, cached_local_symbol_016, local_symbol_168));
                    end,
                    ANDK = function(param_603)
                        local constant_value_102 = bit32.band(bit32.rshift(param_603, 8), 255);
                        local constant_value_103 = bit32.band(bit32.rshift(param_603, 16), 255);
                        local constant_value_104 = cached_constants_001[bit32.band(bit32.rshift(param_603, 24), 255)];
                        local cached_helper_function_074 = helper_function_030;
                        local cached_constant_value_021 = constant_value_102;
                        local cached_helper_function_075 = helper_function_039;
                        local cached_constant_value_022 = constant_value_102;
                        local local_symbol_169;
                        if table_value_044[constant_value_103] then
                            local_symbol_169 = helper_function_017(constant_value_103, table_value_044[constant_value_103]);
                        else
                            local expression_value_056 = array_value_078[constant_value_103];
                            if not expression_value_056 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_103) .. "]");
                                expression_value_056 = helper_function_014(constant_value_103, (conditional_not(true)));
                            end;
                            local_symbol_169 = expression_value_056;
                        end;
                        if table_value_030[local_symbol_169] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_169] = true;
                        end;
                        cached_helper_function_074(cached_constant_value_021, cached_helper_function_075(cached_constant_value_022, local_symbol_169, helper_function_034(nil, constant_value_104)));
                    end,
                    OR = function(param_604)
                        local bit_value_217 = bit32.band(bit32.rshift(param_604, 8), 255);
                        local bit_value_218 = bit32.band(bit32.rshift(param_604, 16), 255);
                        local bit_value_219 = bit32.band(bit32.rshift(param_604, 24), 255);
                        local cached_helper_function_076 = helper_function_030;
                        local cached_bit_value_036 = bit_value_217;
                        local cached_helper_function_077 = helper_function_038;
                        local cached_bit_value_037 = bit_value_217;
                        local local_symbol_170;
                        if table_value_044[bit_value_218] then
                            local_symbol_170 = helper_function_017(bit_value_218, table_value_044[bit_value_218]);
                        else
                            local expression_value_057 = array_value_078[bit_value_218];
                            if not expression_value_057 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_218) .. "]");
                                expression_value_057 = helper_function_014(bit_value_218, (conditional_not(true)));
                            end;
                            local_symbol_170 = expression_value_057;
                        end;
                        if table_value_030[local_symbol_170] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_170] = true;
                        end;
                        local cached_local_symbol_017 = local_symbol_170;
                        local local_symbol_171;
                        if table_value_044[bit_value_219] then
                            local_symbol_171 = helper_function_017(bit_value_219, table_value_044[bit_value_219]);
                        else
                            local expression_value_058 = array_value_078[bit_value_219];
                            if not expression_value_058 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_219) .. "]");
                                expression_value_058 = helper_function_014(bit_value_219, (conditional_not(true)));
                            end;
                            local_symbol_171 = expression_value_058;
                        end;
                        if table_value_030[local_symbol_171] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_171] = true;
                        end;
                        cached_helper_function_076(cached_bit_value_036, cached_helper_function_077(cached_bit_value_037, cached_local_symbol_017, local_symbol_171));
                    end,
                    ORK = function(param_605)
                        local constant_value_105 = bit32.band(bit32.rshift(param_605, 8), 255);
                        local constant_value_106 = bit32.band(bit32.rshift(param_605, 16), 255);
                        local constant_value_107 = cached_constants_001[bit32.band(bit32.rshift(param_605, 24), 255)];
                        local cached_helper_function_078 = helper_function_030;
                        local cached_constant_value_023 = constant_value_105;
                        local cached_helper_function_079 = helper_function_038;
                        local cached_constant_value_024 = constant_value_105;
                        local local_symbol_172;
                        if table_value_044[constant_value_106] then
                            local_symbol_172 = helper_function_017(constant_value_106, table_value_044[constant_value_106]);
                        else
                            local expression_value_059 = array_value_078[constant_value_106];
                            if not expression_value_059 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(constant_value_106) .. "]");
                                expression_value_059 = helper_function_014(constant_value_106, (conditional_not(true)));
                            end;
                            local_symbol_172 = expression_value_059;
                        end;
                        if table_value_030[local_symbol_172] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_172] = true;
                        end;
                        cached_helper_function_078(cached_constant_value_023, cached_helper_function_079(cached_constant_value_024, local_symbol_172, helper_function_034(nil, constant_value_107)));
                    end,
                    CONCAT = function(param_606)
                        local bit_value_220 = bit32.band(bit32.rshift(param_606, 8), 255);
                        local bit_value_221 = bit32.band(bit32.rshift(param_606, 16), 255);
                        local bit_value_222 = bit32.band(bit32.rshift(param_606, 24), 255);
                        local table_value_149 = {};
                        for index_053 = bit_value_221, bit_value_222 do
                            local local_symbol_173;
                            if table_value_044[index_053] then
                                local_symbol_173 = helper_function_017(index_053, table_value_044[index_053]);
                            else
                                local expression_value_060 = array_value_078[index_053];
                                if not expression_value_060 then
                                    helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(index_053) .. "]");
                                    expression_value_060 = helper_function_014(index_053, (conditional_not(true)));
                                end;
                                local_symbol_173 = expression_value_060;
                            end;
                            if table_value_030[local_symbol_173] then
                                helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                            else
                                table_value_030[local_symbol_173] = true;
                            end;
                            table.insert(table_value_149, local_symbol_173);
                        end;
                        helper_function_030(bit_value_220, helper_function_051(bit_value_220, table_value_149));
                    end,
                    NOT = function(param_607)
                        local bit_value_223 = bit32.band(bit32.rshift(param_607, 8), 255);
                        local bit_value_224 = bit32.band(bit32.rshift(param_607, 16), 255);
                        local cached_helper_function_080 = helper_function_030;
                        local cached_bit_value_038 = bit_value_223;
                        local cached_helper_function_081 = helper_function_047;
                        local cached_bit_value_039 = bit_value_223;
                        local local_symbol_174;
                        if table_value_044[bit_value_224] then
                            local_symbol_174 = helper_function_017(bit_value_224, table_value_044[bit_value_224]);
                        else
                            local expression_value_061 = array_value_078[bit_value_224];
                            if not expression_value_061 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_224) .. "]");
                                expression_value_061 = helper_function_014(bit_value_224, (conditional_not(true)));
                            end;
                            local_symbol_174 = expression_value_061;
                        end;
                        if table_value_030[local_symbol_174] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_174] = true;
                        end;
                        cached_helper_function_080(cached_bit_value_038, cached_helper_function_081(cached_bit_value_039, local_symbol_174));
                    end,
                    MINUS = function(param_608)
                        local bit_value_225 = bit32.band(bit32.rshift(param_608, 8), 255);
                        local bit_value_226 = bit32.band(bit32.rshift(param_608, 16), 255);
                        local cached_helper_function_082 = helper_function_030;
                        local cached_bit_value_040 = bit_value_225;
                        local cached_helper_function_083 = helper_function_048;
                        local cached_bit_value_041 = bit_value_225;
                        local local_symbol_175;
                        if table_value_044[bit_value_226] then
                            local_symbol_175 = helper_function_017(bit_value_226, table_value_044[bit_value_226]);
                        else
                            local expression_value_062 = array_value_078[bit_value_226];
                            if not expression_value_062 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_226) .. "]");
                                expression_value_062 = helper_function_014(bit_value_226, (conditional_not(true)));
                            end;
                            local_symbol_175 = expression_value_062;
                        end;
                        if table_value_030[local_symbol_175] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_175] = true;
                        end;
                        cached_helper_function_082(cached_bit_value_040, cached_helper_function_083(cached_bit_value_041, local_symbol_175));
                    end,
                    LENGTH = function(param_609)
                        local bit_value_227 = bit32.band(bit32.rshift(param_609, 8), 255);
                        local bit_value_228 = bit32.band(bit32.rshift(param_609, 16), 255);
                        local cached_helper_function_084 = helper_function_030;
                        local cached_bit_value_042 = bit_value_227;
                        local cached_helper_function_085 = helper_function_049;
                        local cached_bit_value_043 = bit_value_227;
                        local local_symbol_176;
                        if table_value_044[bit_value_228] then
                            local_symbol_176 = helper_function_017(bit_value_228, table_value_044[bit_value_228]);
                        else
                            local expression_value_063 = array_value_078[bit_value_228];
                            if not expression_value_063 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_228) .. "]");
                                expression_value_063 = helper_function_014(bit_value_228, (conditional_not(true)));
                            end;
                            local_symbol_176 = expression_value_063;
                        end;
                        if table_value_030[local_symbol_176] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_176] = true;
                        end;
                        cached_helper_function_084(cached_bit_value_042, cached_helper_function_085(cached_bit_value_043, local_symbol_176));
                    end,
                    NATIVECALL = function(_)
                        local string_value_041 = table_value_022[#table_value_022];
                        if string_value_041 and string_value_041.t == "comment" and string.sub(string_value_041.text, 1, 12) == "<NATIVECALL>" then
                            string_value_041.stack = string_value_041.stack + 1;
                            string_value_041.text = "<NATIVECALL>" .. " (x" .. string_value_041.stack .. ")";
                        else
                            table_value_042 = is_point_in_range("<NATIVECALL>");
                            helper_function_010();
                        end;
                        helper_function_031();
                    end,
                    BREAK = function(_)
                        local string_value_042 = table_value_022[#table_value_022];
                        if string_value_042 and string_value_042.t == "comment" and string.sub(string_value_042.text, 1, 12) == "<DEBUGBREAK>" then
                            string_value_042.stack = string_value_042.stack + 1;
                            string_value_042.text = "<DEBUGBREAK>" .. " (x" .. string_value_042.stack .. ")";
                        else
                            table_value_042 = is_point_in_range("<DEBUGBREAK>");
                            helper_function_010();
                        end;
                        helper_function_031();
                    end,
                    NOP = function(_)
                        local string_value_043 = table_value_022[#table_value_022];
                        if string_value_043 and string_value_043.t == "comment" and string.sub(string_value_043.text, 1, 5) == "<NOP>" then
                            string_value_043.stack = string_value_043.stack + 1;
                            string_value_043.text = "<NOP>" .. " (x" .. string_value_043.stack .. ")";
                        else
                            table_value_042 = is_point_in_range("<NOP>");
                            helper_function_010();
                        end;
                        helper_function_031();
                    end,
                    COVERAGE = function(_)
                        local string_value_044 = table_value_022[#table_value_022];
                        if string_value_044 and string_value_044.t == "comment" and string.sub(string_value_044.text, 1, 10) == "<COVERAGE>" then
                            string_value_044.stack = string_value_044.stack + 1;
                            string_value_044.text = "<COVERAGE>" .. " (x" .. string_value_044.stack .. ")";
                        else
                            table_value_042 = is_point_in_range("<COVERAGE>");
                            helper_function_010();
                        end;
                        helper_function_031();
                    end
                };
                local table_value_150 = {};
                for opcode_value_016, item_098 in pairs(local_symbol_132) do
                    local opcode_value_017 = opcode_def_by_name[opcode_value_016];
                    if opcode_value_017 then
                        table_value_150[opcode_value_017.opcode] = item_098;
                    end;
                end;
                local _ = {};
                local function helper_function_099(param_610, param_611)
                    local cached_table_value_007 = table_value_022;
                    table_value_022 = param_610;
                    for _, item_099 in ipairs(param_611) do
                        if local_symbol_025 < item_099.index then
                            local_symbol_025 = item_099.index;
                            local_symbol_024 = item_099.code_index;
                            local opcode_value_018 = table_value_041[local_symbol_025];
                            local opcode_value_019 = table_value_150[opcode_value_018.opcode];
                            if opcode_value_019 then
                                helper_function_029();
                                opcode_value_019(opcode_value_018.inst);
                                if not local_symbol_031 then
                                    error(opcode_value_018.opname);
                                end;
                            else
                                helper_function_012((("%*: Skipped instruction %*"):format(cached_prefix_warning, opcode_value_018.opname)));
                            end;
                        end;
                    end;
                    table_value_022 = cached_table_value_007;
                end;
                local helper_function_100 = nil;
                local function helper_function_101(_, _)
                    helper_function_031();
                end;
                local function helper_function_102(param_612, _)
                    local bit_value_229 = bit32.band(bit32.rshift(param_612, 8), 255);
                    local bit_value_230 = table_value_026[local_symbol_024];
                    local cached_ranges_equal = ranges_equal;
                    local cached_bit_value_044 = bit_value_230;
                    local local_symbol_177;
                    if table_value_044[bit_value_229] then
                        local_symbol_177 = helper_function_017(bit_value_229, table_value_044[bit_value_229]);
                    else
                        local expression_value_064 = array_value_078[bit_value_229];
                        if not expression_value_064 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_229) .. "]");
                            expression_value_064 = helper_function_014(bit_value_229, (conditional_not(true)));
                        end;
                        local_symbol_177 = expression_value_064;
                    end;
                    if table_value_030[local_symbol_177] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_177] = true;
                    end;
                    cached_ranges_equal(cached_bit_value_044, local_symbol_177);
                    helper_function_031();
                end;
                local function helper_function_103(param_613, _)
                    local bit_value_231 = bit32.band(bit32.rshift(param_613, 8), 255);
                    local bit_value_232 = cached_code_001[local_symbol_024 + 1];
                    if not bit_value_232 then
                        error("Expected aux");
                    end;
                    local cached_bit_value_045 = bit_value_232;
                    bit_value_232 = table_value_026[local_symbol_024];
                    local cached_ranges_equal_001 = ranges_equal;
                    local cached_bit_value_046 = bit_value_232;
                    local local_symbol_178;
                    if table_value_044[bit_value_231] then
                        local_symbol_178 = helper_function_017(bit_value_231, table_value_044[bit_value_231]);
                    else
                        local expression_value_065 = array_value_078[bit_value_231];
                        if not expression_value_065 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_231) .. "]");
                            expression_value_065 = helper_function_014(bit_value_231, (conditional_not(true)));
                        end;
                        local_symbol_178 = expression_value_065;
                    end;
                    if table_value_030[local_symbol_178] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_178] = true;
                    end;
                    cached_ranges_equal_001(cached_bit_value_046, local_symbol_178);
                    cached_ranges_equal_001 = ranges_equal;
                    cached_bit_value_046 = bit_value_232;
                    if table_value_044[cached_bit_value_045] then
                        local_symbol_178 = helper_function_017(cached_bit_value_045, table_value_044[cached_bit_value_045]);
                    else
                        local expression_value_066 = array_value_078[cached_bit_value_045];
                        if not expression_value_066 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_bit_value_045) .. "]");
                            expression_value_066 = helper_function_014(cached_bit_value_045, (conditional_not(true)));
                        end;
                        local_symbol_178 = expression_value_066;
                    end;
                    if table_value_030[local_symbol_178] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_178] = true;
                    end;
                    cached_ranges_equal_001(cached_bit_value_046, local_symbol_178);
                    helper_function_031();
                end;
                local function helper_function_104(param_614, _)
                    local bit_value_233 = bit32.band(bit32.rshift(param_614, 8), 255);
                    if not cached_code_001[local_symbol_024 + 1] then
                        error("Expected aux");
                    end;
                    local diagnostic_value_002 = table_value_026[local_symbol_024];
                    local cached_ranges_equal_002 = ranges_equal;
                    local cached_diagnostic_value_001 = diagnostic_value_002;
                    local local_symbol_179;
                    if table_value_044[bit_value_233] then
                        local_symbol_179 = helper_function_017(bit_value_233, table_value_044[bit_value_233]);
                    else
                        local expression_value_067 = array_value_078[bit_value_233];
                        if not expression_value_067 then
                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_233) .. "]");
                            expression_value_067 = helper_function_014(bit_value_233, (conditional_not(true)));
                        end;
                        local_symbol_179 = expression_value_067;
                    end;
                    if table_value_030[local_symbol_179] then
                        helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                    else
                        table_value_030[local_symbol_179] = true;
                    end;
                    cached_ranges_equal_002(cached_diagnostic_value_001, local_symbol_179);
                    helper_function_031();
                end;
                local table_value_151 = {
                    JUMP = helper_function_101,
                    JUMPX = helper_function_101,
                    JUMPBACK = helper_function_101,
                    JUMPIF = helper_function_102,
                    JUMPIFNOT = helper_function_102,
                    JUMPIFEQ = helper_function_103,
                    JUMPIFLE = helper_function_103,
                    JUMPIFLT = helper_function_103,
                    JUMPIFNOTEQ = helper_function_103,
                    JUMPIFNOTLE = helper_function_103,
                    JUMPIFNOTLT = helper_function_103,
                    JUMPXEQKNIL = helper_function_104,
                    JUMPXEQKB = helper_function_104,
                    JUMPXEQKN = helper_function_104,
                    JUMPXEQKS = helper_function_104,
                    FORNLOOP = function(param_615, _)
                        local bit_value_234 = bit32.band(bit32.rshift(param_615, 8), 255);
                        local bit_value_235 = table_value_026[local_symbol_024];
                        local cached_ranges_equal_003 = ranges_equal;
                        local cached_bit_value_047 = bit_value_235;
                        local local_symbol_180;
                        if table_value_044[bit_value_234] then
                            local_symbol_180 = helper_function_017(bit_value_234, table_value_044[bit_value_234]);
                        else
                            local expression_value_068 = array_value_078[bit_value_234];
                            if not expression_value_068 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_234) .. "]");
                                expression_value_068 = helper_function_014(bit_value_234, (conditional_not(true)));
                            end;
                            local_symbol_180 = expression_value_068;
                        end;
                        if table_value_030[local_symbol_180] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_180] = true;
                        end;
                        cached_ranges_equal_003(cached_bit_value_047, local_symbol_180);
                        cached_ranges_equal_003 = ranges_equal;
                        cached_bit_value_047 = bit_value_235;
                        local condition_value_106 = bit_value_234 + 1;
                        if table_value_044[condition_value_106] then
                            local_symbol_180 = helper_function_017(condition_value_106, table_value_044[condition_value_106]);
                        else
                            local expression_value_069 = array_value_078[condition_value_106];
                            if not expression_value_069 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(condition_value_106) .. "]");
                                expression_value_069 = helper_function_014(condition_value_106, (conditional_not(true)));
                            end;
                            local_symbol_180 = expression_value_069;
                        end;
                        if table_value_030[local_symbol_180] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_180] = true;
                        end;
                        cached_ranges_equal_003(cached_bit_value_047, local_symbol_180);
                        helper_function_031();
                    end,
                    FORGLOOP = function(param_616, param_617)
                        local bit_value_236 = bit32.band(bit32.rshift(param_616, 8), 255);
                        local bit_value_237 = table_value_026[local_symbol_024];
                        local cached_ranges_equal_004 = ranges_equal;
                        local cached_bit_value_048 = bit_value_237;
                        local local_symbol_181;
                        if table_value_044[bit_value_236] then
                            local_symbol_181 = helper_function_017(bit_value_236, table_value_044[bit_value_236]);
                        else
                            local expression_value_070 = array_value_078[bit_value_236];
                            if not expression_value_070 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(bit_value_236) .. "]");
                                expression_value_070 = helper_function_014(bit_value_236, (conditional_not(true)));
                            end;
                            local_symbol_181 = expression_value_070;
                        end;
                        if table_value_030[local_symbol_181] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_181] = true;
                        end;
                        cached_ranges_equal_004(cached_bit_value_048, local_symbol_181);
                        cached_ranges_equal_004 = ranges_equal;
                        cached_bit_value_048 = bit_value_237;
                        local condition_value_107 = bit_value_236 + 1;
                        if table_value_044[condition_value_107] then
                            local_symbol_181 = helper_function_017(condition_value_107, table_value_044[condition_value_107]);
                        else
                            local expression_value_071 = array_value_078[condition_value_107];
                            if not expression_value_071 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(condition_value_107) .. "]");
                                expression_value_071 = helper_function_014(condition_value_107, (conditional_not(true)));
                            end;
                            local_symbol_181 = expression_value_071;
                        end;
                        if table_value_030[local_symbol_181] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_181] = true;
                        end;
                        cached_ranges_equal_004(cached_bit_value_048, local_symbol_181);
                        cached_ranges_equal_004 = ranges_equal;
                        cached_bit_value_048 = bit_value_237;
                        condition_value_107 = bit_value_236 + 2;
                        if table_value_044[condition_value_107] then
                            local_symbol_181 = helper_function_017(condition_value_107, table_value_044[condition_value_107]);
                        else
                            local expression_value_072 = array_value_078[condition_value_107];
                            if not expression_value_072 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(condition_value_107) .. "]");
                                expression_value_072 = helper_function_014(condition_value_107, (conditional_not(true)));
                            end;
                            local_symbol_181 = expression_value_072;
                        end;
                        if table_value_030[local_symbol_181] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[local_symbol_181] = true;
                        end;
                        cached_ranges_equal_004(cached_bit_value_048, local_symbol_181);
                        assert(param_617);
                        for _ = 1, bit32.band(param_617, 255) do

                        end;
                        helper_function_031();
                    end
                };
                local function helper_function_105(param_618, param_619, param_620)
                    local local_symbol_182 = nil;
                    if param_620 then
                        local_symbol_182 = table_value_022;
                        table_value_022 = param_618;
                        proto_value_006 = proto_value_006 + 1;
                    end;
                    local condition_value_108 = false;
                    if param_619.analysis_failed then
                        if param_619.type == "single" and #param_619.data == 0 and not param_619.jump then
                            condition_value_108 = true;
                        else
                            helper_function_012((("%*: [%*] %*. Error Block %* start (CF ANALYSIS FAILED)"):format(cached_prefix_error, param_619.actual_code_index, param_619.actual_index, param_619.hl_index)));
                        end;
                    end;
                    if not condition_value_108 then
                        if param_619.type == "single" then
                            helper_function_099(param_618, param_619.data);
                            local l__visitor_9 = param_619._visitor;
                            if l__visitor_9 then
                                local cached_code_003 = l__visitor_9.code;
                                local opcode_value_020 = table_value_151[cached_code_003.opname];
                                if opcode_value_020 then
                                    helper_function_029();
                                    opcode_value_020(cached_code_003.inst, cached_code_003.aux);
                                end;
                            end;
                        elseif param_619.type == "oneblockwhile" then
                            local table_value_152 = {};
                            local cached_data_006 = param_619.data;
                            local local_symbol_183 = nil;
                            local cached_for_info = cached_data_006.for_info;
                            if cached_for_info then
                                local_symbol_183 = {
                                    t = "for",
                                    lines = table_value_022,
                                    reads = {},
                                    writes = {},
                                    code = table_value_152,
                                    for_info = cached_for_info
                                };
                                local cached_variables = cached_for_info.variables;
                                assert(cached_variables);
                                for expression_value_073, item_100 in ipairs(cached_variables) do
                                    item_100.init_expr = local_symbol_183;
                                    item_100.var_num = expression_value_073;
                                    local cached_local_symbol_018 = local_symbol_183;
                                    table.insert(cached_local_symbol_018.writes, item_100);
                                    table.insert(item_100.writes, cached_local_symbol_018);
                                end;
                                local cached_type_006 = cached_for_info.type;
                                if cached_type_006 == "numeric" then
                                    local cached_args = cached_for_info.args;
                                    local cached_index_reg_001 = cached_args.index_reg;
                                    local local_symbol_184;
                                    if table_value_044[cached_index_reg_001] then
                                        local_symbol_184 = helper_function_017(cached_index_reg_001, table_value_044[cached_index_reg_001]);
                                    else
                                        local condition_value_109 = array_value_078[cached_index_reg_001];
                                        if not condition_value_109 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_index_reg_001) .. "]");
                                            condition_value_109 = helper_function_014(cached_index_reg_001, (conditional_not(true)));
                                        end;
                                        local_symbol_184 = condition_value_109;
                                    end;
                                    cached_args.index_expr = local_symbol_184;
                                    assert(cached_args.index_expr);
                                    ranges_equal(local_symbol_183, cached_args.index_expr);
                                    cached_index_reg_001 = cached_args.end_reg;
                                    if table_value_044[cached_index_reg_001] then
                                        local_symbol_184 = helper_function_017(cached_index_reg_001, table_value_044[cached_index_reg_001]);
                                    else
                                        local condition_value_110 = array_value_078[cached_index_reg_001];
                                        if not condition_value_110 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_index_reg_001) .. "]");
                                            condition_value_110 = helper_function_014(cached_index_reg_001, (conditional_not(true)));
                                        end;
                                        local_symbol_184 = condition_value_110;
                                    end;
                                    cached_args.end_expr = local_symbol_184;
                                    assert(cached_args.end_expr);
                                    ranges_equal(local_symbol_183, cached_args.end_expr);
                                    cached_index_reg_001 = cached_args.step_reg;
                                    if table_value_044[cached_index_reg_001] then
                                        local_symbol_184 = helper_function_017(cached_index_reg_001, table_value_044[cached_index_reg_001]);
                                    else
                                        local condition_value_111 = array_value_078[cached_index_reg_001];
                                        if not condition_value_111 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_index_reg_001) .. "]");
                                            condition_value_111 = helper_function_014(cached_index_reg_001, (conditional_not(true)));
                                        end;
                                        local_symbol_184 = condition_value_111;
                                    end;
                                    cached_args.step_expr = local_symbol_184;
                                    assert(cached_args.step_expr);
                                    ranges_equal(local_symbol_183, cached_args.step_expr);
                                    assert(#cached_variables == 1);
                                    table_value_044[cached_args.index_reg] = cached_variables[1];
                                elseif cached_type_006 == "generic" then
                                    local cached_args_001 = cached_for_info.args;
                                    local cached_generator_reg = cached_args_001.generator_reg;
                                    local local_symbol_185;
                                    if table_value_044[cached_generator_reg] then
                                        local_symbol_185 = helper_function_017(cached_generator_reg, table_value_044[cached_generator_reg]);
                                    else
                                        local condition_value_112 = array_value_078[cached_generator_reg];
                                        if not condition_value_112 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_generator_reg) .. "]");
                                            condition_value_112 = helper_function_014(cached_generator_reg, (conditional_not(true)));
                                        end;
                                        local_symbol_185 = condition_value_112;
                                    end;
                                    cached_args_001.generator_expr = local_symbol_185;
                                    cached_generator_reg = cached_args_001.state_reg;
                                    if table_value_044[cached_generator_reg] then
                                        local_symbol_185 = helper_function_017(cached_generator_reg, table_value_044[cached_generator_reg]);
                                    else
                                        local condition_value_113 = array_value_078[cached_generator_reg];
                                        if not condition_value_113 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_generator_reg) .. "]");
                                            condition_value_113 = helper_function_014(cached_generator_reg, (conditional_not(true)));
                                        end;
                                        local_symbol_185 = condition_value_113;
                                    end;
                                    cached_args_001.state_expr = local_symbol_185;
                                    cached_generator_reg = cached_args_001.index_reg;
                                    if table_value_044[cached_generator_reg] then
                                        local_symbol_185 = helper_function_017(cached_generator_reg, table_value_044[cached_generator_reg]);
                                    else
                                        local condition_value_114 = array_value_078[cached_generator_reg];
                                        if not condition_value_114 then
                                            helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_generator_reg) .. "]");
                                            condition_value_114 = helper_function_014(cached_generator_reg, (conditional_not(true)));
                                        end;
                                        local_symbol_185 = condition_value_114;
                                    end;
                                    cached_args_001.index_expr = local_symbol_185;
                                    for expression_value_074, item_101 in ipairs(cached_variables) do
                                        assert(item_101.var_num == expression_value_074);
                                        table_value_044[cached_for_info.variables_reg_range.beginning + expression_value_074 - 1] = item_101;
                                    end;
                                else
                                    error((("Unknown for loop type %*"):format(cached_type_006)));
                                end;
                                local l__visitor_10 = param_619._visitor;
                                assert(l__visitor_10);
                                local local_symbol_186 = table_value_026[l__visitor_10.code.code_index];
                                local cached_local_symbol_019 = local_symbol_183;
                                table.clear(local_symbol_186);
                                for local_symbol_187, item_102 in pairs(cached_local_symbol_019) do
                                    local_symbol_186[local_symbol_187] = item_102;
                                end;
                                helper_function_105(table_value_152, table_value_043[cached_data_006.code], true);
                            else
                                local_symbol_183 = {
                                    t = "while",
                                    lines = table_value_022,
                                    reads = {},
                                    writes = {},
                                    code = table_value_152,
                                    expr = nil
                                };
                                helper_function_105(table_value_152, table_value_043[cached_data_006.code], true);
                            end;
                            for _, item_103 in ipairs(table_value_152) do
                                item_103.parent = local_symbol_183;
                            end;
                            table.insert(table_value_022, local_symbol_183);
                        elseif param_619.type == "sequential" then
                            for _, item_104 in ipairs(param_619.data) do
                                helper_function_105(param_618, table_value_043[item_104]);
                            end;
                        elseif not (param_619.type ~= "ifthen") or param_619.type == "ifthenelse" then
                            local cached_data_007 = param_619.data;
                            local condition_value_115 = true;
                            local cached_condition_003 = cached_data_007.condition;
                            while true do
                                if cached_condition_003.type == "and" then
                                    local cached_lhs_001 = cached_condition_003.lhs;
                                    if type(cached_lhs_001) == "table" and cached_lhs_001.type ~= "reg" then
                                        condition_value_115 = nil;
                                        break;
                                    else
                                        local cached_rhs_003 = cached_condition_003.rhs;
                                        if type(cached_rhs_003) == "table" then
                                            if cached_rhs_003.type == "and" then
                                                cached_condition_003 = cached_rhs_003;
                                            elseif not (cached_rhs_003.type == "reg") then
                                                condition_value_115 = nil;
                                                break;
                                            else
                                                break;
                                            end;
                                        else
                                            break;
                                        end;
                                    end;
                                else
                                    condition_value_115 = nil;
                                    break;
                                end;
                            end;
                            local local_symbol_188 = helper_function_100(param_618, cached_data_007.condition, condition_value_115, true);
                            local table_value_153 = {};
                            helper_function_105(table_value_153, table_value_043[cached_data_007.pass], true);
                            local local_symbol_189 = nil;
                            if cached_data_007.else_ then
                                local_symbol_189 = {};
                                helper_function_105(local_symbol_189, table_value_043[cached_data_007.else_], true);
                            end;
                            local table_value_154 = {
                                t = "if",
                                lines = table_value_022,
                                reads = {},
                                writes = {},
                                pass = table_value_153,
                                elseifs = {},
                                else_ = local_symbol_189,
                                expr = local_symbol_188
                            };
                            for _, item_105 in ipairs(table_value_153) do
                                item_105.parent = table_value_154;
                            end;
                            if local_symbol_189 then
                                for _, item_106 in ipairs(local_symbol_189) do
                                    item_106.parent = table_value_154;
                                end;
                            end;
                            table.insert(table_value_022, table_value_154);
                        else
                            error((("Unknown hl_block type \"%*\""):format(param_619.type)));
                        end;
                        local cached_jump_007 = param_619.jump;
                        if cached_jump_007 then
                            local cached_type_007 = cached_jump_007.type;
                            if cached_type_007 == "break" then
                                helper_function_025();
                            elseif cached_type_007 == "continue" then
                                helper_function_026();
                            elseif cached_type_007 == "goto" then
                                helper_function_027(cached_jump_007.destination);
                            else
                                error((("Unknown jump_type \"%*\""):format(cached_type_007)));
                            end;
                            helper_function_010();
                        end;
                        if param_619.analysis_failed then
                            helper_function_012((("%*: [%*] %*. Error Block %* end (CF ANALYSIS FAILED)"):format(cached_prefix_error, table_value_082[param_619.code_index], table_value_083[param_619.index], param_619.hl_index)));
                        end;
                    end;
                    if param_620 then
                        table_value_022 = local_symbol_182;
                        proto_value_006 = proto_value_006 - 1;
                    end;
                end;
                helper_function_100 = function(param_621, param_622, param_623, param_624)
                    if param_622.type == "reg" then
                        assert(param_622.code);
                        assert(type(param_622.lhs) == "number");
                        local number_value_002 = #table_value_022;
                        local number_value_003 = table_value_022[#table_value_022];
                        helper_function_105(param_621, table_value_043[param_622.code]);
                        local number_value_004;
                        if type(param_622.lhs) == "number" then
                            local cached_lhs_002 = param_622.lhs;
                            if table_value_044[cached_lhs_002] then
                                number_value_004 = helper_function_017(cached_lhs_002, table_value_044[cached_lhs_002]);
                            else
                                local expression_value_075 = array_value_078[cached_lhs_002];
                                if not expression_value_075 then
                                    helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_lhs_002) .. "]");
                                    expression_value_075 = helper_function_014(cached_lhs_002, (conditional_not(true)));
                                end;
                                number_value_004 = expression_value_075;
                            end;
                        else
                            number_value_004 = param_622.lhs;
                        end;
                        local number_value_005 = nil;
                        if param_622.rhs then
                            if type(param_622.rhs) == "number" then
                                local cached_rhs_004 = param_622.rhs;
                                if table_value_044[cached_rhs_004] then
                                    number_value_005 = helper_function_017(cached_rhs_004, table_value_044[cached_rhs_004]);
                                else
                                    local expression_value_076 = array_value_078[cached_rhs_004];
                                    if not expression_value_076 then
                                        helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_rhs_004) .. "]");
                                        expression_value_076 = helper_function_014(cached_rhs_004, (conditional_not(true)));
                                    end;
                                    number_value_005 = expression_value_076;
                                end;
                            else
                                number_value_005 = param_622.rhs;
                            end;
                        end;
                        if not param_624 and number_value_002 < #table_value_022 and number_value_003 ~= table_value_022[#table_value_022] then
                            if param_623 then
                                table_value_036[table_value_092[table_value_043[param_622.code].index].index] = true;
                                local_symbol_022 = local_symbol_022 + 1;
                            else
                                local table_value_155 = {};
                                while number_value_002 < #table_value_022 do
                                    local local_symbol_190 = table.remove(table_value_022);
                                    assert(local_symbol_190);
                                    local cached_local_symbol_020 = local_symbol_190;
                                    cached_local_symbol_020.lines = table_value_155;
                                    table.insert(table_value_155, cached_local_symbol_020);
                                end;
                                local cached_number_value_001 = number_value_004;
                                if number_value_005 then
                                    local cached_number_value_002 = number_value_004;
                                    local cached_condition_004 = param_622.condition;
                                    cached_number_value_001 = helper_function_014(nil, (helper_function_004(cached_number_value_002, cached_condition_004, number_value_005)));
                                    param_622.condition = "exist";
                                    param_622.rhs = nil;
                                    number_value_005 = nil;
                                end;
                                table.insert(table_value_155, (helper_function_006(table_value_155, {
                                    cached_number_value_001
                                })));
                                local cached_INLINED = table_value_024.INLINED;
                                local local_symbol_191 = "INLINED";
                                local local_symbol_192 = cached_INLINED or 1;
                                while table_value_023[local_symbol_191] or table_value_018[local_symbol_191] do
                                    local_symbol_192 = local_symbol_192 + 1;
                                    local_symbol_191 = "INLINED" .. "_" .. local_symbol_192;
                                end;
                                table_value_024.INLINED = local_symbol_192;
                                local cached_local_symbol_021 = local_symbol_191;
                                cached_INLINED = is_point_in_named_range(cached_local_symbol_021, {
                                    beginning = -1,
                                    ending = -1
                                }, {});
                                number_value_004 = create_expression(helper_function_017(nil, cached_INLINED), {}, false);
                                local_symbol_191 = {
                                    t = "function",
                                    reads = {},
                                    writes = {},
                                    contributors = {},
                                    is_self_referencing = false,
                                    name = cached_local_symbol_021,
                                    varname = cached_INLINED,
                                    name_known = true,
                                    args = {},
                                    is_vararg = false,
                                    line_defined = -1,
                                    upvalues_count = 0,
                                    upvalues = {},
                                    ast = table_value_155
                                };
                                table.insert(local_symbol_191.writes, cached_INLINED);
                                table.insert(table_value_022, (helper_function_005(table_value_022, local_symbol_191, cached_INLINED, "local")));
                            end;
                        end;
                        param_622.lhs = number_value_004;
                        param_622.rhs = number_value_005;
                    end;
                    local number_value_006 = nil;
                    local cached_lhs_003 = param_622.lhs;
                    assert(cached_lhs_003);
                    if type(cached_lhs_003) == "number" then
                        local number_value_007;
                        if table_value_044[cached_lhs_003] then
                            number_value_007 = helper_function_017(cached_lhs_003, table_value_044[cached_lhs_003]);
                        else
                            local expression_value_077 = array_value_078[cached_lhs_003];
                            if not expression_value_077 then
                                helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_lhs_003) .. "]");
                                expression_value_077 = helper_function_014(cached_lhs_003, (conditional_not(true)));
                            end;
                            number_value_007 = expression_value_077;
                        end;
                        if table_value_030[number_value_007] then
                            helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                        else
                            table_value_030[number_value_007] = true;
                        end;
                        number_value_006 = number_value_007;
                        error("messgage");
                    else
                        number_value_006 = if cached_lhs_003.is_full_condition_t then helper_function_100(param_621, cached_lhs_003, param_623, param_624) else cached_lhs_003;
                    end;
                    param_622.lhs = number_value_006;
                    local number_value_008 = nil;
                    local cached_rhs_005 = param_622.rhs;
                    if cached_rhs_005 then
                        if type(cached_rhs_005) == "number" then
                            local number_value_009;
                            if table_value_044[cached_rhs_005] then
                                number_value_009 = helper_function_017(cached_rhs_005, table_value_044[cached_rhs_005]);
                            else
                                local expression_value_078 = array_value_078[cached_rhs_005];
                                if not expression_value_078 then
                                    helper_function_012(cached_prefix_warning .. ": Failed to evaluate expression, replaced with nil [" .. tostring(local_symbol_024) .. "." .. tostring(cached_rhs_005) .. "]");
                                    expression_value_078 = helper_function_014(cached_rhs_005, (conditional_not(true)));
                                end;
                                number_value_009 = expression_value_078;
                            end;
                            if table_value_030[number_value_009] then
                                helper_function_012(cached_prefix_error .. ": Expression was reused, decompilation is incorrect");
                            else
                                table_value_030[number_value_009] = true;
                            end;
                            number_value_008 = number_value_009;
                            error("messagee");
                        else
                            number_value_008 = if cached_rhs_005.is_full_condition_t then helper_function_100(param_621, cached_rhs_005, param_623) else cached_rhs_005;
                        end;
                    end;
                    if param_622.type ~= "reg" then
                        assert(number_value_008);
                        if param_622.type == "and" then
                            number_value_006 = helper_function_014(nil, (helper_function_003(number_value_006, number_value_008)));
                        elseif param_622.type == "or" then
                            number_value_006 = helper_function_038(nil, number_value_006, number_value_008);
                        else
                            error("Impossible!!!!!!!!!!!!!!!!!!!!!!!!!");
                        end;
                        number_value_008 = nil;
                    end;
                    if number_value_008 then
                        return helper_function_040(nil, number_value_006, param_622.condition, number_value_008);
                    elseif param_622.condition == "not exist" then
                        return helper_function_047(nil, number_value_006);
                    else
                        return number_value_006;
                    end;
                end;
                helper_function_105(table_value_022, helper_function_057());
                for _, item_107 in cached_constants_001 do
                    if item_107.type == 4 and type(item_107.value) == "number" then
                        item_107.value = helper_function_053(nil, item_107.value);
                    end;
                end;
                local_symbol_023:end_benchmark("AST Generation");
                current_function_context = cached_current_function_context;
                local_symbol_023:print_all_times();
                return table_value_022;
            end;
        end;
        helper_function_008 = function(param_625, param_626)
            local string_value_045 = helper_function_007();
            local string_value_046, string_value_047 = xpcall(helper_function_009, function(param_627)
                return tostring(param_627) .. "\nTraceback:\n" .. debug.traceback(nil, 2);
            end, param_625, param_626);
            local cached_table_value_008 = table_value_036;
            if string_value_046 then
                if local_symbol_022 > string_value_045.marked_condition_stop_points then
                    failed_instruction_count = string_value_045.global_failed_instructions_count;
                    table_value_019 = string_value_045.notices;
                    table_value_022 = string_value_045.lines;
                    table_value_031 = string_value_045.variable_mapped_long_string_constants;
                    table_value_032 = string_value_045.variable_mapped_long_string_constants_order;
                    table_value_033 = string_value_045.long_string_usage_counts;
                    table_value_034 = string_value_045.long_string_constant_already_used;
                    local_symbol_021 = string_value_045.long_string_variable_count;
                    table_value_035 = string_value_045.lines_had_skipped_return;
                    table_value_036 = string_value_045.condition_stop_points;
                    local_symbol_022 = string_value_045.marked_condition_stop_points;
                    table_value_036 = cached_table_value_008;
                    return helper_function_008(param_625, param_626);
                else
                    return string_value_047;
                end;
            else
                failed_instruction_count = string_value_045.global_failed_instructions_count;
                table_value_019 = string_value_045.notices;
                table_value_022 = string_value_045.lines;
                table_value_031 = string_value_045.variable_mapped_long_string_constants;
                table_value_032 = string_value_045.variable_mapped_long_string_constants_order;
                table_value_033 = string_value_045.long_string_usage_counts;
                table_value_034 = string_value_045.long_string_constant_already_used;
                local_symbol_021 = string_value_045.long_string_variable_count;
                table_value_035 = string_value_045.lines_had_skipped_return;
                table_value_036 = string_value_045.condition_stop_points;
                local_symbol_022 = string_value_045.marked_condition_stop_points;
                if param_625.debug_name then
                    return {
                        (is_point_in_range(cached_prefix_error .. ": Failed to generate AST for function `" .. tostring(param_625.debug_name) .. "`:\n" .. tostring(string_value_047)))
                    };
                else
                    return {
                        (is_point_in_range(cached_prefix_error .. ": Failed to generate AST for unnamed function:\n" .. tostring(string_value_047)))
                    };
                end;
            end;
        end;
        local_symbol_009:end_benchmark("Global Initialization");
        local_symbol_009:start_benchmark("Global Mapping");
        for _, item_108 in pairs(array_value_069) do
            local bit_value_238 = 0;
            local cached_code_004 = item_108.code;
            local bit_value_239 = #cached_code_004;
            while bit_value_238 < bit_value_239 do
                local opcode_value_021 = opcode_def_by_encoded_byte[bit32.band(cached_code_004[bit_value_238], 255)];
                if opcode_value_021 then
                    if opcode_value_021.opname == "SETGLOBAL" then
                        local opcode_value_022 = cached_code_004[bit_value_238 + 1];
                        local opcode_value_023 = item_108.constants[opcode_value_022];
                        if opcode_value_023 then
                            if opcode_value_023.type == 3 then
                                table_value_018[opcode_value_023.value] = true;
                            else
                                local condition_value_116 = CONSTANT_TYPE_NAMES[opcode_value_023.type];
                                if condition_value_116 then
                                    local table_value_156 = {
                                        type = "warning",
                                        content = ("A SETGLOBAL instruction specified a%* %* constant. Expected a string."):format(VOWELS_BY_CHAR[string.sub(condition_value_116, 1, 1)] and "n" or "", condition_value_116)
                                    };
                                    table.insert(table_value_019, table_value_156);
                                else
                                    table.insert(table_value_019, {
                                        type = "warning",
                                        content = "A SETGLOBAL instruction specified a constant with an invalid type."
                                    });
                                end;
                            end;
                        else
                            table.insert(table_value_019, {
                                type = "warning",
                                content = "A SETGLOBAL instruction specified an invalid constant."
                            });
                        end;
                    end;
                    bit_value_238 = bit_value_238 + opcode_value_021.size;
                else
                    bit_value_238 = bit_value_238 + 1;
                end;
            end;
        end;
        local_symbol_009:end_benchmark("Global Mapping");
        local_symbol_009:start_benchmark("Global Decompilation");
        local local_symbol_193 = helper_function_008(array_value_068);
        local_symbol_009:end_benchmark("Global Decompilation");
        local_symbol_009:start_benchmark("Global High Level Reductions");
        local local_symbol_194 = nil;
        local function _()
            local_symbol_194 = local_symbol_194 + 1;
        end;
        local helper_function_106 = nil;
        local helper_function_107 = nil;
        local local_symbol_195 = nil;
        local function helper_function_108(param_628)
            helper_function_107(param_628.lhs);
            if param_628.rhs then
                helper_function_107(param_628.rhs);
            end;
        end;
        local function helper_function_109(param_629)
            helper_function_107(param_629.rhs);
        end;
        local function helper_function_110(_)

        end;
        local local_symbol_196 = nil;
        local table_value_157 = {
            ["nil"] = helper_function_110,
            boolean = helper_function_110,
            global = helper_function_110,
            varargs = helper_function_110,
            addition = helper_function_108,
            subtraction = helper_function_108,
            multiplication = helper_function_108,
            division = helper_function_108,
            exponentiation = helper_function_108,
            ["floor division"] = helper_function_108,
            modulus = helper_function_108,
            ["and"] = helper_function_108,
            ["or"] = helper_function_108,
            condition = helper_function_108,
            negate = helper_function_109,
            ["not"] = function(param_630)
                local condition_value_117 = 1;
                local cached_param_020 = param_630;
                while cached_param_020.rhs.t == "not" do
                    condition_value_117 = condition_value_117 + 1;
                    cached_param_020 = cached_param_020.rhs;
                end;
                local cached_rhs_006 = cached_param_020.rhs;
                if condition_value_117 > 2 then
                    if condition_value_117 % 2 == 0 then
                        param_630.rhs.rhs = cached_rhs_006;
                    else
                        param_630.rhs = cached_rhs_006;
                    end;
                end;
                helper_function_107(param_630.rhs);
            end,
            length = helper_function_109,
            concatenation = function(param_631)
                for _, item_109 in ipairs(param_631.exprs) do
                    helper_function_107(item_109);
                end;
            end,
            name = function(param_632)
                local cached_override_expr_002 = param_632.name.override_expr;
                if cached_override_expr_002 then
                    helper_function_107(cached_override_expr_002);
                end;
            end,
            constant = function(param_633)
                local cached_const = param_633.const;
                if cached_const.type == 4 then
                    helper_function_107(cached_const.value);
                end;
            end,
            ["constant index"] = function(param_634)
                local cached_index_003 = param_634.index;
                if cached_index_003.type == 4 then
                    helper_function_107(cached_index_003.value);
                end;
                helper_function_107(param_634.table);
            end,
            ["new table"] = function(param_635)
                for condition_value_118, item_110 in pairs(param_635.initializers) do
                    if type(condition_value_118) == "table" then
                        helper_function_107(condition_value_118);
                        helper_function_107(item_110);
                    else
                        helper_function_107(item_110);
                    end;
                end;
            end,
            ["function"] = function(param_636)
                helper_function_106(param_636.ast);
            end,
            call = function(param_637)
                helper_function_107(param_637.func);
                for _, item_111 in ipairs(param_637.args) do
                    helper_function_107(item_111);
                end;
            end,
            ["get table"] = function(param_638)
                helper_function_107(param_638.table);
                helper_function_107(param_638.index);
            end
        };
        helper_function_107 = function(param_639)
            if local_symbol_196[param_639] then
                return;
            else
                local_symbol_196[param_639] = true;
                local expression_value_079 = table_value_157[param_639.t];
                if expression_value_079 then
                    expression_value_079(param_639);
                    return;
                else
                    error((("Unknown expr type %*"):format(param_639.t)));
                    return;
                end;
            end;
        end;
        local function helper_function_111(param_640)
            local cached_condition_005 = param_640.condition;
            if cached_condition_005 ~= "exist" and cached_condition_005 ~= "not exist" then
                local cached_rhs_007 = param_640.rhs;
                if type(cached_rhs_007) == "number" then
                    error("This should NOT have happened");
                    return;
                elseif cached_rhs_007.is_full_condition_t then
                    helper_function_111(cached_rhs_007);
                    return;
                else
                    helper_function_107(cached_rhs_007);
                end;
            end;
        end;
        local function helper_function_112(param_641, param_642, param_643, param_644, param_645)
            local cached_lines = param_641.lines;
            local condition_value_119 = table.find(cached_lines, param_641);
            assert(condition_value_119);
            assert(param_642.t == "function");
            if param_645 then
                assert(param_641.t == "set table");
            end;
            local condition_value_120 = helper_function_005(cached_lines, param_642, param_643, param_644, param_645);
            condition_value_120.reads = param_641.reads;
            condition_value_120.writes = param_641.writes;
            for _, item_112 in ipairs(param_641.reads) do
                local cached_reads = item_112.reads;
                local local_symbol_197 = table.find(cached_reads, param_641);
                assert(local_symbol_197);
                cached_reads[local_symbol_197] = condition_value_120;
            end;
            for _, item_113 in ipairs(param_641.writes) do
                local cached_writes = item_113.writes;
                local local_symbol_198 = table.find(cached_writes, param_641);
                assert(local_symbol_198);
                cached_writes[local_symbol_198] = condition_value_120;
            end;
            cached_lines[condition_value_119] = condition_value_120;
            local_symbol_194 = local_symbol_194 + 1;
        end;
        local function helper_function_113(_)

        end;
        local function helper_function_114(param_646)
            local cached_value_003 = param_646.value;
            while cached_value_003.t == "name" do
                local cached_override_expr_003 = cached_value_003.name.override_expr;
                if cached_override_expr_003 then
                    cached_value_003 = cached_override_expr_003;
                else
                    break;
                end;
            end;
            local cached_value_004 = cached_value_003;
            cached_value_003 = param_646.lines;
            assert(cached_value_003[local_symbol_195] == param_646);
            local condition_value_121 = local_symbol_195 + 1;
            while true do
                local condition_value_122 = cached_value_003[condition_value_121];
                if condition_value_122 and condition_value_122.t == "set table" then
                    local cached_table_001 = condition_value_122.table;
                    while cached_table_001.t == "name" do
                        local cached_override_expr_004 = cached_table_001.name.override_expr;
                        if cached_override_expr_004 then
                            cached_table_001 = cached_override_expr_004;
                        else
                            break;
                        end;
                    end;
                    local cached_table_002 = cached_table_001;
                    if cached_table_002.t == "name" then
                        cached_table_001 = cached_table_002.name;
                        if cached_value_004 == cached_table_001.init_expr then
                            local cached_value_005 = condition_value_122.value;
                            while cached_value_005.t == "name" do
                                local cached_override_expr_005 = cached_value_005.name.override_expr;
                                if cached_override_expr_005 then
                                    cached_value_005 = cached_override_expr_005;
                                else
                                    break;
                                end;
                            end;
                            local cached_value_006 = cached_value_005;
                            if cached_value_006.t == "name" then
                                if not (cached_value_006.name.init_expr and cached_value_006.name ~= cached_table_001) then
                                    break;
                                end;
                            elseif cached_value_006.contributors[cached_value_004] then
                                break;
                            end;
                            local cached_key = condition_value_122.key;
                            while cached_key.t == "name" do
                                local cached_override_expr_006 = cached_key.name.override_expr;
                                if cached_override_expr_006 then
                                    cached_key = cached_override_expr_006;
                                else
                                    break;
                                end;
                            end;
                            cached_value_005 = cached_key;
                            if not cached_value_005.contributors[cached_value_004] then
                                if cached_value_005.t == "constant" then
                                    cached_key = cached_value_005.const;
                                    if cached_key.type == 2 then
                                        local cached_value_007 = cached_key.value;
                                        table.insert(cached_value_004.initializers_order, cached_value_007);
                                        cached_value_004.initializers[cached_value_007] = cached_value_006;
                                        table.remove(cached_value_003, condition_value_121);
                                        make_location_range(condition_value_122, cached_table_001);
                                        local_symbol_194 = local_symbol_194 + 1;
                                        continue;
                                    end;
                                end;
                                table.insert(cached_value_004.initializers_order, cached_value_005);
                                cached_value_004.initializers[cached_value_005] = cached_value_006;
                                table.remove(cached_value_003, condition_value_121);
                                make_location_range(condition_value_122, cached_table_001);
                                local_symbol_194 = local_symbol_194 + 1;
                            else
                                break;
                            end;
                        else
                            break;
                        end;
                    else
                        break;
                    end;
                else
                    break;
                end;
            end;
        end;
        local function _(param_647)
            if param_647.t == "if" and not param_647.else_ and #param_647.elseifs == 0 then
                local cached_pass = param_647.pass;
                if #cached_pass == 1 and cached_pass[1].t == "break" then
                    return true;
                end;
            end;
        end;
        local function helper_function_115(param_648)
            if table_value_035[param_648] then
                return true;
            elseif #param_648 == 0 then
                return false;
            else
                local condition_value_123 = param_648[#param_648];
                if not (condition_value_123.t ~= "return" and condition_value_123.t ~= "break") or condition_value_123.t == "continue" then
                    return true, condition_value_123;
                elseif condition_value_123.t == "do" then
                    return helper_function_115(condition_value_123.content);
                else
                    return false;
                end;
            end;
        end;
        local function _(param_649)
            if not param_649 then
                return "empty return";
            else
                local cached_t_001 = param_649.t;
                if cached_t_001 == "return" then
                    if #param_649.values == 0 then
                        return "empty return";
                    end;
                elseif cached_t_001 == "break" then
                    return "break";
                elseif cached_t_001 == "continue" then
                    return "continue";
                end;
                return;
            end;
        end;
        local table_value_158 = {};
        local table_value_159 = {
            comment = helper_function_113,
            ["break"] = helper_function_113,
            continue = helper_function_113,
            ["unknown jump"] = helper_function_113,
            ["define variable"] = function(param_650)
                local cached_value_008 = param_650.value;
                while cached_value_008.t == "name" do
                    local cached_override_expr_007 = cached_value_008.name.override_expr;
                    if cached_override_expr_007 then
                        cached_value_008 = cached_override_expr_007;
                    else
                        break;
                    end;
                end;
                local cached_value_009 = cached_value_008;
                if cached_value_009.t == "new table" then
                    helper_function_114(param_650);
                end;
                helper_function_107(cached_value_009);
            end,
            ["set global"] = function(param_651)
                helper_function_107(param_651.value);
            end,
            ["define function"] = function(param_652)
                helper_function_107(param_652.func);
            end,
            call = function(param_653)
                helper_function_107(param_653.func);
                for _, item_114 in ipairs(param_653.args) do
                    helper_function_107(item_114);
                end;
            end,
            ["set table"] = function(param_654)
                helper_function_107(param_654.table);
                helper_function_107(param_654.key);
                helper_function_107(param_654.value);
            end,
            ["set variable"] = function(param_655)
                helper_function_107(param_655.value);
            end,
            ["return"] = function(param_656)
                local cached_lines_001 = param_656.lines;
                local condition_value_124 = table.find(cached_lines_001, param_656);
                assert(condition_value_124);
                if cached_lines_001[condition_value_124 + 1] or table_value_035[cached_lines_001] then
                    local table_value_160 = {
                        param_656
                    };
                    cached_lines_001[condition_value_124] = {
                        t = "do",
                        lines = cached_lines_001,
                        reads = {},
                        writes = {},
                        content = table_value_160
                    };
                    param_656.lines = table_value_160;
                    local_symbol_194 = local_symbol_194 + 1;
                end;
                for _, item_115 in ipairs(param_656.values) do
                    helper_function_107(item_115);
                end;
            end,
            ["if"] = function(param_657)
                helper_function_107(param_657.expr);
                helper_function_106(param_657.pass);
                for _, item_116 in ipairs(param_657.elseifs) do
                    helper_function_107(item_116.expr);
                    helper_function_106(item_116.code);
                end;
                local cached_else_003 = param_657.else_;
                if cached_else_003 then
                    if #cached_else_003 == 1 then
                        local array_value_118 = cached_else_003[1];
                        while array_value_118.t == "if" do
                            table.insert(param_657.elseifs, {
                                expr = array_value_118.expr,
                                code = array_value_118.pass
                            });
                            local_symbol_194 = local_symbol_194 + 1;
                            cached_else_003 = array_value_118.else_;
                            param_657.else_ = cached_else_003;
                            if cached_else_003 and #cached_else_003 == 1 then
                                array_value_118 = cached_else_003[1];
                            else
                                break;
                            end;
                        end;
                        return;
                    else
                        helper_function_106(cached_else_003);
                        return;
                    end;
                else
                    if condition_value_015.assume_if_else then
                        local cached_lines_002 = param_657.lines;
                        local condition_value_125 = table.find(cached_lines_002, param_657);
                        assert(condition_value_125);
                        if condition_value_125 < #cached_lines_002 then
                            local cached_pass_001 = param_657.pass;
                            local local_symbol_199, local_symbol_200;
                            if table_value_035[cached_pass_001] then
                                local_symbol_199 = true;
                                local_symbol_200 = nil;
                            elseif #cached_pass_001 == 0 then
                                local_symbol_199 = false;
                                local_symbol_200 = nil;
                            else
                                local condition_value_126 = cached_pass_001[#cached_pass_001];
                                if not (condition_value_126.t ~= "return" and condition_value_126.t ~= "break") or condition_value_126.t == "continue" then
                                    local_symbol_199 = true;
                                    local_symbol_200 = condition_value_126;
                                elseif condition_value_126.t == "do" then
                                    local condition_value_127, condition_value_128 = helper_function_115(condition_value_126.content);
                                    local_symbol_199 = condition_value_127;
                                    local_symbol_200 = condition_value_128;
                                else
                                    local_symbol_199 = false;
                                    local_symbol_200 = nil;
                                end;
                            end;
                            if local_symbol_199 then
                                local local_symbol_201;
                                if table_value_035[cached_lines_002] then
                                    cached_pass_001 = true;
                                    local_symbol_201 = nil;
                                elseif #cached_lines_002 == 0 then
                                    cached_pass_001 = false;
                                    local_symbol_201 = nil;
                                else
                                    local condition_value_129 = cached_lines_002[#cached_lines_002];
                                    if not (condition_value_129.t ~= "return" and condition_value_129.t ~= "break") or condition_value_129.t == "continue" then
                                        cached_pass_001 = true;
                                        local_symbol_201 = condition_value_129;
                                    elseif condition_value_129.t == "do" then
                                        local condition_value_130, condition_value_131 = helper_function_115(condition_value_129.content);
                                        cached_pass_001 = condition_value_130;
                                        local_symbol_201 = condition_value_131;
                                    else
                                        cached_pass_001 = false;
                                        local_symbol_201 = nil;
                                    end;
                                end;
                                if cached_pass_001 then
                                    local local_symbol_202;
                                    if not local_symbol_200 then
                                        local_symbol_202 = "empty return";
                                    else
                                        local cached_t_002 = local_symbol_200.t;
                                        local_symbol_202 = if cached_t_002 == "return" then #local_symbol_200.values == 0 and "empty return" or nil else cached_t_002 == "break" and "break" or cached_t_002 == "continue" and "continue" or nil;
                                    end;
                                    if local_symbol_202 then
                                        if #param_657.pass == 1 then
                                            return;
                                        else
                                            local local_symbol_203;
                                            if not local_symbol_201 then
                                                local_symbol_203 = "empty return";
                                            else
                                                local cached_t_003 = local_symbol_201.t;
                                                local_symbol_203 = if cached_t_003 == "return" then #local_symbol_201.values == 0 and "empty return" or nil else cached_t_003 == "break" and "break" or cached_t_003 == "continue" and "continue" or nil;
                                            end;
                                            if local_symbol_203 and local_symbol_202 == local_symbol_203 then
                                                local table_value_161 = {};
                                                local local_symbol_204 = condition_value_125 + 1;
                                                if local_symbol_200 then
                                                    local cached_remove = table.remove;
                                                    local cached_lines_003 = local_symbol_200.lines;
                                                    local local_symbol_205 = table.find(local_symbol_200.lines, local_symbol_200);
                                                    assert(local_symbol_205);
                                                    cached_remove(cached_lines_003, local_symbol_205);
                                                end;
                                                if local_symbol_201 then
                                                    local cached_remove_001 = table.remove;
                                                    local cached_lines_004 = local_symbol_201.lines;
                                                    local local_symbol_206 = table.find(local_symbol_201.lines, local_symbol_201);
                                                    assert(local_symbol_206);
                                                    cached_remove_001(cached_lines_004, local_symbol_206);
                                                end;
                                                while cached_lines_002[local_symbol_204] do
                                                    local local_symbol_207 = cached_lines_002[local_symbol_204];
                                                    assert(local_symbol_207);
                                                    local cached_local_symbol_022 = local_symbol_207;
                                                    table.remove(cached_lines_002, local_symbol_204);
                                                    if local_symbol_200 and cached_local_symbol_022 == local_symbol_200 then
                                                        assert(not cached_lines_002[local_symbol_204]);
                                                        break;
                                                    else
                                                        cached_local_symbol_022.lines = table_value_161;
                                                        table.insert(table_value_161, cached_local_symbol_022);
                                                    end;
                                                end;
                                                param_657.else_ = table_value_161;
                                                if local_symbol_202 ~= "empty return" then
                                                    if local_symbol_200 then
                                                        table.insert(cached_lines_002, local_symbol_200);
                                                        return;
                                                    elseif local_symbol_201 then
                                                        table.insert(cached_lines_002, local_symbol_201);
                                                    end;
                                                end;
                                            end;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    return;
                end;
            end,
            ["while"] = function(param_658)
                local expression_value_080 = false;
                local expression_value_081 = false;
                if not param_658.expr then
                    local expression_value_082 = nil;
                    local table_value_162 = {};
                    local cached_code_005 = param_658.code;
                    local table_value_163 = {};
                    for index_054 = #cached_code_005, 1, -1 do
                        local condition_value_132 = cached_code_005[index_054];
                        local condition_value_133;
                        if condition_value_132.t == "if" and not condition_value_132.else_ and #condition_value_132.elseifs == 0 then
                            local cached_pass_002 = condition_value_132.pass;
                            if #cached_pass_002 == 1 and cached_pass_002[1].t == "break" then
                                condition_value_133 = true;
                                expression_value_080 = true;
                            end;
                        end;
                        if not expression_value_080 then
                            condition_value_133 = nil;
                        end;
                        expression_value_080 = false;
                        if condition_value_133 then
                            table.insert(table_value_163, condition_value_132.expr);
                            cached_code_005[index_054] = nil;
                        else
                            break;
                        end;
                    end;
                    for index_055 = #table_value_163, 1, -1 do
                        table.insert(table_value_162, table_value_163[index_055]);
                    end;
                    if #table_value_162 > 0 then
                        expression_value_082 = true;
                    else
                        for _, item_117 in ipairs(cached_code_005) do
                            local condition_value_134;
                            if item_117.t == "if" and not item_117.else_ and #item_117.elseifs == 0 then
                                local cached_pass_003 = item_117.pass;
                                if #cached_pass_003 == 1 and cached_pass_003[1].t == "break" then
                                    condition_value_134 = true;
                                    expression_value_081 = true;
                                end;
                            end;
                            if not expression_value_081 then
                                condition_value_134 = nil;
                            end;
                            expression_value_081 = false;
                            if condition_value_134 then
                                local cached_expr = item_117.expr;
                                local expression_value_083;
                                if cached_expr.t == "condition" then
                                    cached_expr.condition = INVERTED_CONDITION_OPERATOR[cached_expr.condition];
                                    expression_value_083 = cached_expr;
                                else
                                    expression_value_083 = if cached_expr.t == "not" then cached_expr.rhs else helper_function_002(cached_expr);
                                end;
                                table.insert(table_value_162, expression_value_083);
                            else
                                break;
                            end;
                        end;
                        for _ = 1, #table_value_162 do
                            table.remove(cached_code_005, 1);
                        end;
                    end;
                    if #table_value_162 > 0 then
                        if #table_value_162 == 1 then
                            param_658.expr = table_value_162[1];
                        else
                            table_value_163 = table_value_162[1];
                            for index_056 = 2, #table_value_162 do
                                table_value_163 = helper_function_003(table_value_163, table_value_162[index_056]);
                            end;
                            param_658.expr = table_value_163;
                        end;
                        if expression_value_082 then
                            param_658.t = "repeat";
                        end;
                    end;
                end;
                if param_658.expr then
                    helper_function_107(param_658.expr);
                end;
                helper_function_106(param_658.code);
            end,
            ["repeat"] = function(param_659)
                if param_659.expr then
                    helper_function_107(param_659.expr);
                end;
                helper_function_106(param_659.code);
            end,
            ["do"] = function(param_660)
                helper_function_106(param_660.content);
            end,
            ["for"] = function(param_661)
                local cached_for_info_001 = param_661.for_info;
                local cached_variables_001 = cached_for_info_001.variables;
                assert(cached_variables_001);
                local cached_type_008 = cached_for_info_001.type;
                if cached_type_008 == "numeric" then
                    assert(#cached_variables_001 == 1);
                    if not table_value_158[param_661] then
                        table_value_158[param_661] = true;
                        local local_symbol_208 = cached_variables_001[1];
                        local cached_i = table_value_024.i;
                        local local_symbol_209 = "i";
                        local local_symbol_210 = cached_i or 1;
                        while table_value_023[local_symbol_209] or table_value_018[local_symbol_209] do
                            local_symbol_210 = local_symbol_210 + 1;
                            local_symbol_209 = "i" .. "_" .. local_symbol_210;
                        end;
                        table_value_024.i = local_symbol_210;
                        local cached_local_symbol_023 = local_symbol_209;
                        cached_i = local_symbol_208.name;
                        if not table_value_023[cached_i] then
                            error((("[write] Variable %* not allocated"):format(cached_i)));
                        end;
                        table_value_023[cached_i] = nil;
                        local_symbol_208.name = cached_local_symbol_023;
                        table_value_023[cached_local_symbol_023] = local_symbol_208;
                        local_symbol_208.attributes.renamed = true;
                    end;
                    local cached_args_002 = cached_for_info_001.args;
                    local cached_index_expr = cached_args_002.index_expr;
                    assert(cached_index_expr);
                    helper_function_107(cached_index_expr);
                    local cached_end_expr = cached_args_002.end_expr;
                    assert(cached_end_expr);
                    helper_function_107(cached_end_expr);
                    local cached_step_expr_001 = cached_args_002.step_expr;
                    assert(cached_step_expr_001);
                    helper_function_107(cached_step_expr_001);
                elseif cached_type_008 == "generic" then
                    assert(#cached_variables_001 > 0);
                    if not table_value_158[param_661] then
                        table_value_158[param_661] = true;
                        local local_symbol_211 = cached_variables_001[1];
                        local cached_i_001 = table_value_024.i;
                        local local_symbol_212 = "i";
                        local local_symbol_213 = cached_i_001 or 1;
                        while table_value_023[local_symbol_212] or table_value_018[local_symbol_212] do
                            local_symbol_213 = local_symbol_213 + 1;
                            local_symbol_212 = "i" .. "_" .. local_symbol_213;
                        end;
                        table_value_024.i = local_symbol_213;
                        local cached_local_symbol_024 = local_symbol_212;
                        cached_i_001 = local_symbol_211.name;
                        if not table_value_023[cached_i_001] then
                            error((("[write] Variable %* not allocated"):format(cached_i_001)));
                        end;
                        table_value_023[cached_i_001] = nil;
                        local_symbol_211.name = cached_local_symbol_024;
                        table_value_023[cached_local_symbol_024] = local_symbol_211;
                        local_symbol_211.attributes.renamed = true;
                        if #cached_variables_001 == 2 then
                            local_symbol_211 = cached_variables_001[2];
                            cached_i_001 = table_value_024.v;
                            local_symbol_212 = "v";
                            local_symbol_213 = cached_i_001 or 1;
                            while table_value_023[local_symbol_212] or table_value_018[local_symbol_212] do
                                local_symbol_213 = local_symbol_213 + 1;
                                local_symbol_212 = "v" .. "_" .. local_symbol_213;
                            end;
                            table_value_024.v = local_symbol_213;
                            cached_local_symbol_024 = local_symbol_212;
                            cached_i_001 = local_symbol_211.name;
                            if not table_value_023[cached_i_001] then
                                error((("[write] Variable %* not allocated"):format(cached_i_001)));
                            end;
                            table_value_023[cached_i_001] = nil;
                            local_symbol_211.name = cached_local_symbol_024;
                            table_value_023[cached_local_symbol_024] = local_symbol_211;
                            local_symbol_211.attributes.renamed = true;
                        else
                            for index_057 = 2, #cached_variables_001 do
                                local_symbol_212 = cached_variables_001[index_057];
                                local local_symbol_214 = "v" .. index_057 - 1;
                                local local_symbol_215 = table_value_024[local_symbol_214];
                                local cached_local_symbol_025 = local_symbol_214;
                                local local_symbol_216 = local_symbol_215 or 1;
                                while table_value_023[cached_local_symbol_025] or table_value_018[cached_local_symbol_025] do
                                    local_symbol_216 = local_symbol_216 + 1;
                                    cached_local_symbol_025 = local_symbol_214 .. "_" .. local_symbol_216;
                                end;
                                table_value_024[local_symbol_214] = local_symbol_216;
                                local_symbol_213 = cached_local_symbol_025;
                                local_symbol_214 = local_symbol_212.name;
                                if not table_value_023[local_symbol_214] then
                                    error((("[write] Variable %* not allocated"):format(local_symbol_214)));
                                end;
                                table_value_023[local_symbol_214] = nil;
                                local_symbol_212.name = local_symbol_213;
                                table_value_023[local_symbol_213] = local_symbol_212;
                                local_symbol_212.attributes.renamed = true;
                            end;
                        end;
                    end;
                    local cached_args_003 = cached_for_info_001.args;
                    local cached_generator_expr = cached_args_003.generator_expr;
                    assert(cached_generator_expr);
                    helper_function_107(cached_generator_expr);
                    if cached_args_003.state_expr then
                        helper_function_107(cached_args_003.state_expr);
                    end;
                    if cached_args_003.index_expr then
                        helper_function_107(cached_args_003.index_expr);
                    end;
                else
                    error((("Unknown for_type \"%*\""):format(cached_type_008)));
                end;
                helper_function_106(param_661.code);
            end
        };
        local table_value_164 = {
            {},
            {
                ["define variable"] = function(param_662)
                    local cached_value_010 = param_662.value;
                    while cached_value_010.t == "name" do
                        local cached_override_expr_008 = cached_value_010.name.override_expr;
                        if cached_override_expr_008 then
                            cached_value_010 = cached_override_expr_008;
                        else
                            break;
                        end;
                    end;
                    local cached_value_011 = cached_value_010;
                    if cached_value_011.t == "new table" then
                        helper_function_114(param_662);
                    elseif cached_value_011.t == "function" then
                        assert(#param_662.names == 1);
                        cached_value_010 = param_662.names[1];
                        assert(cached_value_010 == cached_value_011.varname);
                        local cached_name_010 = cached_value_011.name;
                        local cached_name_011 = cached_value_010.name;
                        if not table_value_023[cached_name_011] then
                            error((("[write] Variable %* not allocated"):format(cached_name_011)));
                        end;
                        table_value_023[cached_name_011] = nil;
                        cached_value_010.name = cached_name_010;
                        table_value_023[cached_name_010] = cached_value_010;
                        cached_value_010.attributes.renamed = true;
                        helper_function_112(param_662, cached_value_011, cached_value_010, "local");
                    end;
                    helper_function_107(cached_value_011);
                end,
                ["set variable"] = function(param_663)
                    local cached_value_012 = param_663.value;
                    while cached_value_012.t == "name" do
                        local cached_override_expr_009 = cached_value_012.name.override_expr;
                        if cached_override_expr_009 then
                            cached_value_012 = cached_override_expr_009;
                        else
                            break;
                        end;
                    end;
                    local cached_value_013 = cached_value_012;
                    if cached_value_013.t == "function" then
                        cached_value_012 = param_663.name;
                        local cached_name_012 = cached_value_013.name;
                        if condition_value_015.smart_var_level >= 2 then
                            local cached_name_013 = cached_value_012.name;
                            if not table_value_023[cached_name_013] then
                                error((("[write] Variable %* not allocated"):format(cached_name_013)));
                            end;
                            table_value_023[cached_name_013] = nil;
                            cached_value_012.name = cached_name_012;
                            table_value_023[cached_name_012] = cached_value_012;
                            cached_value_012.attributes.renamed = true;
                        end;
                        helper_function_112(param_663, cached_value_013, cached_value_012, "global");
                    end;
                    helper_function_107(param_663.value);
                end,
                ["set global"] = function(param_664)
                    local cached_value_014 = param_664.value;
                    while cached_value_014.t == "name" do
                        local cached_override_expr_010 = cached_value_014.name.override_expr;
                        if cached_override_expr_010 then
                            cached_value_014 = cached_override_expr_010;
                        else
                            break;
                        end;
                    end;
                    local cached_value_015 = cached_value_014;
                    if cached_value_015.t == "function" then
                        cached_value_014 = param_664.name;
                        if cached_value_014.type == 3 then
                            local cached_helper_function_086 = helper_function_112;
                            local cached_param_021 = param_664;
                            local cached_value_016 = cached_value_015;
                            local cached_value_017 = cached_value_014.value;
                            cached_helper_function_086(cached_param_021, cached_value_016, table_value_023[cached_value_017] or is_point_in_named_range(cached_value_017, {
                                beginning = -1,
                                ending = -1
                            }, {}), "global");
                        end;
                    end;
                    helper_function_107(cached_value_015);
                end,
                ["set table"] = function(param_665)
                    local cached_value_018 = param_665.value;
                    while cached_value_018.t == "name" do
                        local cached_override_expr_011 = cached_value_018.name.override_expr;
                        if cached_override_expr_011 then
                            cached_value_018 = cached_override_expr_011;
                        else
                            break;
                        end;
                    end;
                    local cached_value_019 = cached_value_018;
                    if cached_value_019.t == "function" then
                        local cached_table_003 = param_665.table;
                        while cached_table_003.t == "name" do
                            local cached_override_expr_012 = cached_table_003.name.override_expr;
                            if cached_override_expr_012 then
                                cached_table_003 = cached_override_expr_012;
                            else
                                break;
                            end;
                        end;
                        cached_value_018 = cached_table_003;
                        cached_table_003 = cached_value_018.t;
                        local condition_value_135 = nil;
                        if cached_table_003 == "global" then
                            local cached_name_014 = cached_value_018.name;
                            if cached_name_014.type == 3 then
                                condition_value_135 = cached_name_014.value;
                            end;
                        elseif cached_table_003 == "name" then
                            condition_value_135 = cached_value_018.name.name;
                        end;
                        if condition_value_135 and is_valid_identifier(condition_value_135) then
                            local constant_value_108 = nil;
                            local cached_key_001 = param_665.key;
                            if cached_key_001.t == "constant" then
                                local cached_const_001 = cached_key_001.const;
                                if cached_const_001.type == 3 then
                                    local cached_value_020 = cached_const_001.value;
                                    if is_valid_identifier(cached_value_020) then
                                        assert(type(cached_value_020) == "string");
                                        constant_value_108 = cached_value_020;
                                    end;
                                end;
                            end;
                            if constant_value_108 then
                                local cached_helper_function_087 = helper_function_112;
                                local cached_param_022 = param_665;
                                local cached_cached_value = cached_value_019;
                                local cached_constant_value_025 = constant_value_108;
                                local range_value_027 = table_value_023[cached_constant_value_025] or is_point_in_named_range(cached_constant_value_025, {
                                    beginning = -1,
                                    ending = -1
                                }, {});
                                cached_constant_value_025 = "table";
                                local table_value_165 = {};
                                local cached_condition_value_004 = condition_value_135;
                                local range_value_028 = table_value_023[cached_condition_value_004] or is_point_in_named_range(cached_condition_value_004, {
                                    beginning = -1,
                                    ending = -1
                                }, {});
                                local cached_constant_value_026 = constant_value_108;
                                cached_condition_value_004 = table_value_023[cached_constant_value_026] or is_point_in_named_range(cached_constant_value_026, {
                                    beginning = -1,
                                    ending = -1
                                }, {});
                                copy_varargs_into_array(table_value_165, 1, range_value_028, cached_condition_value_004);
                                cached_helper_function_087(cached_param_022, cached_cached_value, range_value_027, cached_constant_value_025, table_value_165);
                            end;
                        end;
                        helper_function_107(cached_value_018);
                        helper_function_107(param_665.key);
                        helper_function_107(cached_value_019);
                        return;
                    else
                        helper_function_107(param_665.table);
                        helper_function_107(param_665.key);
                        helper_function_107(cached_value_019);
                        return;
                    end;
                end
            }
        };
        assert(#table_value_164 > 0);
        local local_symbol_217 = nil;
        helper_function_106 = function(param_666)
            local cached_table_value_009 = table_value_022;
            local cached_local_symbol_026 = local_symbol_195;
            table_value_022 = param_666;
            local_symbol_195 = 1;
            while true do
                if local_symbol_195 <= #param_666 then
                    local condition_value_136 = param_666[local_symbol_195];
                    if local_symbol_196[condition_value_136] then
                        return;
                    else
                        local_symbol_196[condition_value_136] = true;
                        local condition_value_137 = local_symbol_217[condition_value_136.t];
                        if condition_value_137 then
                            condition_value_137(condition_value_136);
                            local_symbol_195 = local_symbol_195 + 1;
                        else
                            error((("Unknown line type %*"):format(condition_value_136.t)));
                        end;
                    end;
                else
                    table_value_022 = cached_table_value_009;
                    local_symbol_195 = cached_local_symbol_026;
                    return;
                end;
            end;
        end;
        local function _()
            local_symbol_194 = 0;
        end;
        local function helper_function_116()
            local_symbol_194 = 0;
            local table_value_166 = {};
            for _, item_118 in pairs(table.clone(table_value_023)) do
                if item_118.init_expr then
                    assert(item_118.init_expr);
                    local cached_attributes = item_118.attributes;
                    if not cached_attributes.no_inline and not cached_attributes.is_upvalue then
                        local register_value_016 = #item_118.reads;
                        if register_value_016 == 1 then
                            if #item_118.writes == 1 then
                                if cached_attributes.multireg then
                                    local condition_value_138 = item_118.reads[1];
                                    if not table_value_166[condition_value_138] and condition_value_138.t == "for" then
                                        table_value_166[condition_value_138] = true;
                                        local cached_var_list_001 = item_118.var_list;
                                        assert(#cached_var_list_001 > 1);
                                        if #cached_var_list_001 < 4 then
                                            local expression_value_084 = item_118.writes[1];
                                            local cached_init_expr = item_118.init_expr;
                                            assert(cached_init_expr);
                                            local expression_value_085 = true;
                                            for _, item_119 in ipairs(cached_var_list_001) do
                                                if item_119 ~= item_118 then
                                                    if not (#item_119.reads == 1 and #item_119.writes == 1) or item_119.reads[1] ~= condition_value_138 then
                                                        expression_value_085 = false;
                                                        break;
                                                    else
                                                        assert(item_119.writes[1] == expression_value_084);
                                                        assert(item_119.init_expr == cached_init_expr);
                                                    end;
                                                end;
                                            end;
                                            if expression_value_085 then
                                                local cached_for_info_002 = condition_value_138.for_info;
                                                assert(cached_for_info_002.type == "generic");
                                                local cached_args_004 = cached_for_info_002.args;
                                                local cached_generator_expr_001 = cached_args_004.generator_expr;
                                                local cached_state_expr_001 = cached_args_004.state_expr;
                                                local cached_index_expr_001 = cached_args_004.index_expr;
                                                for expression_value_086, item_120 in ipairs(cached_var_list_001) do
                                                    assert(item_120.var_num == expression_value_086);
                                                end;
                                                expression_value_085 = false;
                                                if #cached_var_list_001 == 2 then
                                                    if cached_state_expr_001 then
                                                        local cached_state_expr_002 = cached_state_expr_001;
                                                        local expression_value_087 = cached_var_list_001[1];
                                                        local cached_state_expr = cached_state_expr_002;
                                                        while cached_state_expr.t == "name" do
                                                            local cached_override_expr_013 = cached_state_expr.name.override_expr;
                                                            if cached_override_expr_013 then
                                                                cached_state_expr = cached_override_expr_013;
                                                            else
                                                                break;
                                                            end;
                                                        end;
                                                        cached_state_expr_002 = cached_state_expr;
                                                        if cached_state_expr_002.t == "name" and cached_state_expr_002.name == expression_value_087 and cached_index_expr_001 then
                                                            cached_state_expr_002 = cached_index_expr_001;
                                                            expression_value_087 = cached_var_list_001[2];
                                                            cached_state_expr = cached_state_expr_002;
                                                            while cached_state_expr.t == "name" do
                                                                local cached_override_expr_014 = cached_state_expr.name.override_expr;
                                                                if cached_override_expr_014 then
                                                                    cached_state_expr = cached_override_expr_014;
                                                                else
                                                                    break;
                                                                end;
                                                            end;
                                                            cached_state_expr_002 = cached_state_expr;
                                                            if cached_state_expr_002.t == "name" and cached_state_expr_002.name == expression_value_087 then
                                                                expression_value_085 = true;
                                                                cached_args_004.state_expr = cached_init_expr;
                                                                cached_args_004.index_expr = nil;
                                                            end;
                                                        end;
                                                    end;
                                                elseif cached_generator_expr_001 then
                                                    local cached_generator_expr_002 = cached_generator_expr_001;
                                                    local expression_value_088 = cached_var_list_001[1];
                                                    local cached_generator_expr_003 = cached_generator_expr_002;
                                                    while cached_generator_expr_003.t == "name" do
                                                        local cached_override_expr_015 = cached_generator_expr_003.name.override_expr;
                                                        if cached_override_expr_015 then
                                                            cached_generator_expr_003 = cached_override_expr_015;
                                                        else
                                                            break;
                                                        end;
                                                    end;
                                                    cached_generator_expr_002 = cached_generator_expr_003;
                                                    if cached_generator_expr_002.t == "name" and cached_generator_expr_002.name == expression_value_088 and cached_state_expr_001 then
                                                        cached_generator_expr_002 = cached_state_expr_001;
                                                        expression_value_088 = cached_var_list_001[2];
                                                        cached_generator_expr_003 = cached_generator_expr_002;
                                                        while cached_generator_expr_003.t == "name" do
                                                            local cached_override_expr_016 = cached_generator_expr_003.name.override_expr;
                                                            if cached_override_expr_016 then
                                                                cached_generator_expr_003 = cached_override_expr_016;
                                                            else
                                                                break;
                                                            end;
                                                        end;
                                                        cached_generator_expr_002 = cached_generator_expr_003;
                                                        if cached_generator_expr_002.t == "name" and cached_generator_expr_002.name == expression_value_088 and cached_index_expr_001 then
                                                            cached_generator_expr_002 = cached_index_expr_001;
                                                            expression_value_088 = cached_var_list_001[3];
                                                            cached_generator_expr_003 = cached_generator_expr_002;
                                                            while cached_generator_expr_003.t == "name" do
                                                                local cached_override_expr_017 = cached_generator_expr_003.name.override_expr;
                                                                if cached_override_expr_017 then
                                                                    cached_generator_expr_003 = cached_override_expr_017;
                                                                else
                                                                    break;
                                                                end;
                                                            end;
                                                            cached_generator_expr_002 = cached_generator_expr_003;
                                                            if cached_generator_expr_002.t == "name" and cached_generator_expr_002.name == expression_value_088 then
                                                                expression_value_085 = true;
                                                                cached_args_004.generator_expr = cached_init_expr;
                                                                cached_args_004.state_expr = nil;
                                                                cached_args_004.index_expr = nil;
                                                            end;
                                                        end;
                                                    end;
                                                end;
                                                if expression_value_085 then
                                                    local cached_lines_005 = expression_value_084.lines;
                                                    local local_symbol_218 = table.find(cached_lines_005, expression_value_084);
                                                    assert(local_symbol_218);
                                                    make_location_range(condition_value_138, item_118);
                                                    get_range_size(expression_value_084, item_118);
                                                    table.remove(cached_lines_005, local_symbol_218);
                                                    assert(item_118.init_expr);
                                                    local_symbol_194 = local_symbol_194 + 1;
                                                end;
                                            end;
                                        end;
                                    end;
                                else
                                    local local_symbol_219 = item_118.reads[1];
                                    local condition_value_139 = item_118.writes[1];
                                    if not LUAU_KEYWORDS_REQUIRING_SUFFIX[condition_value_139.t] then
                                        local cached_lines_006 = condition_value_139.lines;
                                        local local_symbol_220 = table.find(cached_lines_006, condition_value_139);
                                        assert(local_symbol_220);
                                        make_location_range(local_symbol_219, item_118);
                                        get_range_size(condition_value_139, item_118);
                                        table.remove(cached_lines_006, local_symbol_220);
                                        local cached_init_expr_001 = item_118.init_expr;
                                        local cached_name_015 = item_118.name;
                                        if not table_value_023[cached_name_015] then
                                            error((("[write] Variable %* not allocated"):format(cached_name_015)));
                                        end;
                                        table_value_023[cached_name_015] = nil;
                                        item_118.override_expr = cached_init_expr_001;
                                        local_symbol_194 = local_symbol_194 + 1;
                                    end;
                                end;
                            end;
                        elseif register_value_016 == 0 and not cached_attributes._ then
                            local cached_name_016 = item_118.name;
                            if not table_value_023[cached_name_016] then
                                error((("[write] Variable %* not allocated"):format(cached_name_016)));
                            end;
                            table_value_023[cached_name_016] = nil;
                            item_118.name = "_";
                            table_value_023._ = item_118;
                            item_118.attributes.renamed = true;
                            cached_attributes._ = true;
                            local_symbol_194 = local_symbol_194 + 1;
                        end;
                    end;
                end;
            end;
        end;
        local function helper_function_117()
            local_symbol_194 = 0;
            local_symbol_217 = table.clone(table_value_159);
            for _, item_121 in ipairs(table_value_164) do
                for array_value_119, item_122 in pairs(item_121) do
                    local_symbol_217[array_value_119] = item_122;
                end;
                while true do
                    local_symbol_196 = {};
                    helper_function_106(table_value_022);
                    if local_symbol_194 ~= 0 then
                        local_symbol_194 = 0;
                    else
                        break;
                    end;
                end;
                local_symbol_194 = 0;
            end;
        end;
        local function _()
            local condition_value_140 = -1;
            while true do
                condition_value_140 = condition_value_140 + 1;
                helper_function_116();
                if not (local_symbol_194 ~= 0) then
                    break;
                end;
            end;
            return condition_value_140;
        end;
        local function _()
            local condition_value_141 = -1;
            while true do
                condition_value_141 = condition_value_141 + 1;
                helper_function_117();
                if not (local_symbol_194 ~= 0) then
                    break;
                end;
            end;
            return condition_value_141;
        end;
        local local_symbol_221 = nil;
        while true do
            local_symbol_221 = 0;
            local condition_value_142 = -1;
            while true do
                condition_value_142 = condition_value_142 + 1;
                helper_function_117();
                if not (local_symbol_194 ~= 0) then
                    break;
                end;
            end;
            local_symbol_221 = local_symbol_221 + condition_value_142;
            condition_value_142 = -1;
            while true do
                condition_value_142 = condition_value_142 + 1;
                helper_function_116();
                if not (local_symbol_194 ~= 0) then
                    break;
                end;
            end;
            if not (local_symbol_221 + condition_value_142 ~= 0) then
                break;
            end;
        end;
        local_symbol_009:end_benchmark("Global High Level Reductions");
        local_symbol_009:start_benchmark("Smart Naming");
        local local_symbol_222 = condition_value_015.smart_var_level >= 3 and "NONE" or nil;
        local condition_value_143 = condition_value_015.smart_var_extensive_prefixes and true or nil;
        local function _(param_667)
            if condition_value_143 then
                return param_667;
            else
                return "";
            end;
        end;
        local function _(param_668)
            local cached_reads_001 = param_668.reads;
            local condition_value_144 = cached_reads_001[#cached_reads_001];
            if condition_value_144 and condition_value_144.t == "return" then
                local table_value_167 = {};
                local cached_values = condition_value_144.values;
                if condition_value_015.smart_var_level == 3 then
                    return true;
                elseif #table_value_167 == 1 then
                    table_value_167 = cached_values;
                    return;
                else
                    return;
                end;
            else
                return;
            end;
        end;
        local function helper_function_118(param_669)
            local constant_value_109 = true;
            if param_669.t ~= "constant index" then
                constant_value_109 = param_669.t == "get table";
            end;
            assert(constant_value_109);
            local constant_value_110 = "";
            constant_value_109 = nil;
            local constant_value_111, constant_value_112;
            while true do
                if param_669.t == "constant index" then
                    constant_value_110 = "." .. param_669.index.value .. constant_value_110;
                elseif param_669.t == "get table" then
                    constant_value_112 = param_669.index;
                    if constant_value_112.t == "constant" then
                        constant_value_110 = "." .. format_constant(constant_value_112.const, condition_value_015.string_quotes_behavior, true) .. constant_value_110;
                    else
                        constant_value_110 = ".any" .. constant_value_110;
                    end;
                else
                    assert(nil);
                end;
                constant_value_112 = param_669.table;
                constant_value_111 = constant_value_112.t;
                if not (constant_value_111 ~= "constant index") or constant_value_111.t == "get table" then
                    param_669 = constant_value_112;
                else
                    break;
                end;
            end;
            if constant_value_111 == "global" then
                return format_constant(constant_value_112.name, condition_value_015.string_quotes_behavior, true) .. constant_value_110, constant_value_109;
            else
                return "any" .. constant_value_110, true;
            end;
        end;
        local _ = function(param_670)
            local _ = nil;
            local string_value_048 = string.reverse(param_670);
            local string_value_049 = string.find(string_value_048, "%.");
            if string_value_049 then
                return (string.sub(param_670, #param_670 - string_value_049 + 2, #param_670));
            else
                return param_670;
            end;
        end;
        local table_value_168 = {
            GetMouse = function(param_671, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_002 = param_671.var_num;
                    assert(cached_var_num_002);
                    if cached_var_num_002 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "mouse";
            end,
            Clone = function(param_672, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_003 = param_672.var_num;
                    assert(cached_var_num_003);
                    if cached_var_num_003 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "clone";
            end,
            GetChildren = function(param_673, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_004 = param_673.var_num;
                    assert(cached_var_num_004);
                    if cached_var_num_004 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "children";
            end,
            GetDescendants = function(param_674, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_005 = param_674.var_num;
                    assert(cached_var_num_005);
                    if cached_var_num_005 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "descendants";
            end,
            GetPlayers = function(param_675, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_006 = param_675.var_num;
                    assert(cached_var_num_006);
                    if cached_var_num_006 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "players";
            end,
            format = function(param_676, param_677)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_007 = param_676.var_num;
                    assert(cached_var_num_007);
                    if cached_var_num_007 > 1 then
                        return local_symbol_222;
                    end;
                end;
                if condition_value_143 then
                    local condition_value_145 = #param_677.args;
                    if condition_value_145 == 1 then
                        return "formatted_1_value";
                    else
                        return "formatted_" .. condition_value_145 .. "_values";
                    end;
                else
                    return "formatted";
                end;
            end,
            IsA = function(param_678, _)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_008 = param_678.var_num;
                    assert(cached_var_num_008);
                    if cached_var_num_008 > 1 then
                        return local_symbol_222;
                    end;
                end;
                return "children";
            end,
            WaitForChild = function(param_679, param_680)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_009 = param_679.var_num;
                    assert(cached_var_num_009);
                    if cached_var_num_009 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_005 = param_680.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_005 == 0 then
                    return (condition_value_143 and "instance_" or "") .. "NEVER";
                else
                    local constant_value_113 = nil;
                    local constant_value_114 = cached_args_005[1];
                    if constant_value_114.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_002 = constant_value_114.const;
                        if cached_const_002.type == 3 then
                            return (condition_value_143 and "instance_" or "") .. make_safe_identifier(cached_const_002.value, true, true);
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_113 = true;
                        end;
                    end;
                    if constant_value_113 then
                        return (condition_value_143 and "instance_" or "") .. "NEVER";
                    elseif condition_value_015.smart_var_level >= 3 then
                        return (condition_value_143 and "instance_" or "") .. "SOME";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "instance";
                    else
                        return;
                    end;
                end;
            end,
            FindFirstChildOfClass = function(param_681, param_682)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_010 = param_681.var_num;
                    assert(cached_var_num_010);
                    if cached_var_num_010 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_006 = param_682.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_006 == 0 then
                    return (condition_value_143 and "instance_" or "") .. "NEVER";
                else
                    local constant_value_115 = nil;
                    local constant_value_116 = cached_args_006[1];
                    if constant_value_116.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_003 = constant_value_116.const;
                        if cached_const_003.type == 3 then
                            return (condition_value_143 and "instance_with_" or "") .. "class_" .. make_safe_identifier(cached_const_003.value, true, true);
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_115 = true;
                        end;
                    end;
                    if constant_value_115 then
                        return (condition_value_143 and "instance_" or "") .. "NEVER";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "instance";
                    else
                        return;
                    end;
                end;
            end,
            FindFirstChildWhichIsA = function(param_683, param_684)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_011 = param_683.var_num;
                    assert(cached_var_num_011);
                    if cached_var_num_011 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_007 = param_684.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_007 == 0 then
                    return (condition_value_143 and "instance_" or "") .. "NEVER";
                else
                    local constant_value_117 = nil;
                    local constant_value_118 = cached_args_007[1];
                    if constant_value_118.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_004 = constant_value_118.const;
                        if cached_const_004.type == 3 then
                            return (condition_value_143 and "instance_which_is_a_" or "") .. "class_" .. make_safe_identifier(cached_const_004.value, true, true);
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_117 = true;
                        end;
                    end;
                    if constant_value_117 then
                        return (condition_value_143 and "instance_" or "") .. "NEVER";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "instance";
                    else
                        return;
                    end;
                end;
            end,
            GetAttribute = function(param_685, param_686)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_012 = param_685.var_num;
                    assert(cached_var_num_012);
                    if cached_var_num_012 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_008 = param_686.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_008 == 0 then
                    return "NEVER";
                else
                    local constant_value_119 = nil;
                    local constant_value_120 = cached_args_008[1];
                    if constant_value_120.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_005 = constant_value_120.const;
                        if cached_const_005.type == 3 then
                            return (condition_value_143 and "attribute_" or "") .. make_safe_identifier(cached_const_005.value, true, true);
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_119 = true;
                        end;
                    end;
                    if constant_value_119 then
                        return "NEVER";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "attribute";
                    else
                        return;
                    end;
                end;
            end,
            GetAttributeChangedSignal = function(param_687, param_688)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_013 = param_687.var_num;
                    assert(cached_var_num_013);
                    if cached_var_num_013 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_009 = param_688.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_009 == 0 then
                    return "NEVER";
                else
                    local constant_value_121 = nil;
                    local constant_value_122 = cached_args_009[1];
                    if constant_value_122.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_006 = constant_value_122.const;
                        if cached_const_006.type == 3 then
                            return (condition_value_143 and "attribute_" or "") .. make_safe_identifier(cached_const_006.value, true, true) .. "_changed_signal";
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_121 = true;
                        end;
                    end;
                    if constant_value_121 then
                        return "NEVER";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "attribute_changed_signal";
                    else
                        return;
                    end;
                end;
            end,
            GetPropertyChangedSignal = function(param_689, param_690)
                if condition_value_015.smart_var_level >= 3 then
                    local cached_var_num_014 = param_689.var_num;
                    assert(cached_var_num_014);
                    if cached_var_num_014 > 1 then
                        return local_symbol_222;
                    end;
                end;
                local cached_args_010 = param_690.args;
                if condition_value_015.smart_var_level >= 3 and #cached_args_010 == 0 then
                    return "NEVER";
                else
                    local constant_value_123 = nil;
                    local constant_value_124 = cached_args_010[1];
                    if constant_value_124.t == "constant" and condition_value_015.smart_var_level >= 2 then
                        local cached_const_007 = constant_value_124.const;
                        if cached_const_007.type == 3 then
                            return (condition_value_143 and "property_" or "") .. make_safe_identifier(cached_const_007.value, true, true) .. "_changed_signal";
                        elseif condition_value_015.smart_var_level >= 3 then
                            constant_value_123 = true;
                        end;
                    end;
                    if constant_value_123 then
                        return "NEVER";
                    elseif condition_value_015.smart_var_level >= 2 then
                        return "property_changed_signal";
                    else
                        return;
                    end;
                end;
            end
        };
        local function _(param_691, param_692)
            local local_symbol_223 = table_value_168[param_692];
            assert(local_symbol_223);
            table_value_168[param_691] = local_symbol_223;
        end;
        local cached_Clone = table_value_168.Clone;
        assert(cached_Clone);
        table_value_168.clone = cached_Clone;
        cached_Clone = table_value_168.GetChildren;
        assert(cached_Clone);
        table_value_168.getChildren = cached_Clone;
        cached_Clone = table_value_168.GetChildren;
        assert(cached_Clone);
        table_value_168.children = cached_Clone;
        cached_Clone = table_value_168.WaitForChild;
        assert(cached_Clone);
        table_value_168.FindFirstChild = cached_Clone;
        cached_Clone = table_value_168.FindFirstChild;
        assert(cached_Clone);
        table_value_168.findFirstChild = cached_Clone;
        cached_Clone = table_value_168.FindFirstChild;
        assert(cached_Clone);
        table_value_168.FindFirstAncestor = cached_Clone;
        cached_Clone = table_value_168.FindFirstChildOfClass;
        assert(cached_Clone);
        table_value_168.FindFirstAncestorOfClass = cached_Clone;
        cached_Clone = table_value_168.FindFirstChildWhichIsA;
        assert(cached_Clone);
        table_value_168.FindFirstAncestorWhichIsA = cached_Clone;
        cached_Clone = table_value_168.FindFirstChild;
        assert(cached_Clone);
        table_value_168.FindFirstDescendant = cached_Clone;
        cached_Clone = {
            ["Instance.new"] = function(param_693, param_694)
                local cached_var_num_015 = param_693.var_num;
                assert(cached_var_num_015);
                if cached_var_num_015 > 1 then
                    return local_symbol_222;
                else
                    local cached_args_011 = param_694.args;
                    if #cached_args_011 == 0 then
                        return (condition_value_143 and "instance_" or "") .. "NEVER";
                    else
                        cached_var_num_015 = nil;
                        if #cached_args_011 > 1 and condition_value_015.smart_var_level >= 2 and cached_args_011[2].t ~= "nil" then
                            cached_var_num_015 = true;
                        end;
                        local constant_value_125 = nil;
                        local constant_value_126 = cached_args_011[1];
                        if constant_value_126.t == "constant" then
                            local constant_value_127 = format_constant(constant_value_126.const, condition_value_015.string_quotes_behavior, true);
                            constant_value_125 = make_safe_identifier(constant_value_127, true, true);
                        else
                            constant_value_125 = "any";
                        end;
                        if cached_var_num_015 then
                            return (condition_value_143 and "instance_" or "") .. constant_value_125 .. (condition_value_143 and "_parented" or "");
                        else
                            return (condition_value_143 and "instance_" or "") .. constant_value_125;
                        end;
                    end;
                end;
            end,
            ["math.random"] = function(param_695, param_696)
                local cached_var_num_016 = param_695.var_num;
                assert(cached_var_num_016);
                if cached_var_num_016 > 1 then
                    return local_symbol_222;
                else
                    local condition_value_146 = #param_696.args;
                    if condition_value_146 == 0 and condition_value_015.smart_var_level >= 2 then
                        return "seed";
                    elseif condition_value_015.smart_var_level >= 3 then
                        if condition_value_146 == 1 then
                            return "randint_from_1";
                        else
                            return "randint";
                        end;
                    else
                        return "randint";
                    end;
                end;
            end,
            ["math.sqrt"] = function(param_697, param_698)
                local cached_var_num_017 = param_697.var_num;
                assert(cached_var_num_017);
                if cached_var_num_017 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_698.args == 0 then
                        return "NEVER";
                    else
                        return "squareroot";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "root";
                else
                    return "num";
                end;
            end,
            ["math.abs"] = function(param_699, param_700)
                local cached_var_num_018 = param_699.var_num;
                assert(cached_var_num_018);
                if cached_var_num_018 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_700.args == 0 then
                        return "NEVER";
                    else
                        return "absolute";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "absolute";
                else
                    return "num";
                end;
            end,
            ["math.floor"] = function(param_701, param_702)
                local cached_var_num_019 = param_701.var_num;
                assert(cached_var_num_019);
                if cached_var_num_019 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    local condition_value_147 = param_702.args[1];
                    if condition_value_147 then
                        if condition_value_147.t == "addition" then
                            cached_var_num_019 = {
                                condition_value_147.lhs,
                                condition_value_147.rhs
                            };
                            local constant_value_128 = 0;
                            for _, item_123 in ipairs(cached_var_num_019) do
                                if item_123.t == "constant" then
                                    local cached_const_008 = item_123.const;
                                    if cached_const_008.type == 2 and cached_const_008.value == 0.5 then
                                        constant_value_128 = constant_value_128 + 1;
                                    end;
                                end;
                            end;
                            if constant_value_128 == 2 then
                                return "one";
                            elseif constant_value_128 == 1 then
                                return "rounded";
                            else
                                return "floored";
                            end;
                        else
                            return "floored";
                        end;
                    else
                        return "NEVER";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "floored";
                else
                    return "num";
                end;
            end,
            ["math.ceil"] = function(param_703, param_704)
                local cached_var_num_020 = param_703.var_num;
                assert(cached_var_num_020);
                if cached_var_num_020 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_704.args == 0 then
                        return "NEVER";
                    else
                        return "ceiled";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "ceiled";
                else
                    return "num";
                end;
            end,
            ["math.round"] = function(param_705, param_706)
                local cached_var_num_021 = param_705.var_num;
                assert(cached_var_num_021);
                if cached_var_num_021 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_706.args == 0 then
                        return "NEVER";
                    else
                        return "rounded";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "rounded";
                else
                    return "num";
                end;
            end,
            ["math.sin"] = function(param_707, param_708)
                local cached_var_num_022 = param_707.var_num;
                assert(cached_var_num_022);
                if cached_var_num_022 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_708.args == 0 then
                        return "NEVER";
                    else
                        return "sine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "sine";
                else
                    return "num";
                end;
            end,
            ["math.sinh"] = function(param_709, param_710)
                local cached_var_num_023 = param_709.var_num;
                assert(cached_var_num_023);
                if cached_var_num_023 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_710.args == 0 then
                        return "NEVER";
                    else
                        return "hypsine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "hypsine";
                else
                    return "num";
                end;
            end,
            ["math.asin"] = function(param_711, param_712)
                local cached_var_num_024 = param_711.var_num;
                assert(cached_var_num_024);
                if cached_var_num_024 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_712.args == 0 then
                        return "NEVER";
                    else
                        return "arcsine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "arcsine";
                else
                    return "num";
                end;
            end,
            ["math.cos"] = function(param_713, param_714)
                local cached_var_num_025 = param_713.var_num;
                assert(cached_var_num_025);
                if cached_var_num_025 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_714.args == 0 then
                        return "NEVER";
                    else
                        return "cosine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cosine";
                else
                    return "num";
                end;
            end,
            ["math.cosh"] = function(param_715, param_716)
                local cached_var_num_026 = param_715.var_num;
                assert(cached_var_num_026);
                if cached_var_num_026 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_716.args == 0 then
                        return "NEVER";
                    else
                        return "hypcosine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "hypcosine";
                else
                    return "num";
                end;
            end,
            ["math.acos"] = function(param_717, param_718)
                local cached_var_num_027 = param_717.var_num;
                assert(cached_var_num_027);
                if cached_var_num_027 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_718.args == 0 then
                        return "NEVER";
                    else
                        return "arccosine";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "arccosine";
                else
                    return "num";
                end;
            end,
            ["math.tan"] = function(param_719, param_720)
                local cached_var_num_028 = param_719.var_num;
                assert(cached_var_num_028);
                if cached_var_num_028 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_720.args == 0 then
                        return "NEVER";
                    else
                        return "tangent";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "tangent";
                else
                    return "num";
                end;
            end,
            ["math.tanh"] = function(param_721, param_722)
                local cached_var_num_029 = param_721.var_num;
                assert(cached_var_num_029);
                if cached_var_num_029 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_722.args == 0 then
                        return "NEVER";
                    else
                        return "hyptangent";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "hyptangent";
                else
                    return "num";
                end;
            end,
            ["math.atan"] = function(param_723, param_724)
                local cached_var_num_030 = param_723.var_num;
                assert(cached_var_num_030);
                if cached_var_num_030 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_724.args == 0 then
                        return "NEVER";
                    else
                        return "arctangent";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "arctangent";
                else
                    return "num";
                end;
            end,
            ["math.atan2"] = function(param_725, param_726)
                local cached_var_num_031 = param_725.var_num;
                assert(cached_var_num_031);
                if cached_var_num_031 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_726.args < 2 then
                        return "NEVER";
                    else
                        return "arctangent";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "arctangent";
                else
                    return "num";
                end;
            end,
            ["math.rad"] = function(param_727, param_728)
                local cached_var_num_032 = param_727.var_num;
                assert(cached_var_num_032);
                if cached_var_num_032 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_728.args == 0 then
                        return "NEVER";
                    else
                        return "radians";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "radians";
                else
                    return "num";
                end;
            end,
            ["math.deg"] = function(param_729, param_730)
                local cached_var_num_033 = param_729.var_num;
                assert(cached_var_num_033);
                if cached_var_num_033 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_730.args == 0 then
                        return "NEVER";
                    else
                        return "degrees";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "degrees";
                else
                    return "num";
                end;
            end,
            ["math.sign"] = function(param_731, param_732)
                local cached_var_num_034 = param_731.var_num;
                assert(cached_var_num_034);
                if cached_var_num_034 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_732.args == 0 then
                        return "NEVER";
                    else
                        return "sign";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "sign";
                else
                    return "num";
                end;
            end,
            ["math.exp"] = function(param_733, param_734)
                local cached_var_num_035 = param_733.var_num;
                assert(cached_var_num_035);
                if cached_var_num_035 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_734.args == 0 then
                        return "NEVER";
                    else
                        return "exponentiated";
                    end;
                else
                    return "num";
                end;
            end,
            ["math.clamp"] = function(param_735, param_736)
                local cached_var_num_036 = param_735.var_num;
                assert(cached_var_num_036);
                if cached_var_num_036 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_736.args < 3 then
                        return "NEVER";
                    else
                        return "clamped";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "clamped";
                else
                    return "num";
                end;
            end,
            ["math.min"] = function(param_737, param_738)
                local cached_var_num_037 = param_737.var_num;
                assert(cached_var_num_037);
                if cached_var_num_037 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_738.args == 0 then
                        return "NEVER";
                    else
                        return "minimum";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "minimum";
                else
                    return "num";
                end;
            end,
            ["math.max"] = function(param_739, param_740)
                local cached_var_num_038 = param_739.var_num;
                assert(cached_var_num_038);
                if cached_var_num_038 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_740.args == 0 then
                        return "NEVER";
                    else
                        return "maximum";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "maximum";
                else
                    return "num";
                end;
            end,
            ["Random.new"] = function(param_741, _)
                local cached_var_num_039 = param_741.var_num;
                assert(cached_var_num_039);
                if cached_var_num_039 > 1 then
                    return local_symbol_222;
                else
                    return "random_state";
                end;
            end,
            ["bit32.lshift"] = function(param_742, param_743)
                local cached_var_num_040 = param_742.var_num;
                assert(cached_var_num_040);
                if cached_var_num_040 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_743.args < 2 then
                        return "NEVER";
                    else
                        return "lshifted";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "shifted";
                else
                    return "num";
                end;
            end,
            ["bit32.rshift"] = function(param_744, param_745)
                local cached_var_num_041 = param_744.var_num;
                assert(cached_var_num_041);
                if cached_var_num_041 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_745.args < 2 then
                        return "NEVER";
                    else
                        return "rshifted";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "shifted";
                else
                    return "num";
                end;
            end,
            ["bit32.arshift"] = function(param_746, param_747)
                local cached_var_num_042 = param_746.var_num;
                assert(cached_var_num_042);
                if cached_var_num_042 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_747.args < 2 then
                        return "NEVER";
                    else
                        return "arshifted";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "shifted";
                else
                    return "num";
                end;
            end,
            ["bit32.lrotate"] = function(param_748, param_749)
                local cached_var_num_043 = param_748.var_num;
                assert(cached_var_num_043);
                if cached_var_num_043 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_749.args < 2 then
                        return "NEVER";
                    else
                        return "lrotated";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "rotated";
                else
                    return "num";
                end;
            end,
            ["bit32.rrotate"] = function(param_750, param_751)
                local cached_var_num_044 = param_750.var_num;
                assert(cached_var_num_044);
                if cached_var_num_044 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_751.args < 2 then
                        return "NEVER";
                    else
                        return "rrotated";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "rotated";
                else
                    return "num";
                end;
            end,
            ["bit32.band"] = function(param_752, param_753)
                local cached_var_num_045 = param_752.var_num;
                assert(cached_var_num_045);
                if cached_var_num_045 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_753.args == 0 then
                        return "bit32_max";
                    else
                        return "masked";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "masked";
                else
                    return "num";
                end;
            end,
            ["bit32.bor"] = function(param_754, param_755)
                local cached_var_num_046 = param_754.var_num;
                assert(cached_var_num_046);
                if cached_var_num_046 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_755.args == 0 then
                        return "zero";
                    else
                        return "flags";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "flags";
                else
                    return "num";
                end;
            end,
            ["bit32.bxor"] = function(param_756, param_757)
                local cached_var_num_047 = param_756.var_num;
                assert(cached_var_num_047);
                if cached_var_num_047 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_757.args == 0 then
                        return "zero";
                    else
                        return "xored";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "xored";
                else
                    return "num";
                end;
            end,
            ["bit32.bnot"] = function(param_758, param_759)
                local cached_var_num_048 = param_758.var_num;
                assert(cached_var_num_048);
                if cached_var_num_048 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_759.args == 0 then
                        return "NEVER";
                    else
                        return "inverted";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "inverted";
                else
                    return "num";
                end;
            end,
            ["bit32.btest"] = function(param_760, param_761)
                local cached_var_num_049 = param_760.var_num;
                assert(cached_var_num_049);
                if cached_var_num_049 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_761.args == 0 then
                        return "true_";
                    else
                        return "found_common_bit";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "found_common_bit";
                else
                    return "num";
                end;
            end,
            ["bit32.countlz"] = function(param_762, param_763)
                local cached_var_num_050 = param_762.var_num;
                assert(cached_var_num_050);
                if cached_var_num_050 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_763.args == 0 then
                        return "NEVER";
                    else
                        return "zero_count_left";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "zero_count";
                else
                    return "num";
                end;
            end,
            ["bit32.countrz"] = function(param_764, param_765)
                local cached_var_num_051 = param_764.var_num;
                assert(cached_var_num_051);
                if cached_var_num_051 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_765.args == 0 then
                        return "NEVER";
                    else
                        return "zero_count_right";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "zero_count";
                else
                    return "num";
                end;
            end,
            ["bit32.extract"] = function(param_766, param_767)
                local cached_var_num_052 = param_766.var_num;
                assert(cached_var_num_052);
                if cached_var_num_052 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_767.args < 2 then
                        return "NEVER";
                    else
                        return "extracted";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "extracted";
                else
                    return "num";
                end;
            end,
            ["bit32.replace"] = function(param_768, param_769)
                local cached_var_num_053 = param_768.var_num;
                assert(cached_var_num_053);
                if cached_var_num_053 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_769.args < 3 then
                        return "NEVER";
                    else
                        return "replaced";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "replaced";
                else
                    return "num";
                end;
            end,
            ["debug.traceback"] = function(param_770, _)
                local cached_var_num_054 = param_770.var_num;
                assert(cached_var_num_054);
                if cached_var_num_054 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "call_stack";
                else
                    return "num";
                end;
            end,
            ["debug.info"] = function(param_771, param_772)
                if condition_value_015.smart_var_level >= 2 then
                    if #param_772.args < 2 then
                        return "NEVER";
                    else
                        local constant_value_129 = if #param_772.args == 2 then param_772.args[2] else param_772.args[3];
                        if constant_value_129.t == "constant" then
                            local cached_const_009 = constant_value_129.const;
                            if cached_const_009.type == 3 then
                                local cached_value_021 = cached_const_009.value;
                                if cached_value_021 == "s" then
                                    local cached_var_num_055 = param_771.var_num;
                                    assert(cached_var_num_055);
                                    if cached_var_num_055 == 1 then
                                        return "func_source";
                                    end;
                                elseif cached_value_021 == "l" then
                                    local cached_var_num_056 = param_771.var_num;
                                    assert(cached_var_num_056);
                                    if cached_var_num_056 == 1 then
                                        return "line_defined";
                                    end;
                                elseif cached_value_021 == "n" then
                                    local cached_var_num_057 = param_771.var_num;
                                    assert(cached_var_num_057);
                                    if cached_var_num_057 == 1 then
                                        return "func_name";
                                    end;
                                elseif cached_value_021 == "a" then
                                    local cached_var_num_058 = param_771.var_num;
                                    assert(cached_var_num_058);
                                    local cached_var_num = cached_var_num_058;
                                    if cached_var_num == 1 then
                                        return "parameter_count";
                                    elseif cached_var_num == 2 then
                                        return "is_vararg";
                                    else
                                        return local_symbol_222;
                                    end;
                                elseif cached_value_021 == "f" then
                                    local cached_var_num_059 = param_771.var_num;
                                    assert(cached_var_num_059);
                                    if cached_var_num_059 == 1 then
                                        return "func";
                                    end;
                                end;
                            end;
                            return "NEVER";
                        else
                            local cached_var_num_060 = param_771.var_num;
                            assert(cached_var_num_060);
                            if cached_var_num_060 == 1 then
                                return "info";
                            end;
                        end;
                    end;
                else
                    local cached_var_num_061 = param_771.var_num;
                    assert(cached_var_num_061);
                    if cached_var_num_061 == 1 then
                        return "num";
                    end;
                end;
                return local_symbol_222;
            end,
            ["Vector3.new"] = function(param_773, param_774)
                local cached_var_num_062 = param_773.var_num;
                assert(cached_var_num_062);
                if cached_var_num_062 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_774.args == 0 then
                        return "zero_vector3";
                    else
                        return "vector3";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "vector3";
                else
                    return "vector";
                end;
            end,
            ["Vector2.new"] = function(param_775, param_776)
                local cached_var_num_063 = param_775.var_num;
                assert(cached_var_num_063);
                if cached_var_num_063 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_776.args == 0 then
                        return "zero_vector2";
                    else
                        return "vector2";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "vector2";
                else
                    return "vector";
                end;
            end,
            ["UDim.new"] = function(param_777, param_778)
                local cached_var_num_064 = param_777.var_num;
                assert(cached_var_num_064);
                if cached_var_num_064 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_778.args == 0 then
                        return "zero_udim";
                    else
                        return "udim";
                    end;
                else
                    return "udim";
                end;
            end,
            ["UDim2.new"] = function(param_779, param_780)
                local cached_var_num_065 = param_779.var_num;
                assert(cached_var_num_065);
                if cached_var_num_065 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_780.args == 0 then
                        return "zero_udim2";
                    else
                        return "udim2";
                    end;
                else
                    return "udim2";
                end;
            end,
            ["UDim2.fromOffset"] = function(param_781, param_782)
                local cached_var_num_066 = param_781.var_num;
                assert(cached_var_num_066);
                if cached_var_num_066 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_782.args == 0 then
                        return "zero_udim2";
                    else
                        return "udim2";
                    end;
                else
                    return "udim2";
                end;
            end,
            ["UDim2.fromScale"] = function(param_783, param_784)
                local cached_var_num_067 = param_783.var_num;
                assert(cached_var_num_067);
                if cached_var_num_067 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_784.args == 0 then
                        return "zero_udim2";
                    else
                        return "udim2";
                    end;
                else
                    return "udim2";
                end;
            end,
            ["CFrame.new"] = function(param_785, param_786)
                local cached_var_num_068 = param_785.var_num;
                assert(cached_var_num_068);
                if cached_var_num_068 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_786.args == 0 then
                    return "zero_cframe";
                else
                    return "cframe";
                end;
            end,
            ["CFrame.Angles"] = function(param_787, param_788)
                local cached_var_num_069 = param_787.var_num;
                assert(cached_var_num_069);
                if cached_var_num_069 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_788.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe" or "");
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromEulerAnglesXYZ"] = function(param_789, param_790)
                local cached_var_num_070 = param_789.var_num;
                assert(cached_var_num_070);
                if cached_var_num_070 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_790.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe" or "");
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromEulerAnglesYXZ"] = function(param_791, param_792)
                local cached_var_num_071 = param_791.var_num;
                assert(cached_var_num_071);
                if cached_var_num_071 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_792.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe" or "");
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromEulerAngles"] = function(param_793, param_794)
                local cached_var_num_072 = param_793.var_num;
                assert(cached_var_num_072);
                if cached_var_num_072 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_794.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe" or "");
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromOrientation"] = function(param_795, param_796)
                local cached_var_num_073 = param_795.var_num;
                assert(cached_var_num_073);
                if cached_var_num_073 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_796.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe" or "");
                else
                    return "cframe";
                end;
            end,
            ["CFrame.lookAt"] = function(param_797, param_798)
                local cached_var_num_074 = param_797.var_num;
                assert(cached_var_num_074);
                if cached_var_num_074 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_798.args < 2 then
                    return "NEVER" .. (condition_value_143 and "_cframe_looking_at" or "");
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cframe_looking_at";
                else
                    return "cframe";
                end;
            end,
            ["CFrame.lookAlong"] = function(param_799, param_800)
                local cached_var_num_075 = param_799.var_num;
                assert(cached_var_num_075);
                if cached_var_num_075 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_800.args < 2 then
                    return "NEVER" .. (condition_value_143 and "_cframe_looking_along" or "");
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cframe_looking_along";
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromMatrix"] = function(param_801, param_802)
                local cached_var_num_076 = param_801.var_num;
                assert(cached_var_num_076);
                if cached_var_num_076 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_802.args < 3 then
                    return "NEVER" .. (condition_value_143 and "_cframe_matrix" or "");
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cframe_matrix";
                else
                    return "cframe";
                end;
            end,
            ["CFrame.fromAxisAngle"] = function(param_803, param_804)
                local cached_var_num_077 = param_803.var_num;
                assert(cached_var_num_077);
                if cached_var_num_077 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 and #param_804.args < 2 then
                    return "NEVER" .. (condition_value_143 and "_cframe_axis_angle" or "");
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cframe_axis_angle";
                else
                    return "cframe";
                end;
            end,
            ["game.GetService"] = function(param_805, param_806)
                local cached_var_num_078 = param_805.var_num;
                assert(cached_var_num_078);
                if cached_var_num_078 > 1 then
                    return local_symbol_222;
                else
                    local cached_args_012 = param_806.args;
                    if condition_value_015.smart_var_level >= 3 and #cached_args_012 == 0 then
                        return "NEVER" .. (condition_value_143 and "_service" or "");
                    else
                        cached_var_num_078 = if condition_value_015.smart_var_level >= 3 then cached_args_012 else {
                            cached_args_012[1]
                        };
                        local constant_value_130 = nil;
                        for _, item_124 in ipairs(cached_var_num_078) do
                            if item_124.t == "constant" and condition_value_015.smart_var_level >= 2 then
                                local cached_const_010 = item_124.const;
                                if cached_const_010.type == 3 then
                                    return cached_const_010.value .. (condition_value_143 and "_service" or "");
                                elseif condition_value_015.smart_var_level >= 3 then
                                    constant_value_130 = true;
                                end;
                            end;
                        end;
                        if constant_value_130 then
                            return "NEVER" .. (condition_value_143 and "_service" or "");
                        elseif condition_value_015.smart_var_level >= 2 then
                            return "service";
                        else
                            return;
                        end;
                    end;
                end;
            end,
            select = function(param_807, param_808)
                local cached_var_num_079 = param_807.var_num;
                assert(cached_var_num_079);
                if cached_var_num_079 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 2 then
                    local cached_args_013 = param_808.args;
                    cached_var_num_079 = cached_args_013[1];
                    if cached_var_num_079 then
                        if cached_var_num_079.t == "constant" then
                            local cached_const_011 = cached_var_num_079.const;
                            if cached_const_011.type == 3 and cached_const_011.value == "#" then
                                if #cached_args_013 == 2 and cached_args_013[2].t == "varargs" then
                                    return "arg_count";
                                else
                                    return "len";
                                end;
                            end;
                        end;
                        if #cached_args_013 == 2 and cached_args_013[2].t == "varargs" then
                            return "selected_arg";
                        else
                            return "selected";
                        end;
                    else
                        return "NEVER";
                    end;
                else
                    return;
                end;
            end,
            require = function(param_809, param_810)
                local cached_var_num_080 = param_809.var_num;
                assert(cached_var_num_080);
                if cached_var_num_080 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 2 then
                    cached_var_num_080 = param_810.args[1];
                    if cached_var_num_080 then
                        local constant_value_131 = nil;
                        if not (cached_var_num_080.t ~= "constant index") or cached_var_num_080.t == "get table" then
                            local _ = cached_var_num_080.const;
                            local string_value_050, _ = helper_function_118(cached_var_num_080);
                            local _ = nil;
                            local string_value_051 = string.reverse(string_value_050);
                            local string_value_052 = string.find(string_value_051, "%.");
                            constant_value_131 = if string_value_052 then string.sub(string_value_050, #string_value_050 - string_value_052 + 2, #string_value_050) else string_value_050;
                        elseif not (cached_var_num_080.t ~= "name") or cached_var_num_080.t == "global" then
                            constant_value_131 = if cached_var_num_080.t == "name" then cached_var_num_080.name.name else if cached_var_num_080.name.type == 3 then cached_var_num_080.name.value else "INVALIDGLOBAL";
                        end;
                        if constant_value_131 then
                            return (condition_value_143 and "module_" or "") .. constant_value_131;
                        elseif cached_var_num_080.t == "constant" then
                            local cached_const_012 = cached_var_num_080.const;
                            if cached_const_012.type == 2 then
                                return "external_module";
                            elseif cached_const_012.type == 3 then
                                return (condition_value_143 and "module_" or "") .. make_safe_identifier(cached_const_012.value, true, true);
                            end;
                        else
                            return "module";
                        end;
                    end;
                    return "NEVER";
                else
                    return;
                end;
            end,
            ["table.clear"] = function(_, _)
                return local_symbol_222;
            end,
            ["table.foreach"] = function(_, _)
                return local_symbol_222;
            end,
            ["table.foreachi"] = function(_, _)
                return local_symbol_222;
            end,
            ["table.insert"] = function(_, _)
                return local_symbol_222;
            end,
            ["table.sort"] = function(_, _)
                return local_symbol_222;
            end,
            ["table.clone"] = function(param_811, param_812)
                local cached_var_num_081 = param_811.var_num;
                assert(cached_var_num_081);
                if cached_var_num_081 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_812.args == 0 then
                        return "NEVER";
                    else
                        return "cloned" .. (condition_value_143 and "_tbl" or "");
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "cloned";
                else
                    return "tbl";
                end;
            end,
            ["table.concat"] = function(param_813, param_814)
                local cached_var_num_082 = param_813.var_num;
                assert(cached_var_num_082);
                if cached_var_num_082 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_814.args < 2 then
                        return "NEVER";
                    else
                        return "concatenated" .. (condition_value_143 and "_tbl" or "");
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "concatenated";
                else
                    return "str";
                end;
            end,
            ["table.getn"] = function(param_815, param_816)
                local cached_var_num_083 = param_815.var_num;
                assert(cached_var_num_083);
                if cached_var_num_083 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_816.args == 0 then
                        return "NEVER";
                    else
                        return (condition_value_143 and "tbl_" or "") .. "len";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "len";
                else
                    return "num";
                end;
            end,
            ["table.maxn"] = function(param_817, param_818)
                local cached_var_num_084 = param_817.var_num;
                assert(cached_var_num_084);
                if cached_var_num_084 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_818.args == 0 then
                        return "NEVER";
                    else
                        return (condition_value_143 and "tbl_" or "") .. "highest_value";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "highest_value";
                else
                    return "num";
                end;
            end,
            ["table.isfrozen"] = function(param_819, param_820)
                local cached_var_num_085 = param_819.var_num;
                assert(cached_var_num_085);
                if cached_var_num_085 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_820.args == 0 then
                        return "NEVER";
                    else
                        return (condition_value_143 and "tbl_" or "") .. "is_frozen";
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "is_frozen";
                else
                    return "bool";
                end;
            end,
            ["table.pack"] = function(param_821, _)
                local cached_var_num_086 = param_821.var_num;
                assert(cached_var_num_086);
                if cached_var_num_086 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    return "packed" .. (condition_value_143 and "_tbl" or "");
                elseif condition_value_015.smart_var_level >= 2 then
                    return "packed";
                else
                    return "tbl";
                end;
            end,
            ["table.unpack"] = function(param_822, _)
                if condition_value_015.smart_var_level >= 2 then
                    local local_symbol_224 = "unpacked_value_";
                    local cached_var_num_087 = param_822.var_num;
                    assert(cached_var_num_087);
                    return local_symbol_224 .. cached_var_num_087;
                else
                    return;
                end;
            end,
            ["table.remove"] = function(param_823, param_824)
                local cached_var_num_088 = param_823.var_num;
                assert(cached_var_num_088);
                if cached_var_num_088 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_824.args == 0 then
                        return "NEVER";
                    elseif #param_824.args == 1 then
                        return "popped" .. (condition_value_143 and "_last_value" or "");
                    else
                        return "popped" .. (condition_value_143 and "_value" or "");
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "popped";
                else
                    return;
                end;
            end,
            ["table.move"] = function(param_825, param_826)
                local cached_var_num_089 = param_825.var_num;
                assert(cached_var_num_089);
                if cached_var_num_089 > 1 then
                    return local_symbol_222;
                elseif condition_value_015.smart_var_level >= 3 then
                    if #param_826.args < 4 then
                        return "NEVER";
                    else
                        return "moved" .. (condition_value_143 and "_tbl" or "");
                    end;
                elseif condition_value_015.smart_var_level >= 2 then
                    return "moved";
                else
                    return "tbl";
                end;
            end,
            ["coroutine.running"] = function(param_827, _)
                local cached_var_num_090 = param_827.var_num;
                assert(cached_var_num_090);
                if cached_var_num_090 > 1 then
                    return local_symbol_222;
                else
                    return "current_thread";
                end;
            end
        };
        if condition_value_015.smart_var_level >= 3 then
            local _ = function(param_828)
                local string_value_053 = cached_Clone[param_828];
                assert(string_value_053);
                local cached_table_value_010 = table_value_168;
                local _ = nil;
                local string_value_054 = string.reverse(param_828);
                local string_value_055 = string.find(string_value_054, "%.");
                cached_table_value_010[if string_value_055 then string.sub(param_828, #param_828 - string_value_055 + 2, #param_828) else param_828] = string_value_053;
            end;
            local _ = function(param_829)
                local local_symbol_225 = cached_Clone[param_829];
                assert(local_symbol_225);
                if condition_value_015.smart_var_level >= 4 then
                    local cached_table_value_011 = table_value_168;
                    local _ = nil;
                    local string_value_056 = string.reverse(param_829);
                    local string_value_057 = string.find(string_value_056, "%.");
                    cached_table_value_011[if string_value_057 then string.sub(param_829, #param_829 - string_value_057 + 2, #param_829) else param_829] = local_symbol_225;
                    return;
                else
                    local cached_table_value_012 = table_value_168;
                    local _ = nil;
                    local string_value_058 = string.reverse(param_829);
                    local string_value_059 = string.find(string_value_058, "%.");
                    cached_table_value_012[if string_value_059 then string.sub(param_829, #param_829 - string_value_059 + 2, #param_829) else param_829] = function(param_830, param_831)
                        local string_value_060 = local_symbol_225(param_830, param_831);
                        if string_value_060 then
                            if string.match(string_value_060, "NEVER") then
                                return;
                            else
                                return string_value_060;
                            end;
                        else
                            return;
                        end;
                    end;
                    return;
                end;
            end;
            local string_value_061 = cached_Clone["game.GetService"];
            assert(string_value_061);
            if condition_value_015.smart_var_level >= 4 then
                local _ = nil;
                local string_value_062 = string.reverse("game.GetService");
                local string_value_063 = string.find(string_value_062, "%.");
                table_value_168[if string_value_063 then string.sub("game.GetService", 15 - string_value_063 + 2, 15) else "game.GetService"] = string_value_061;
            else
                local _ = nil;
                local string_value_064 = string.reverse("game.GetService");
                local string_value_065 = string.find(string_value_064, "%.");
                local cached_string_value_023 = string_value_061 ;
                table_value_168[if string_value_065 then string.sub("game.GetService", 15 - string_value_065 + 2, 15) else "game.GetService"] = function(param_832, param_833)
                    local string_value_066 = cached_string_value_023(param_832, param_833);
                    if string_value_066 then
                        if string.match(string_value_066, "NEVER") then
                            return;
                        else
                            return string_value_066;
                        end;
                    else
                        return;
                    end;
                end;
            end;
        end;
        local constant_value_132 = nil;
        constant_value_132 = {
            call = function(param_834, param_835, _)
                local cached_func = param_835.func;
                if not (cached_func.t ~= "constant index") or cached_func.t == "get table" then
                    local constant_value_133, constant_value_134 = helper_function_118(cached_func);
                    if constant_value_134 and condition_value_015.smart_var_level < 2 then
                        return;
                    else
                        if condition_value_015.smart_var_level >= 2 then
                            local cached_table_value_013 = table_value_168;
                            local _ = nil;
                            local string_value_067 = string.reverse(constant_value_133);
                            local string_value_068 = string.find(string_value_067, "%.");
                            local string_value_069 = cached_table_value_013[if string_value_068 then string.sub(constant_value_133, #constant_value_133 - string_value_068 + 2, #constant_value_133) else constant_value_133];
                            if string_value_069 then
                                cached_table_value_013 = string_value_069(param_834, param_835);
                                if cached_table_value_013 then
                                    return cached_table_value_013;
                                end;
                            end;
                        end;
                        local condition_value_148 = cached_Clone[constant_value_133];
                        if condition_value_148 then
                            return condition_value_148(param_834, param_835);
                        elseif condition_value_015.smart_var_level >= 3 then
                            return make_safe_identifier(constant_value_133, nil, true) .. "_result" .. (param_834.var_num or "");
                        end;
                    end;
                elseif not (cached_func.t ~= "name") or cached_func.t == "global" then
                    local condition_value_149 = nil;
                    condition_value_149 = if cached_func.t == "name" then cached_func.name.name else if cached_func.name.type == 3 then cached_func.name.value else "INVALIDGLOBAL";
                    local condition_value_150 = cached_Clone[condition_value_149];
                    if condition_value_150 then
                        return condition_value_150(param_834, param_835);
                    elseif condition_value_015.smart_var_level >= 3 then
                        return make_safe_identifier(condition_value_149, nil, true) .. "_result" .. (param_834.var_num or "");
                    end;
                end;
            end,
            ["new table"] = function(param_836, param_837, _)
                local local_symbol_226 = false;
                local cached_initializers = param_837.initializers;
                local condition_value_151 = "";
                if condition_value_015.smart_var_level >= 2 then
                    if #cached_initializers == 0 then
                        if next(cached_initializers) then
                            condition_value_151 = condition_value_143 and "_dict" or "";
                        end;
                    else
                        condition_value_151 = if next(cached_initializers) then condition_value_143 and "_mixed" or "" else condition_value_143 and "_list" or "";
                    end;
                end;
                local local_symbol_227 = "";
                if condition_value_015.smart_var_usage_analysis then
                    local condition_value_152 = true;
                    for _, item_125 in ipairs(param_836.reads) do
                        if item_125.t == "set table" then
                            condition_value_152 = false;
                            break;
                        end;
                    end;
                    if condition_value_152 then
                        local_symbol_227 = condition_value_143 and "const_" or "";
                    end;
                end;
                for _, item_126 in ipairs(cached_initializers) do
                    if item_126.t == "varargs" then
                        if condition_value_015.smart_var_level >= 2 then
                            condition_value_151 = condition_value_151 .. "_varargs";
                        end;
                        if #cached_initializers == 1 then
                            if condition_value_015.smart_var_level >= 3 then
                                return "args_list";
                            else
                                return "args";
                            end;
                        else
                            break;
                        end;
                    end;
                end;
                local cached_reads_002 = param_836.reads;
                local condition_value_153 = cached_reads_002[#cached_reads_002];
                local condition_value_154;
                if condition_value_153 and condition_value_153.t == "return" then
                    local table_value_169 = {};
                    local cached_values_001 = condition_value_153.values;
                    if condition_value_015.smart_var_level == 3 then
                        condition_value_154 = true;
                        local_symbol_226 = true;
                    elseif #table_value_169 == 1 then
                        table_value_169 = cached_values_001;
                    else
                        condition_value_154 = nil;
                        local_symbol_226 = true;
                    end;
                end;
                if not local_symbol_226 then
                    if not local_symbol_226 then
                        condition_value_154 = nil;
                    end;
                end;
                local_symbol_226 = false;
                if condition_value_154 then
                    return local_symbol_227 .. "module" .. condition_value_151;
                else
                    return local_symbol_227 .. "tbl" .. condition_value_151;
                end;
            end,
            ["constant index"] = function(_, param_838, _)
                if condition_value_015.smart_var_level >= 2 then
                    return (make_safe_identifier(format_constant(param_838.index, condition_value_015.string_quotes_behavior, true)));
                else
                    return;
                end;
            end,
            ["get table"] = function(_, param_839, _)
                if condition_value_015.smart_var_level >= 2 then
                    local cached_index_004 = param_839.index;
                    if cached_index_004.t == "constant" then
                        local constant_value_135 = format_constant(cached_index_004.const, condition_value_015.string_quotes_behavior, true);
                        if cached_index_004.const.type ~= 3 then
                            constant_value_135 = "_" .. constant_value_135;
                        end;
                        return (make_safe_identifier(constant_value_135));
                    end;
                end;
            end,
            constant = function(param_840, param_841, _)
                if not condition_value_015.smart_var_usage_analysis then
                    return;
                else
                    local condition_value_155 = #param_840.writes <= 1;
                    if condition_value_155 then
                        for _, item_127 in ipairs(param_840.reads) do
                            if item_127.t == "set table" then
                                condition_value_155 = false;
                                break;
                            end;
                        end;
                    end;
                    if condition_value_155 then
                        local cached_type_009 = param_841.const.type;
                        if cached_type_009 == 1 then
                            return "const_boolean";
                        elseif cached_type_009 == 6 then
                            return "const_function";
                        elseif cached_type_009 == 4 then
                            return "const_import";
                        elseif cached_type_009 == 0 then
                            return "const_nil";
                        elseif cached_type_009 == 3 then
                            return "const_string";
                        elseif cached_type_009 == 2 then
                            return "const_number";
                        elseif cached_type_009 == 5 then
                            return "const_table";
                        elseif cached_type_009 == 7 then
                            return "const_vector";
                        else
                            return "const_unknown";
                        end;
                    else
                        return;
                    end;
                end;
            end,
            length = function(_, param_842, _)
                if condition_value_015.smart_var_level >= 2 then
                    local cached_rhs_008 = param_842.rhs;
                    while cached_rhs_008.t == "name" do
                        local cached_override_expr_018 = cached_rhs_008.name.override_expr;
                        if cached_override_expr_018 then
                            cached_rhs_008 = cached_override_expr_018;
                        else
                            break;
                        end;
                    end;
                    local cached_rhs = cached_rhs_008;
                    if cached_rhs.t == "name" then
                        cached_rhs_008 = cached_rhs.name.name;
                        if not (cached_rhs_008 ~= "args") or cached_rhs_008 == "args_list" then
                            return "arg_count";
                        end;
                    elseif cached_rhs.t == "new table" then
                        cached_rhs_008 = cached_rhs.initializers;
                        if #cached_rhs_008 == 1 and cached_rhs_008[1].t == "varargs" then
                            return "arg_count";
                        end;
                    end;
                    return "len";
                else
                    return;
                end;
            end,
            global = function(_, param_843, _)
                return (make_safe_identifier(format_constant(param_843.name, condition_value_015.string_quotes_behavior, true)));
            end
        };
        local function _(param_844, param_845)
            local string_value_070 = constant_value_132[param_845.t];
            if string_value_070 then
                local condition_value_156 = string_value_070(param_844, param_845, true);
                if condition_value_156 then
                    return condition_value_156;
                end;
            end;
        end;
        local function is_valid_identifier(name)
    		return type(name) == "string"
        		and name:match("^[a-zA-Z_][a-zA-Z0-9_]*$") ~= nil
        		and not LUAU_RESERVED_KEYWORDS[name]
		end;
        for _, item_128 in pairs(table.clone(table_value_023)) do
            local cached_attributes_001 = item_128.attributes;
            local cached_name_017 = item_128.name;
            local cached_name_018 = cached_name_017;
            local cached_init_expr_002 = item_128.init_expr;
            if cached_init_expr_002 then
                if condition_value_015.smart_var_level > 0 then
                    local expression_value_089 = constant_value_132[cached_init_expr_002.t];
                    cached_name_017 = expression_value_089 and expression_value_089(item_128, cached_init_expr_002, true) or nil or cached_name_017;
                end;
                if cached_name_017 ~= cached_name_018 then
                    if not is_valid_identifier(cached_name_017) then
                        cached_name_017 = cached_name_018;
                    end;

                    local cached_name_019 = cached_name_017;
                    local local_symbol_228 = table_value_024[cached_name_019];
                    local cached_name = cached_name_019;
                    local local_symbol_229 = local_symbol_228 or 1;
                    while table_value_023[cached_name] or table_value_018[cached_name] do
                        local_symbol_229 = local_symbol_229 + 1;
                        cached_name = cached_name_019 .. "_" .. local_symbol_229;
                        if not is_valid_identifier(cached_name) then
                            break;
                        end;
                    end;
                    if is_valid_identifier(cached_name) then
                        table_value_024[cached_name_019] = local_symbol_229;
                        cached_name_017 = cached_name;
                    else
                        cached_name_017 = cached_name_018;
                    end;
                end;
                if cached_attributes_001.is_upvalue and condition_value_015.mark_upvalues then
                    local register_value_017 = if condition_value_015.mark_upvalues == "extra" then if cached_attributes_001.is_upvalue == "read" then cached_name_017 .. "_upvr" else cached_name_017 .. "_upvw" else cached_name_017 .. "_upv";
                    local condition_value_157 = table_value_024[register_value_017];
                    local cached_register_value_001 = register_value_017;
                    local local_symbol_230 = condition_value_157 or 1;
                    while table_value_023[cached_register_value_001] or table_value_018[cached_register_value_001] do
                        local_symbol_230 = local_symbol_230 + 1;
                        cached_register_value_001 = register_value_017 .. "_" .. local_symbol_230;
						if not is_valid_identifier(cached_register_value_001) then
                            break;
						end;
                    end;
                    if is_valid_identifier(cached_register_value_001) then
                        table_value_024[register_value_017] = local_symbol_230;
                        cached_name_017 = cached_register_value_001;
                    end;
                end;
                local cached_name_020 = cached_name_017;
                local cached_name_021 = item_128.name;
                if not table_value_023[cached_name_021] then
                    error((("[write] Variable %* not allocated"):format(cached_name_021)));
                end;
                table_value_023[cached_name_021] = nil;
                item_128.name = cached_name_020;
                table_value_023[cached_name_020] = item_128;
                item_128.attributes.renamed = true;
            end;
        end;
        local_symbol_009:end_benchmark("Smart Naming");
        local_symbol_009:start_benchmark("Global AST To String");
        local string_value_071 = ("-- Decompiled with Konstant V%*, a fast Luau decompiler made in Luau by plusgiant5\n"):format("2.1");
        if type(param_224) ~= "string" and getscripthash_ref then
            string_value_071 = string_value_071 .. ("-- Script hash: %*\n"):format((string.upper(getscripthash_ref(param_224))));
        end;
        string_value_071 = (string_value_071 .. ("-- Decompiled on %*\n"):format((os.date("%Y-%m-%d %H:%M:%S")))) .. ("-- Luau version %*%*\n"):format(string.byte(param_224, 1, 1), if array_value_070 then (", Types version %*"):format(array_value_070) else "");
        local string_value_072 = if condition_value_015.spaces_in_indentation then string.rep(" ", condition_value_015.spaces_in_indentation) else string.char(9);
        local function helper_function_119(param_846)
            return string.rep(string_value_072, #param_846 / #string_value_072 + 1);
        end;
        local helper_function_120 = nil;
        local helper_function_121 = nil;
        local helper_function_122 = nil;
        local table_value_170 = {};
        local array_value_120 = 0;
        local function _()
            array_value_120 = array_value_120 + #string_value_071;
            table.insert(table_value_170, string_value_071);
            string_value_071 = "";
        end;
        local function _(param_847, param_848)
            array_value_120 = array_value_120 + #param_847;
            table.insert(table_value_170, param_848, param_847);
        end;
        local function _(param_849)
            local cached_string_value_024 = string_value_071;
            array_value_120 = array_value_120 + #cached_string_value_024;
            table.insert(table_value_170, param_849, cached_string_value_024);
            string_value_071 = "";
        end;
        local function _()
            if #string_value_071 > 20 then
                array_value_120 = array_value_120 + #string_value_071;
                table.insert(table_value_170, string_value_071);
                string_value_071 = "";
            end;
        end;
        array_value_120 = array_value_120 + #string_value_071;
        table.insert(table_value_170, string_value_071);
        string_value_071 = "";
        local function _(param_850)
            local array_value_121 = nil;
            local cached_type_010 = param_850.type;
            array_value_121 = cached_type_010 == "table" and "{[any]: any}" or cached_type_010 == "function" and "_function_" or cached_type_010 == "thread" and "_thread_" or cached_type_010 == "userdata" and "_userdata_" or cached_type_010 == "invalid" and "_invalid_" or cached_type_010;
            if param_850.optional then
                return array_value_121 .. "?";
            else
                return array_value_121;
            end;
        end;
        local function helper_function_123(param_851, _)
            local cached_is_vararg = param_851.is_vararg;
            local cached_args_014 = param_851.args;
            for local_symbol_231, item_129 in ipairs(cached_args_014) do
                string_value_071 = string_value_071 .. item_129.name;
                if item_129.luau_type then
                    local cached_string_value_025 = string_value_071;
                    local local_symbol_232 = ": ";
                    local cached_luau_type = item_129.luau_type;
                    local condition_value_158 = nil;
                    local cached_type_011 = cached_luau_type.type;
                    condition_value_158 = cached_type_011 == "table" and "{[any]: any}" or cached_type_011 == "function" and "_function_" or cached_type_011 == "thread" and "_thread_" or cached_type_011 == "userdata" and "_userdata_" or cached_type_011 == "invalid" and "_invalid_" or cached_type_011;
                    string_value_071 = cached_string_value_025 .. local_symbol_232 .. if cached_luau_type.optional then condition_value_158 .. "?" else condition_value_158;
                end;
                if local_symbol_231 < #cached_args_014 then
                    string_value_071 = string_value_071 .. ", ";
                end;
            end;
            if cached_is_vararg then
                if #cached_args_014 > 0 then
                    string_value_071 = string_value_071 .. ", ";
                end;
                string_value_071 = string_value_071 .. "...";
            end;
        end;
        local function _(param_852)
            return param_852 and param_852.precedence or -100;
        end;
        local function _(param_853, param_854)
            local cached_t_004 = param_853.t;
            if cached_t_004 ~= param_854.t then
                return false;
            elseif cached_t_004 == "constant" then
                return param_853.const.value == param_854.const.value;
            elseif cached_t_004 == "name" then
                return param_853.name == param_854.name;
            else
                return true;
            end;
        end;
        local function _(param_855, param_856)
            local cached_override_expr_019 = param_855.override_expr;
            if cached_override_expr_019 then
                helper_function_120(cached_override_expr_019, param_856);
                return;
            else
                string_value_071 = string_value_071 .. param_855.name;
                return;
            end;
        end;
        local _ = function(param_857, param_858, _)
            local condition_value_159 = " -- ";
            local cached_line_defined = param_857.line_defined;
            if cached_line_defined then
                if cached_line_defined == -1 then
                    string_value_071 = string_value_071 .. " -- Internal function, doesn't exist in bytecode";
                    condition_value_159 = ", ";
                elseif condition_value_015.show_proto_line_defined then
                    string_value_071 = string_value_071 .. " -- Line " .. cached_line_defined;
                    condition_value_159 = ", ";
                end;
            end;
            if param_857.name_known and param_857.name ~= param_858 then
                string_value_071 = string_value_071 .. condition_value_159 .. "Named \"" .. param_857.name .. "\"";
            end;
        end;
        local function helper_function_124(param_859, param_860)
            if condition_value_015.show_proto_upvalues then
                local cached_upvalues_count = param_859.upvalues_count;
                if cached_upvalues_count > 0 then
                    local register_value_018 = string.rep(string_value_072, #param_860 / #string_value_072 + 1);
                    string_value_071 = string_value_071 .. param_860 .. "--[[ Upvalues[" .. cached_upvalues_count .. "]:\n";
                    local cached_upvalues = param_859.upvalues;
                    for index_058 = 0, cached_upvalues_count - 1 do
                        string_value_071 = string_value_071 .. register_value_018 .. "[" .. index_058 + 1 .. "]: " .. cached_upvalues[index_058].name.name .. " (";
                        if cached_upvalues[index_058].name.name == param_859.name.name then
                            string_value_071 = string_value_071 .. "self-reference, ";
                        end;
                        string_value_071 = string_value_071 .. cached_upvalues[index_058].access .. ")\n";
                    end;
                    string_value_071 = string_value_071 .. param_860 .. "]]\n";
                end;
            end;
        end;
        local function helper_function_125(param_861, param_862)
            array_value_120 = array_value_120 + #string_value_071;
            table.insert(table_value_170, string_value_071);
            string_value_071 = "";
            local array_value_122 = string.rep(string_value_072, #param_862 / #string_value_072 + 1);
            helper_function_124(param_861, array_value_122);
            array_value_120 = array_value_120 + #string_value_071;
            table.insert(table_value_170, string_value_071);
            string_value_071 = "";
            local cached_table_value_014 = table_value_170;
            local cached_ast = param_861.ast;
            table_value_170 = table.create(#cached_ast * 5);
            helper_function_121(cached_ast, array_value_122);
            table.move(table_value_170, 1, #table_value_170, #cached_table_value_014 + 1, cached_table_value_014);
            table_value_170 = cached_table_value_014;
            array_value_120 = array_value_120 + #string_value_071;
            table.insert(table_value_170, string_value_071);
            string_value_071 = "";
        end;
        local function helper_function_126(param_863, param_864, param_865, _)
            if param_864 > 0 then
                if param_865 == 0 then
                    return param_863 .. " reads: " .. param_864;
                else
                    return param_863 .. " reads: " .. param_864 .. ", writes: " .. param_865;
                end;
            elseif param_865 ~= 0 then
                return param_863 .. " writes: " .. param_865;
            else
                return param_863 .. " unused";
            end;
        end;
        local function helper_function_127(param_866, param_867)
            for condition_value_160, item_130 in ipairs(param_866) do
                local cached_string_value_026 = string_value_071;
                local condition_value_161 = #param_866 == 1 and "-- Variable" or "-- Variables[" .. condition_value_160 .. "]";
                local condition_value_162 = #item_130.reads;
                local condition_value_163 = #item_130.writes - 1;
                string_value_071 = cached_string_value_026 .. (if condition_value_162 > 0 then if condition_value_163 == 0 then condition_value_161 .. " reads: " .. condition_value_162 else condition_value_161 .. " reads: " .. condition_value_162 .. ", writes: " .. condition_value_163 else if condition_value_163 ~= 0 then condition_value_161 .. " writes: " .. condition_value_163 else condition_value_161 .. " unused") .. "\n" .. param_867;
            end;
        end;
        local table_value_171 = {
            nothing = function(_, _)
                error("Shouldn't happen !!!!!!!!!!");
            end,
            comment = function(param_868, _)
                string_value_071 = string_value_071 .. "-- " .. param_868.text;
            end,
            ["break"] = function(_, _)
                string_value_071 = string_value_071 .. "break";
            end,
            continue = function(_, _)
                string_value_071 = string_value_071 .. "continue";
            end,
            ["unknown jump"] = function(param_869, _)
                local condition_value_164 = table_value_020[param_869];
                if condition_value_164 then
                    local condition_value_165 = condition_value_164[param_869.destination];
                    if condition_value_165 then
                        string_value_071 = string_value_071 .. ("-- %*: GOTO [%*] #%*"):format(cached_prefix_warning, condition_value_165.actual_code_index, condition_value_165.actual_index);
                        return;
                    else
                        string_value_071 = string_value_071 .. ("-- %*: GOTO UNK2"):format(cached_prefix_warning);
                        return;
                    end;
                else
                    string_value_071 = string_value_071 .. ("-- %*: GOTO UNK1"):format(cached_prefix_warning);
                    return;
                end;
            end,
            ["if"] = function(param_870, param_871)
                string_value_071 = string_value_071 .. "if ";
                helper_function_120(param_870.expr, param_871);
                local expression_value_090 = string.rep(string_value_072, #param_871 / #string_value_072 + 1);
                local expression_value_091 = nil;
                if condition_value_015.minify_if_statements and not param_870.else_ and #param_870.elseifs == 0 and #param_870.pass == 1 then
                    local statement_value_001 = param_870.pass[1];
                    local cached_t_005 = statement_value_001.t;
                    if cached_t_005 == "return" then
                        if #statement_value_001.values == 0 then
                            expression_value_091 = cached_t_005;
                        end;
                    elseif not (cached_t_005 ~= "continue") or cached_t_005 == "break" then
                        expression_value_091 = cached_t_005;
                    end;
                end;
                if expression_value_091 then
                    string_value_071 = string_value_071 .. " then " .. expression_value_091 .. " end";
                    return;
                else
                    string_value_071 = string_value_071 .. " then\n";
                    helper_function_121(param_870.pass, expression_value_090);
                    for _, item_131 in ipairs(param_870.elseifs) do
                        string_value_071 = string_value_071 .. param_871 .. "elseif ";
                        helper_function_120(item_131.expr, param_871);
                        string_value_071 = string_value_071 .. " then\n";
                        helper_function_121(item_131.code, expression_value_090);
                    end;
                    if param_870.else_ then
                        string_value_071 = string_value_071 .. param_871 .. "else\n";
                        helper_function_121(param_870.else_, expression_value_090);
                    end;
                    string_value_071 = string_value_071 .. param_871 .. "end";
                    return;
                end;
            end,
            ["for"] = function(param_872, param_873)
                local local_symbol_233 = false;
                local cached_for_info_003 = param_872.for_info;
                local cached_variables_002 = cached_for_info_003.variables;
                assert(cached_variables_002);
                if condition_value_015.mark_reads_and_writes then
                    helper_function_127(cached_variables_002, param_873);
                end;
                local local_symbol_234 = #cached_variables_002;
                string_value_071 = string_value_071 .. "for ";
                for condition_value_166, item_132 in ipairs(cached_variables_002) do
                    string_value_071 = string_value_071 .. item_132.name;
                    if condition_value_166 ~= local_symbol_234 then
                        string_value_071 = string_value_071 .. ", ";
                    end;
                end;
                local cached_type_012 = cached_for_info_003.type;
                if cached_type_012 == "numeric" then
                    string_value_071 = string_value_071 .. " = ";
                    local cached_args_015 = cached_for_info_003.args;
                    assert(cached_args_015.index_expr);
                    assert(cached_args_015.end_expr);
                    assert(cached_args_015.step_expr);
                    helper_function_120(cached_args_015.index_expr, param_873);
                    string_value_071 = string_value_071 .. ", ";
                    helper_function_120(cached_args_015.end_expr, param_873);
                    local cached_step_expr_002 = cached_args_015.step_expr;
                    while true do
                        if not (cached_step_expr_002.t == "name") then
                            break;
                        end;
                        local cached_override_expr_020 = cached_step_expr_002.name.override_expr;
                        if cached_override_expr_020 then
                            cached_step_expr_002 = cached_override_expr_020;
                        else
                            break;
                        end;
                    end;
                    local cached_step_expr = cached_step_expr_002;
                    assert(cached_step_expr);
                    if cached_step_expr.t == "constant" then
                        cached_step_expr_002 = cached_step_expr.const;
                        local_symbol_233 = not (not (cached_step_expr_002.type == 2) or cached_step_expr_002.value ~= 1);
                    end;
                    if not local_symbol_233 then
                        string_value_071 = string_value_071 .. ", ";
                        helper_function_120(cached_step_expr, param_873);
                    end;
                elseif cached_type_012 == "generic" then
                    string_value_071 = string_value_071 .. " in ";
                    local cached_args_016 = cached_for_info_003.args;
                    local cached_generator_expr_004 = cached_args_016.generator_expr;
                    assert(cached_generator_expr_004);
                    local expression_value_092 = nil;
                    local cached_state_expr_003 = cached_args_016.state_expr;
                    local cached_index_expr_002 = cached_args_016.index_expr;
                    local expression_value_093 = nil;
                    if not cached_index_expr_002 or cached_index_expr_002.t == "nil" then
                        expression_value_093 = if not cached_state_expr_003 or cached_state_expr_003.t == "nil" then not MULTI_RETURN_EXPRESSION_TYPES[cached_generator_expr_004.t] else not MULTI_RETURN_EXPRESSION_TYPES[cached_state_expr_003.t];
                    end;
                    expression_value_092 = if cached_index_expr_002 then if cached_state_expr_003 then if cached_state_expr_003.t == "nil" and cached_index_expr_002.t == "nil" then {
                        cached_generator_expr_004,
                        cached_state_expr_003
                    } else {
                        cached_generator_expr_004,
                        cached_state_expr_003,
                        cached_index_expr_002
                    } else {
                        cached_generator_expr_004,
                        conditional_not(),
                        cached_index_expr_002
                    } else if cached_state_expr_003 then {
                        cached_generator_expr_004,
                        cached_state_expr_003
                    } else {
                        cached_generator_expr_004
                    };
                    if expression_value_093 then
                        while true do
                            if not (#expression_value_092 > 1 and expression_value_092[#expression_value_092].t == "nil") then
                                break;
                            end;
                            table.remove(expression_value_092);
                        end;
                    end;
                    local number_value_010 = #expression_value_092;
                    for number_value_011, item_133 in ipairs(expression_value_092) do
                        if type(item_133) == "number" then
                            string_value_071 = string_value_071 .. "nil";
                        else
                            helper_function_120(item_133, param_873);
                        end;
                        if number_value_011 < number_value_010 then
                            string_value_071 = string_value_071 .. ", ";
                        end;
                    end;
                else
                    error((("Unknown for_type \"%*\""):format(cached_type_012)));
                end;
                local_symbol_233 = false;
                string_value_071 = string_value_071 .. " do\n";
                helper_function_121(param_872.code, helper_function_119(param_873));
                string_value_071 = string_value_071 .. param_873 .. "end";
            end,
            ["while"] = function(param_874, param_875)
                if param_874.expr then
                    string_value_071 = string_value_071 .. "while ";
                    helper_function_120(param_874.expr, param_875);
                    string_value_071 = string_value_071 .. " do\n";
                elseif condition_value_015.do_while_1 then
                    string_value_071 = string_value_071 .. "while 1 do\n";
                else
                    string_value_071 = string_value_071 .. "while true do\n";
                end;
                helper_function_121(param_874.code, helper_function_119(param_875));
                string_value_071 = string_value_071 .. param_875 .. "end";
            end,
            ["repeat"] = function(param_876, param_877)
                string_value_071 = string_value_071 .. "repeat\n";
                helper_function_121(param_876.code, helper_function_119(param_877));
                if param_876.expr then
                    string_value_071 = string_value_071 .. param_877 .. "until ";
                    helper_function_120(param_876.expr, param_877);
                    return;
                else
                    string_value_071 = string_value_071 .. param_877 .. "until nil";
                    return;
                end;
            end,
            ["do"] = function(param_878, param_879)
                string_value_071 = string_value_071 .. "do\n";
                helper_function_121(param_878.content, helper_function_119(param_879));
                string_value_071 = string_value_071 .. param_879 .. "end";
            end,
            call = function(param_880, param_881)
                local cached_func_001 = param_880.func;
                while cached_func_001.t == "name" do
                    local cached_override_expr_021 = cached_func_001.name.override_expr;
                    if cached_override_expr_021 then
                        cached_func_001 = cached_override_expr_021;
                    else
                        break;
                    end;
                end;
                local cached_func_002 = cached_func_001;
                if cached_func_002.t == "constant index" then
                    cached_func_001 = cached_func_002.table;
                    if cached_func_001.t == "constant" then
                        local cached_const_013 = cached_func_001.const;
                        if cached_const_013.type == 3 then
                            local function _(param_882)
                                return (string.gsub(param_882, "%%%%", "%%"));
                            end;
                            local cached_value_022 = cached_const_013.value;
                            local buffer_value_092 = buffer.fromstring(cached_value_022);
                            local table_value_172 = {};
                            local buffer_value_093 = 1;
                            local buffer_value_094 = false;
                            for index_059 = 0, #cached_value_022 - 1 do
                                local buffer_value_095 = buffer.readu8(buffer_value_092, index_059);
                                if buffer_value_095 == 37 then
                                    buffer_value_094 = not buffer_value_094;
                                else
                                    if buffer_value_095 == 42 and buffer_value_094 then
                                        local array_value_123 = string.sub(cached_value_022, buffer_value_093, index_059 - 1);
                                        table.insert(table_value_172, (string.gsub(array_value_123, "%%%%", "%%")));
                                        buffer_value_093 = index_059 + 2;
                                    end;
                                    buffer_value_094 = false;
                                end;
                            end;
                            local array_value_124 = string.sub(cached_value_022, buffer_value_093, #cached_value_022);
                            table.insert(table_value_172, (string.gsub(array_value_124, "%%%%", "%%")));
                            if #table_value_172 - 1 == #param_880.args then
                                string_value_071 = string_value_071 .. "`";
                                array_value_120 = array_value_120 + #string_value_071;
                                table.insert(table_value_170, string_value_071);
                                string_value_071 = "";
                                for array_value_125, item_134 in ipairs(table_value_172) do
                                    string_value_071 = string_value_071 .. register_usage_handlers_or_quote_string(condition_value_015.string_quotes_behavior, item_134, true);
                                    array_value_120 = array_value_120 + #string_value_071;
                                    table.insert(table_value_170, string_value_071);
                                    string_value_071 = "";
                                    if array_value_125 < #table_value_172 then
                                        string_value_071 = string_value_071 .. "{";
                                        helper_function_120(param_880.args[array_value_125], param_881);
                                        string_value_071 = string_value_071 .. "}";
                                        array_value_120 = array_value_120 + #string_value_071;
                                        table.insert(table_value_170, string_value_071);
                                        string_value_071 = "";
                                    end;
                                end;
                                string_value_071 = string_value_071 .. "`";
                                return;
                            end;
                        end;
                    end;
                end;
                cached_func_001 = helper_function_120;
                local cached_func_003 = cached_func_002;
                local cached_param_023 = param_881;
                local condition_value_167 = true;
                if cached_func_002.t ~= "concatenation" then
                    condition_value_167 = true;
                    if cached_func_002.t ~= "function" then
                        condition_value_167 = cached_func_002.t == "constant" and cached_func_002.const.type ~= 4 or (cached_func_002 and cached_func_002.precedence or -100) >= 0;
                    end;
                end;
                cached_func_001(cached_func_003, cached_param_023, condition_value_167);
                if param_880.namecall_method then
                    string_value_071 = string_value_071 .. ":" .. param_880.namecall_method .. "(";
                else
                    string_value_071 = string_value_071 .. "(";
                end;
                for condition_value_168, item_135 in ipairs(param_880.args) do
                    helper_function_120(item_135, param_881);
                    if condition_value_168 < #param_880.args then
                        string_value_071 = string_value_071 .. ", ";
                    end;
                end;
                string_value_071 = string_value_071 .. ")";
            end,
            ["define variable"] = function(param_883, param_884)
                if condition_value_015.mark_reads_and_writes then
                    helper_function_127(param_883.names, param_884);
                end;
                string_value_071 = string_value_071 .. "local ";
                for condition_value_169, item_136 in ipairs(param_883.names) do
                    string_value_071 = string_value_071 .. item_136.name;
                    if condition_value_169 < #param_883.names then
                        string_value_071 = string_value_071 .. ", ";
                    end;
                end;
                if (condition_value_015.show_nil_definitions or param_883.value.t ~= "nil") and not param_883.value.invisible then
                    string_value_071 = string_value_071 .. " = ";
                    helper_function_120(param_883.value, param_884);
                end;
            end,
            ["define function"] = function(param_885, param_886)
                local cached_func_004 = param_885.func;
                local cached_define_function_type = param_885.define_function_type;
                if condition_value_015.mark_reads_and_writes and cached_define_function_type == "local" then
                    helper_function_127({
                        cached_func_004.varname
                    }, param_886);
                end;
                if cached_define_function_type == "local" then
                    string_value_071 = string_value_071 .. "local function " .. param_885.func_name.name .. "(";
                elseif cached_define_function_type == "table" then
                    string_value_071 = string_value_071 .. "function ";
                    local cached_path = param_885.path;
                    for condition_value_170, item_137 in ipairs(cached_path) do
                        if condition_value_170 == #cached_path then
                            string_value_071 = string_value_071 .. item_137.name;
                        else
                            string_value_071 = string_value_071 .. item_137.name .. ".";
                        end;
                    end;
                    string_value_071 = string_value_071 .. "(";
                else
                    string_value_071 = string_value_071 .. "function " .. param_885.func_name.name .. "(";
                end;
                helper_function_123(cached_func_004, param_886);
                string_value_071 = string_value_071 .. ")";
                local cached_name_022 = param_885.func_name.name;
                local condition_value_171 = " -- ";
                local cached_line_defined_001 = cached_func_004.line_defined;
                if cached_line_defined_001 then
                    if cached_line_defined_001 == -1 then
                        string_value_071 = string_value_071 .. " -- Internal function, doesn't exist in bytecode";
                        condition_value_171 = ", ";
                    elseif condition_value_015.show_proto_line_defined then
                        string_value_071 = string_value_071 .. " -- Line " .. cached_line_defined_001;
                        condition_value_171 = ", ";
                    end;
                end;
                if cached_func_004.name_known and cached_func_004.name ~= cached_name_022 then
                    string_value_071 = string_value_071 .. condition_value_171 .. "Named \"" .. cached_func_004.name .. "\"";
                end;
                string_value_071 = string_value_071 .. "\n";
                helper_function_125(cached_func_004, param_886);
                string_value_071 = string_value_071 .. param_886 .. "end";
            end,
            ["set variable"] = function(param_887, param_888)
                string_value_071 = string_value_071 .. param_887.name.name;
                local condition_value_172 = COMPOUND_ASSIGNMENT_BY_KIND[param_887.value.t];
                local expression_value_094 = false;
                if condition_value_172 and condition_value_015.use_compound_assignment then
                    if param_887.value.t == "concatenation" then
                        if #param_887.value.exprs > 1 and param_887.value.exprs[1].t == "global" and param_887.value.exprs[1].name == param_887.name then
                            expression_value_094 = true;
                        end;
                    elseif param_887.value.lhs.t == "name" and param_887.name.name == param_887.value.lhs.name.name then
                        expression_value_094 = true;
                    end;
                end;
                if expression_value_094 then
                    string_value_071 = string_value_071 .. " " .. condition_value_172 .. " ";
                    helper_function_120(param_887.value.rhs, param_888);
                    return;
                else
                    string_value_071 = string_value_071 .. " = ";
                    helper_function_120(param_887.value, param_888);
                    return;
                end;
            end,
            ["set global"] = function(param_889, param_890)
                local _ = param_889.value;
                string_value_071 = string_value_071 .. param_889.name.value;
                local condition_value_173 = COMPOUND_ASSIGNMENT_BY_KIND[param_889.value.t];
                local expression_value_095 = false;
                if condition_value_173 and condition_value_015.use_compound_assignment then
                    if param_889.value.t == "concatenation" then
                        if #param_889.value.exprs > 1 and param_889.value.exprs[1].t == "global" and param_889.value.exprs[1].name == param_889.name then
                            expression_value_095 = true;
                        end;
                    elseif param_889.value.lhs.t == "constant" and param_889.name.value == param_889.value.lhs.const.value then
                        expression_value_095 = true;
                    end;
                end;
                if expression_value_095 then
                    string_value_071 = string_value_071 .. " " .. condition_value_173 .. " ";
                    if param_889.value.t == "concatenation" then
                        local array_value_126 = table.clone(param_889.value);
                        local array_value_127 = table.clone(array_value_126.exprs);
                        table.remove(array_value_127, 1);
                        array_value_126.exprs = array_value_127;
                        helper_function_120(array_value_126, param_890);
                    else
                        helper_function_120(param_889.value.rhs, param_890);
                    end;
                else
                    string_value_071 = string_value_071 .. " = ";
                    helper_function_120(param_889.value, param_890);
                end;
                if condition_value_015.mark_setglobal then
                    string_value_071 = string_value_071 .. " -- Setting global";
                end;
            end,
            ["set table"] = function(param_891, param_892)
                local cached_table_004 = param_891.table;
                while cached_table_004.t == "name" do
                    local cached_override_expr_022 = cached_table_004.name.override_expr;
                    if cached_override_expr_022 then
                        cached_table_004 = cached_override_expr_022;
                    else
                        break;
                    end;
                end;
                local cached_table_005 = cached_table_004;
                helper_function_120(cached_table_005, param_892, cached_table_005.t == "new table");
                if param_891.key.t == "constant" and param_891.key.const.type == 3 and is_valid_identifier(param_891.key.const.value) then
                    string_value_071 = string_value_071 .. "." .. param_891.key.const.value .. " ";
                else
                    string_value_071 = string_value_071 .. "[";
                    helper_function_120(param_891.key, param_892);
                    string_value_071 = string_value_071 .. "] ";
                end;
                cached_table_004 = COMPOUND_ASSIGNMENT_BY_KIND[param_891.value.t];
                local condition_value_174 = false;
                if cached_table_004 and condition_value_015.use_compound_assignment then
                    local expression_value_096 = nil;
                    if param_891.value.t == "concatenation" then
                        if cached_table_005.t == "name" and param_891.value.exprs[1].t == "get table" and param_891.value.exprs[1].table.t == "name" and cached_table_005.name == param_891.value.exprs[1].table.name then
                            expression_value_096 = param_891.value.exprs[1].index;
                        end;
                    elseif cached_table_005.t == "name" and param_891.value.lhs.t == "get table" and param_891.value.lhs.table.t == "name" and cached_table_005.name == param_891.value.lhs.table.name then
                        expression_value_096 = param_891.value.lhs.index;
                    end;
                    if expression_value_096 then
                        local cached_expression_value_003 = expression_value_096;
                        local cached_key_002 = param_891.key;
                        local cached_t_006 = cached_expression_value_003.t;
                        if cached_t_006 == cached_key_002.t and if cached_t_006 == "constant" then cached_expression_value_003.const.value == cached_key_002.const.value else not (cached_t_006 == "name") or cached_expression_value_003.name == cached_key_002.name then
                            condition_value_174 = true;
                        end;
                    end;
                end;
                if condition_value_174 then
                    string_value_071 = string_value_071 .. cached_table_004 .. " ";
                    if param_891.value.t == "concatenation" then
                        local array_value_128 = table.clone(param_891.value);
                        local array_value_129 = table.clone(array_value_128.exprs);
                        table.remove(array_value_129, 1);
                        array_value_128.exprs = array_value_129;
                        helper_function_120(array_value_128, param_892);
                        return;
                    else
                        helper_function_120(param_891.value.rhs, param_892);
                        return;
                    end;
                else
                    string_value_071 = string_value_071 .. "= ";
                    helper_function_120(param_891.value, param_892);
                    return;
                end;
            end,
            ["return"] = function(param_893, param_894)
                string_value_071 = string_value_071 .. "return";
                local cached_values_002 = param_893.values;
                local condition_value_175 = #cached_values_002;
                if condition_value_175 > 0 then
                    string_value_071 = string_value_071 .. " ";
                end;
                for index_060 = 1, condition_value_175 do
                    helper_function_120(cached_values_002[index_060], param_894);
                    if index_060 < condition_value_175 then
                        string_value_071 = string_value_071 .. ", ";
                    end;
                end;
            end
        };
        local table_value_173 = {
            global = function(param_895, param_896)
                if param_895.name.type == 3 then
                    string_value_071 = string_value_071 .. param_895.name.value;
                    return;
                elseif param_895.name.type == 4 then
                    helper_function_122(param_895.name, param_896);
                    return;
                else
                    error("Corrupted global");
                    return;
                end;
            end,
            name = function(param_897, param_898)
                local cached_name_023 = param_897.name;
                local cached_override_expr_023 = cached_name_023.override_expr;
                if cached_override_expr_023 then
                    helper_function_120(cached_override_expr_023, param_898);
                    return;
                else
                    string_value_071 = string_value_071 .. cached_name_023.name;
                    return;
                end;
            end,
            varargs = function(_, _)
                string_value_071 = string_value_071 .. "...";
            end,
            ["nil"] = function(_, _)
                string_value_071 = string_value_071 .. "nil";
            end,
            boolean = function(param_899, _)
                string_value_071 = string_value_071 .. (param_899.value and "true" or "false");
            end,
            ["new table"] = function(param_900, param_901)
                local cached_initializers_001 = param_900.initializers;
                local condition_value_176 = true;
                for _ in pairs(cached_initializers_001) do
                    condition_value_176 = false;
                    break;
                end;
                if condition_value_176 then
                    string_value_071 = string_value_071 .. "{}";
                else
                    string_value_071 = string_value_071 .. "{";
                    local local_symbol_235 = table.maxn(cached_initializers_001);
                    local local_symbol_236 = false;
                    if condition_value_015.always_use_table_keys then
                        local_symbol_236 = true;
                    else
                        for item_138 in pairs(cached_initializers_001) do
                            if type(item_138) ~= "number" then
                                local_symbol_236 = true;
                                break;
                            end;
                        end;
                    end;
                    local cached_local_symbol_027 = local_symbol_236;
                    local cached_param_024 = param_901;
                    if cached_local_symbol_027 then
                        param_901 = string.rep(string_value_072, #param_901 / #string_value_072 + 1);
                        string_value_071 = string_value_071 .. "\n" .. param_901;
                    end;
                    local cached_initializers_order = param_900.initializers_order;
                    local local_symbol_237 = #cached_initializers_order;
                    for condition_value_177, item_139 in ipairs(cached_initializers_order) do
                        local constant_value_136 = cached_initializers_001[item_139];
                        if type(item_139) == "table" then
                            if condition_value_015.table_string_key_shortening and item_139.t == "constant" and item_139.const.type == 3 and is_valid_identifier(item_139.const.value) then
                                string_value_071 = string_value_071 .. item_139.const.value .. " = ";
                            else
                                string_value_071 = string_value_071 .. "[";
                                helper_function_120(item_139, param_901);
                                string_value_071 = string_value_071 .. "] = ";
                            end;
                            helper_function_120(constant_value_136, param_901);
                            if condition_value_015.table_dict_key_semicolons then
                                string_value_071 = string_value_071 .. ";";
                            else
                                string_value_071 = string_value_071 .. ",";
                            end;
                            if condition_value_177 ~= local_symbol_237 then
                                string_value_071 = string_value_071 .. "\n" .. param_901;
                            end;
                        elseif condition_value_015.always_use_table_keys then
                            string_value_071 = string_value_071 .. "[" .. item_139 .. "] = ";
                            helper_function_120(constant_value_136, param_901);
                            if condition_value_015.table_dict_key_semicolons then
                                string_value_071 = string_value_071 .. ";";
                            else
                                string_value_071 = string_value_071 .. ",";
                            end;
                            if condition_value_177 ~= local_symbol_237 then
                                string_value_071 = string_value_071 .. "\n" .. param_901;
                            end;
                        end;
                        if #string_value_071 > 20 then
                            array_value_120 = array_value_120 + #string_value_071;
                            table.insert(table_value_170, string_value_071);
                            string_value_071 = "";
                        end;
                    end;
                    if not condition_value_015.always_use_table_keys then
                        if local_symbol_236 and local_symbol_235 > 0 then
                            string_value_071 = string_value_071 .. "\n" .. param_901;
                        end;
                        for index_061 = 1, local_symbol_235 do
                            if not (index_061 % 10 == 0) or cached_local_symbol_027 then

                            end;
                            helper_function_120(cached_initializers_001[index_061], param_901);
                            if index_061 < local_symbol_235 then
                                if condition_value_015.table_array_value_semicolons then
                                    string_value_071 = string_value_071 .. "; ";
                                else
                                    string_value_071 = string_value_071 .. ", ";
                                end;
                            end;
                            if #string_value_071 > 20 then
                                array_value_120 = array_value_120 + #string_value_071;
                                table.insert(table_value_170, string_value_071);
                                string_value_071 = "";
                            end;
                        end;
                    end;
                    param_901 = cached_param_024;
                    if cached_local_symbol_027 then
                        string_value_071 = string_value_071 .. "\n" .. param_901;
                    end;
                    string_value_071 = string_value_071 .. "}";
                end;
                if #string_value_071 > 20 then
                    array_value_120 = array_value_120 + #string_value_071;
                    table.insert(table_value_170, string_value_071);
                    string_value_071 = "";
                end;
            end,
            constant = function(param_902, param_903)
                helper_function_122(param_902.const, param_903);
            end,
            call = table_value_171.call,
            ["constant index"] = function(param_904, param_905)
                helper_function_120(param_904.table, param_905);
                if param_904.index.type == 3 and is_valid_identifier(param_904.index.value) then
                    if param_904.namecall then
                        string_value_071 = string_value_071 .. ":" .. param_904.index.value;
                        return;
                    else
                        string_value_071 = string_value_071 .. "." .. param_904.index.value;
                        return;
                    end;
                else
                    if param_904.namecall then
                        string_value_071 = string_value_071 .. "--[[Namecall requested, but namecall method is an invalid name]]";
                    end;
                    string_value_071 = string_value_071 .. "[";
                    helper_function_122(param_904.index, param_905);
                    string_value_071 = string_value_071 .. "]";
                    return;
                end;
            end,
            ["function"] = function(param_906, param_907)
                string_value_071 = string_value_071 .. "function(";
                helper_function_123(param_906, param_907);
                string_value_071 = string_value_071 .. ")";
                local condition_value_178 = " -- ";
                local cached_line_defined_002 = param_906.line_defined;
                if cached_line_defined_002 then
                    if cached_line_defined_002 == -1 then
                        string_value_071 = string_value_071 .. " -- Internal function, doesn't exist in bytecode";
                        condition_value_178 = ", ";
                    elseif condition_value_015.show_proto_line_defined then
                        string_value_071 = string_value_071 .. " -- Line " .. cached_line_defined_002;
                        condition_value_178 = ", ";
                    end;
                end;
                if param_906.name_known and param_906.name ~= nil then
                    string_value_071 = string_value_071 .. condition_value_178 .. "Named \"" .. param_906.name .. "\"";
                end;
                string_value_071 = string_value_071 .. "\n";
                array_value_120 = array_value_120 + #string_value_071;
                table.insert(table_value_170, string_value_071);
                string_value_071 = "";
                helper_function_125(param_906, param_907);
                string_value_071 = string_value_071 .. param_907 .. "end";
            end,
            ["and"] = function(param_908, param_909)
                local cached_helper_function_088 = helper_function_120;
                local cached_lhs_004 = param_908.lhs;
                local cached_param_025 = param_909;
                local cached_lhs_005 = param_908.lhs;
                cached_helper_function_088(cached_lhs_004, cached_param_025, (cached_lhs_005 and cached_lhs_005.precedence or -100) > (param_908 and param_908.precedence or -100));
                string_value_071 = string_value_071 .. " and ";
                cached_helper_function_088 = helper_function_120;
                cached_lhs_004 = param_908.rhs;
                cached_param_025 = param_909;
                cached_lhs_005 = param_908.rhs;
                cached_helper_function_088(cached_lhs_004, cached_param_025, (cached_lhs_005 and cached_lhs_005.precedence or -100) > (param_908 and param_908.precedence or -100));
            end,
            ["or"] = function(param_910, param_911)
                local cached_helper_function_089 = helper_function_120;
                local cached_lhs_006 = param_910.lhs;
                local cached_param_026 = param_911;
                local cached_lhs_007 = param_910.lhs;
                cached_helper_function_089(cached_lhs_006, cached_param_026, (cached_lhs_007 and cached_lhs_007.precedence or -100) > (param_910 and param_910.precedence or -100));
                string_value_071 = string_value_071 .. " or ";
                cached_helper_function_089 = helper_function_120;
                cached_lhs_006 = param_910.rhs;
                cached_param_026 = param_911;
                cached_lhs_007 = param_910.rhs;
                cached_helper_function_089(cached_lhs_006, cached_param_026, (cached_lhs_007 and cached_lhs_007.precedence or -100) > (param_910 and param_910.precedence or -100));
            end,
            condition = function(param_912, param_913)
                local cached_helper_function_090 = helper_function_120;
                local cached_lhs_008 = param_912.lhs;
                local cached_param_027 = param_913;
                local cached_lhs_009 = param_912.lhs;
                cached_helper_function_090(cached_lhs_008, cached_param_027, (cached_lhs_009 and cached_lhs_009.precedence or -100) > (param_912 and param_912.precedence or -100));
                string_value_071 = string_value_071 .. " " .. param_912.condition .. " ";
                cached_helper_function_090 = helper_function_120;
                cached_lhs_008 = param_912.rhs;
                cached_param_027 = param_913;
                cached_lhs_009 = param_912.rhs;
                cached_helper_function_090(cached_lhs_008, cached_param_027, (cached_lhs_009 and cached_lhs_009.precedence or -100) > (param_912 and param_912.precedence or -100));
            end,
            addition = function(param_914, param_915)
                local cached_helper_function_091 = helper_function_120;
                local cached_lhs_010 = param_914.lhs;
                local cached_param_028 = param_915;
                local local_symbol_238 = true;
                local cached_lhs_011 = param_914.lhs;
                if (cached_lhs_011 and cached_lhs_011.precedence or -100) <= (param_914 and param_914.precedence or -100) then
                    local_symbol_238 = true;
                    if param_914.rhs.t ~= "addition" then
                        local_symbol_238 = param_914.rhs.t == "subtraction";
                    end;
                end;
                cached_helper_function_091(cached_lhs_010, cached_param_028, local_symbol_238);
                string_value_071 = string_value_071 .. " + ";
                cached_helper_function_091 = helper_function_120;
                cached_lhs_010 = param_914.rhs;
                cached_param_028 = param_915;
                local_symbol_238 = true;
                cached_lhs_011 = param_914.rhs;
                if (cached_lhs_011 and cached_lhs_011.precedence or -100) <= (param_914 and param_914.precedence or -100) then
                    local_symbol_238 = true;
                    if param_914.rhs.t ~= "addition" then
                        local_symbol_238 = param_914.rhs.t == "subtraction";
                    end;
                end;
                cached_helper_function_091(cached_lhs_010, cached_param_028, local_symbol_238);
            end,
            subtraction = function(param_916, param_917)
                local cached_helper_function_092 = helper_function_120;
                local cached_lhs_012 = param_916.lhs;
                local cached_param_029 = param_917;
                local local_symbol_239 = true;
                local cached_lhs_013 = param_916.lhs;
                if (cached_lhs_013 and cached_lhs_013.precedence or -100) <= (param_916 and param_916.precedence or -100) then
                    local_symbol_239 = true;
                    if param_916.rhs.t ~= "addition" then
                        local_symbol_239 = param_916.rhs.t == "subtraction";
                    end;
                end;
                cached_helper_function_092(cached_lhs_012, cached_param_029, local_symbol_239);
                string_value_071 = string_value_071 .. " - ";
                cached_helper_function_092 = helper_function_120;
                cached_lhs_012 = param_916.rhs;
                cached_param_029 = param_917;
                local_symbol_239 = true;
                cached_lhs_013 = param_916.rhs;
                if (cached_lhs_013 and cached_lhs_013.precedence or -100) <= (param_916 and param_916.precedence or -100) then
                    local_symbol_239 = true;
                    if param_916.rhs.t ~= "addition" then
                        local_symbol_239 = param_916.rhs.t == "subtraction";
                    end;
                end;
                cached_helper_function_092(cached_lhs_012, cached_param_029, local_symbol_239);
            end,
            multiplication = function(param_918, param_919)
                local cached_helper_function_093 = helper_function_120;
                local cached_lhs_014 = param_918.lhs;
                local cached_param_030 = param_919;
                local local_symbol_240 = true;
                local cached_lhs_015 = param_918.lhs;
                if (cached_lhs_015 and cached_lhs_015.precedence or -100) <= (param_918 and param_918.precedence or -100) then
                    local_symbol_240 = true;
                    if param_918.rhs.t ~= "multiplication" then
                        local_symbol_240 = param_918.rhs.t == "division";
                    end;
                end;
                cached_helper_function_093(cached_lhs_014, cached_param_030, local_symbol_240);
                string_value_071 = string_value_071 .. " * ";
                cached_helper_function_093 = helper_function_120;
                cached_lhs_014 = param_918.rhs;
                cached_param_030 = param_919;
                local_symbol_240 = true;
                cached_lhs_015 = param_918.rhs;
                if (cached_lhs_015 and cached_lhs_015.precedence or -100) <= (param_918 and param_918.precedence or -100) then
                    local_symbol_240 = true;
                    if param_918.rhs.t ~= "multiplication" then
                        local_symbol_240 = param_918.rhs.t == "division";
                    end;
                end;
                cached_helper_function_093(cached_lhs_014, cached_param_030, local_symbol_240);
            end,
            division = function(param_920, param_921)
                local cached_helper_function_094 = helper_function_120;
                local cached_lhs_016 = param_920.lhs;
                local cached_param_031 = param_921;
                local local_symbol_241 = true;
                local cached_lhs_017 = param_920.lhs;
                if (cached_lhs_017 and cached_lhs_017.precedence or -100) <= (param_920 and param_920.precedence or -100) then
                    local_symbol_241 = true;
                    if param_920.rhs.t ~= "multiplication" then
                        local_symbol_241 = param_920.rhs.t == "division";
                    end;
                end;
                cached_helper_function_094(cached_lhs_016, cached_param_031, local_symbol_241);
                string_value_071 = string_value_071 .. " / ";
                cached_helper_function_094 = helper_function_120;
                cached_lhs_016 = param_920.rhs;
                cached_param_031 = param_921;
                local_symbol_241 = true;
                cached_lhs_017 = param_920.rhs;
                if (cached_lhs_017 and cached_lhs_017.precedence or -100) <= (param_920 and param_920.precedence or -100) then
                    local_symbol_241 = true;
                    if param_920.rhs.t ~= "multiplication" then
                        local_symbol_241 = param_920.rhs.t == "division";
                    end;
                end;
                cached_helper_function_094(cached_lhs_016, cached_param_031, local_symbol_241);
            end,
            ["floor division"] = function(param_922, param_923)
                local cached_helper_function_095 = helper_function_120;
                local cached_lhs_018 = param_922.lhs;
                local cached_param_032 = param_923;
                local cached_lhs_019 = param_922.lhs;
                cached_helper_function_095(cached_lhs_018, cached_param_032, (cached_lhs_019 and cached_lhs_019.precedence or -100) > (param_922 and param_922.precedence or -100));
                string_value_071 = string_value_071 .. " // ";
                cached_helper_function_095 = helper_function_120;
                cached_lhs_018 = param_922.rhs;
                cached_param_032 = param_923;
                cached_lhs_019 = param_922.rhs;
                cached_helper_function_095(cached_lhs_018, cached_param_032, (cached_lhs_019 and cached_lhs_019.precedence or -100) > (param_922 and param_922.precedence or -100));
            end,
            modulus = function(param_924, param_925)
                local cached_helper_function_096 = helper_function_120;
                local cached_lhs_020 = param_924.lhs;
                local cached_param_033 = param_925;
                local cached_lhs_021 = param_924.lhs;
                cached_helper_function_096(cached_lhs_020, cached_param_033, (cached_lhs_021 and cached_lhs_021.precedence or -100) > (param_924 and param_924.precedence or -100));
                string_value_071 = string_value_071 .. " % ";
                cached_helper_function_096 = helper_function_120;
                cached_lhs_020 = param_924.rhs;
                cached_param_033 = param_925;
                cached_lhs_021 = param_924.rhs;
                cached_helper_function_096(cached_lhs_020, cached_param_033, (cached_lhs_021 and cached_lhs_021.precedence or -100) > (param_924 and param_924.precedence or -100));
            end,
            negate = function(param_926, param_927)
                string_value_071 = string_value_071 .. "-";
                local cached_helper_function_097 = helper_function_120;
                local cached_rhs_009 = param_926.rhs;
                local cached_param_034 = param_927;
                local cached_rhs_010 = param_926.rhs;
                cached_helper_function_097(cached_rhs_009, cached_param_034, (cached_rhs_010 and cached_rhs_010.precedence or -100) >= (param_926 and param_926.precedence or -100));
            end,
            ["not"] = function(param_928, param_929)
                string_value_071 = string_value_071 .. "not ";
                local cached_helper_function_098 = helper_function_120;
                local cached_rhs_011 = param_928.rhs;
                local cached_param_035 = param_929;
                local cached_rhs_012 = param_928.rhs;
                cached_helper_function_098(cached_rhs_011, cached_param_035, (cached_rhs_012 and cached_rhs_012.precedence or -100) > (param_928 and param_928.precedence or -100));
            end,
            length = function(param_930, param_931)
                string_value_071 = string_value_071 .. "#";
                local cached_helper_function_099 = helper_function_120;
                local cached_rhs_013 = param_930.rhs;
                local cached_param_036 = param_931;
                local cached_rhs_014 = param_930.rhs;
                cached_helper_function_099(cached_rhs_013, cached_param_036, (cached_rhs_014 and cached_rhs_014.precedence or -100) >= (param_930 and param_930.precedence or -100));
            end,
            concatenation = function(param_932, param_933)
                for expression_value_097, item_140 in ipairs(param_932.exprs) do
                    if expression_value_097 > 1 then
                        string_value_071 = string_value_071 .. "..";
                    end;
                    helper_function_120(item_140, param_933, (param_932 and param_932.precedence or -100) < (item_140 and item_140.precedence or -100));
                end;
            end,
            exponentiation = function(param_934, param_935)
                local cached_helper_function_100 = helper_function_120;
                local cached_lhs_022 = param_934.lhs;
                local cached_param_037 = param_935;
                local cached_lhs_023 = param_934.lhs;
                cached_helper_function_100(cached_lhs_022, cached_param_037, (cached_lhs_023 and cached_lhs_023.precedence or -100) > (param_934 and param_934.precedence or -100));
                string_value_071 = string_value_071 .. " ^ ";
                cached_helper_function_100 = helper_function_120;
                cached_lhs_022 = param_934.rhs;
                cached_param_037 = param_935;
                cached_lhs_023 = param_934.rhs;
                cached_helper_function_100(cached_lhs_022, cached_param_037, (cached_lhs_023 and cached_lhs_023.precedence or -100) > (param_934 and param_934.precedence or -100));
            end,
            ["get table"] = function(param_936, param_937)
                local cached_table_006 = param_936.table;
                while cached_table_006.t == "name" do
                    local cached_override_expr_024 = cached_table_006.name.override_expr;
                    if cached_override_expr_024 then
                        cached_table_006 = cached_override_expr_024;
                    else
                        break;
                    end;
                end;
                local cached_table_007 = cached_table_006;
                cached_table_006 = helper_function_120;
                local cached_table = cached_table_007;
                local cached_param_038 = param_937;
                local condition_value_179 = true;
                if cached_table_007.t ~= "new table" then
                    condition_value_179 = (cached_table_007 and cached_table_007.precedence or -100) >= 0;
                end;
                cached_table_006(cached_table, cached_param_038, condition_value_179);
                if param_936.index.t == "constant" and param_936.index.const.type == 3 and is_valid_identifier(param_936.index.const.value) then
                    string_value_071 = string_value_071 .. "." .. param_936.index.const.value;
                    return;
                else
                    string_value_071 = string_value_071 .. "[";
                    helper_function_120(param_936.index, param_937);
                    string_value_071 = string_value_071 .. "]";
                    return;
                end;
            end
        };
        buffer_value_016 = condition_value_015.do_tonumber_nan;
        helper_function_122 = function(param_938, param_939)
            local cached_type_013 = param_938.type;
            if cached_type_013 == 0 then
                string_value_071 = string_value_071 .. "nil";
                return;
            elseif cached_type_013 == 1 then
                string_value_071 = string_value_071 .. (param_938.value and "true" or "false");
                return;
            elseif cached_type_013 == 3 then
                local cached_value_023 = param_938.value;
                local condition_value_180 = table_value_031[cached_value_023];
                if condition_value_180 then
                    string_value_071 = string_value_071 .. condition_value_180;
                    return;
                else
                    array_value_120 = array_value_120 + #string_value_071;
                    table.insert(table_value_170, string_value_071);
                    string_value_071 = "";
                    string_value_071 = string_value_071 .. register_usage_handlers_or_quote_string(condition_value_015.string_quotes_behavior, cached_value_023);
                    array_value_120 = array_value_120 + #string_value_071;
                    table.insert(table_value_170, string_value_071);
                    string_value_071 = "";
                    return;
                end;
            elseif cached_type_013 == 2 then
                string_value_071 = string_value_071 .. format_number_literal(param_938.value);
                return;
            elseif cached_type_013 == 7 then
                string_value_071 = string_value_071 .. "Vector3.new(" .. format_number_literal(param_938.value.X, true) .. ", " .. format_number_literal(param_938.value.Y, true) .. ", " .. format_number_literal(param_938.value.Z, true) .. ")";
                return;
            elseif cached_type_013 == 4 then
                helper_function_120(param_938.value, param_939);
                return;
            else
                error((("Unknown const type %*"):format(cached_type_013)));
                return;
            end;
        end;
        local string_value_073 = string.sub(string_value_072, 1, 1);
        helper_function_120 = function(param_940, param_941, param_942)
            local string_value_074 = table_value_173[param_940.t];
            if string_value_074 then
                if param_942 then
                    local local_symbol_242 = false;
                    if #table_value_170 > 1 then
                        local string_value_075 = true;
                        for index_062 = #string_value_071, 1, -1 do
                            if string.sub(string_value_071, index_062, index_062) ~= string_value_073 then
                                string_value_075 = false;
                                break;
                            end;
                        end;
                        if string_value_075 then
                            local string_value_076 = table_value_170[#table_value_170];
                            if string_value_076 then
                                for index_063 = #string_value_076, 1, -1 do
                                    local string_value_077 = string.sub(string_value_076, index_063, index_063);
                                    if string_value_077 ~= string_value_073 then
                                        if string_value_077 == "\n" then
                                            local_symbol_242 = true;
                                            break;
                                        else
                                            break;
                                        end;
                                    end;
                                end;
                            end;
                        end;
                    end;
                    if local_symbol_242 then
                        string_value_071 = string_value_071 .. ";(";
                    else
                        string_value_071 = string_value_071 .. "(";
                    end;
                end;
                local cached_status, cached_result = pcall(string_value_074, param_940, param_941);
                if not cached_status then
                    table_value_171.comment(is_point_in_range(": First try: " .. cached_result .. "\n"), param_941);
                end;
                if param_942 then
                    string_value_071 = string_value_071 .. ")";
                    return;
                end;
            else
                error((("Unknown AST expr type \"%*\""):format(param_940.t)));
            end;
        end;
        helper_function_121 = function(param_943, param_944)
            for _, item_141 in ipairs(param_943) do
                local condition_value_181 = table_value_171[item_141.t];
                if condition_value_181 then
                    if item_141.t ~= "nothing" then
                        string_value_071 = string_value_071 .. param_944;
                        condition_value_181(item_141, param_944);
                        string_value_071 = string_value_071 .. "\n";
                        array_value_120 = array_value_120 + #string_value_071;
                        table.insert(table_value_170, string_value_071);
                        string_value_071 = "";
                    end;
                else
                    error((("Unknown AST line type \"%*\""):format(item_141.t)));
                end;
            end;
        end;
        local array_value_130 = table.create(#local_symbol_193);
        for _, item_142 in ipairs(local_symbol_193) do
            if item_142.t ~= "nothing" then
                if not item_142.t then
                end;
                table.insert(array_value_130, item_142);
            end;
        end;
        helper_function_121(array_value_130, "");
        local array_value_131 = clock_ref() - local_symbol_008;
        local array_value_132 = 2;
        local function helper_function_128(param_945)
            local cached_array_value_003 = array_value_132;
            array_value_120 = array_value_120 + #param_945;
            table.insert(table_value_170, cached_array_value_003, param_945);
            array_value_132 = array_value_132 + 1;
        end;
        helper_function_128((("-- Time taken: %* seconds\n"):format((string.format("%.6f", array_value_131)))));
        if #table_value_019 > 0 then
            helper_function_128("\n");
            local table_value_174 = {};
            local table_value_175 = {};
            local table_value_176 = {};
            local table_value_177 = {};
            local table_value_178 = {};
            local table_value_179 = {};
            local cached_table_value_015 = table_value_177 ;
            local cached_table_value_016 = table_value_174 ;
            local cached_table_value_017 = table_value_178 ;
            local cached_table_value_018 = table_value_175 ;
            local cached_table_value_019 = table_value_179 ;
            local cached_table_value_020 = table_value_176 ;
            local function helper_function_129(param_946, param_947)
                if param_946 == "error" then
                    local condition_value_182 = cached_table_value_015[param_947];
                    if condition_value_182 then
                        condition_value_182.uses = condition_value_182.uses + 1;
                        return;
                    else
                        local table_value_180 = {
                            uses = 1,
                            content = param_947
                        };
                        cached_table_value_015[param_947] = table_value_180;
                        table.insert(cached_table_value_016, table_value_180);
                        return;
                    end;
                elseif param_946 == "warning" then
                    local condition_value_183 = cached_table_value_017[param_947];
                    if condition_value_183 then
                        condition_value_183.uses = condition_value_183.uses + 1;
                        return;
                    else
                        local table_value_181 = {
                            uses = 1,
                            content = param_947
                        };
                        cached_table_value_017[param_947] = table_value_181;
                        table.insert(cached_table_value_018, table_value_181);
                        return;
                    end;
                elseif param_946 == "info" then
                    local condition_value_184 = cached_table_value_019[param_947];
                    if condition_value_184 then
                        condition_value_184.uses = condition_value_184.uses + 1;
                        return;
                    else
                        local table_value_182 = {
                            uses = 1,
                            content = param_947
                        };
                        cached_table_value_019[param_947] = table_value_182;
                        table.insert(cached_table_value_020, table_value_182);
                        return;
                    end;
                else
                    helper_function_129("error", (("Unknown notice type \"%*\""):format(param_946)));
                    return;
                end;
            end;
            for _, item_143 in ipairs(table_value_019) do
                helper_function_129(item_143.type, item_143.content);
            end;
            local function helper_function_130(param_948, param_949, param_950)
                if #param_950 > 0 then
                    local array_value_133 = "-- " .. param_948 .. "[" .. #param_950 .. "]:\n";
                    local cached_array_value_004 = array_value_132;
                    array_value_120 = array_value_120 + #array_value_133;
                    table.insert(table_value_170, cached_array_value_004, array_value_133);
                    array_value_132 = array_value_132 + 1;
                    for array_value_134, item_144 in ipairs(param_950) do
                        local cached_uses = item_144.uses;
                        local cached_content = item_144.content;
                        if string.match(cached_content, "\n") then
                            if cached_uses == 1 then
                                local condition_value_185 = "--[[ " .. array_value_134 .. ". " .. param_949 .. ":\n" .. cached_content .. "\n]]\n";
                                local cached_array_value_005 = array_value_132;
                                array_value_120 = array_value_120 + #condition_value_185;
                                table.insert(table_value_170, cached_array_value_005, condition_value_185);
                                array_value_132 = array_value_132 + 1;
                            else
                                local local_symbol_243 = "--[[ " .. array_value_134 .. ". " .. param_949 .. " [x" .. cached_uses .. "]:n" .. cached_content .. "\n]]\n";
                                local cached_array_value_006 = array_value_132;
                                array_value_120 = array_value_120 + #local_symbol_243;
                                table.insert(table_value_170, cached_array_value_006, local_symbol_243);
                                array_value_132 = array_value_132 + 1;
                            end;
                        elseif cached_uses == 1 then
                            local condition_value_186 = "---- " .. array_value_134 .. ". " .. param_949 .. ": " .. cached_content .. "\n";
                            local cached_array_value_007 = array_value_132;
                            array_value_120 = array_value_120 + #condition_value_186;
                            table.insert(table_value_170, cached_array_value_007, condition_value_186);
                            array_value_132 = array_value_132 + 1;
                        else
                            local local_symbol_244 = "---- " .. array_value_134 .. ". " .. param_949 .. " [x" .. cached_uses .. "]: " .. cached_content .. "\n";
                            local cached_array_value_008 = array_value_132;
                            array_value_120 = array_value_120 + #local_symbol_244;
                            table.insert(table_value_170, cached_array_value_008, local_symbol_244);
                            array_value_132 = array_value_132 + 1;
                        end;
                    end;
                end;
            end;
            helper_function_130("Global Errors", cached_prefix_error, table_value_174);
            helper_function_130("Global Warnings", cached_prefix_warning, table_value_175);
            helper_function_130("Global Information", cached_prefix_information, table_value_176);
        end;
        helper_function_128("\n");
        for _, item_145 in ipairs(table_value_032) do
            if condition_value_015.mark_reads_and_writes then
                helper_function_128("-- " .. helper_function_126("Variable", table_value_033[item_145], 1, true) .. "\n");
            end;
            helper_function_128("local " .. table_value_031[item_145] .. " = ");
            helper_function_128(register_usage_handlers_or_quote_string(condition_value_015.string_quotes_behavior, item_145));
            helper_function_128("\n");
        end;
        local_symbol_009:end_benchmark("Global AST To String");
        local_symbol_009:start_benchmark("Global String Writing");
        local buffer_value_096 = buffer.create(array_value_120);
        local buffer_value_097 = 0;
        for _, item_146 in ipairs(table_value_170) do
            buffer.copy(buffer_value_096, buffer_value_097, buffer.fromstring(item_146));
            buffer_value_097 = buffer_value_097 + #item_146;
        end;
        while buffer.readu8(buffer_value_096, buffer.len(buffer_value_096) - 1) == 10 do
            local buffer_value_098 = buffer.len(buffer_value_096) - 1;
            local buffer_value_099 = buffer.create(buffer_value_098);
            buffer.copy(buffer_value_099, 0, buffer_value_096, 0, buffer_value_098);
            buffer_value_096 = buffer_value_099;
        end;
        local buffer_value_100 = buffer.tostring(buffer_value_096);
        local_symbol_009:end_benchmark("Global String Writing");
        local_symbol_009:print_all_times();
        return buffer_value_100;
    end;
end;
local function _(param_951, param_952)
    local function helper_function_131(param_953)
        if type(param_953) == "string" then
            return param_951(param_953);
        else
            assert(getscriptbytecode_ref, "getscriptbytecode was undefined");
            return param_951(getscriptbytecode_ref(param_953));
        end;
    end;
    if param_952 then
        return function(...)
            local string_value_078, string_value_079 = xpcall(helper_function_131, function(param_954)
                return tostring(param_954) .. "\n" .. debug.traceback(nil, 2);
            end, ...);
            if string_value_078 then
                return string_value_079;
            else
                return previous_error_prefix .. ": After: " .. string_value_079;
            end;
        end;
    else
        return helper_function_131;
    end;
end;
local function decompile_input(decompile_target, decompile_options)
    if type(decompile_target) == "string" then
        return decompile_bytecode(decompile_target, decompile_options);
    else
        assert(getscriptbytecode_ref, "getscriptbytecode was undefined");
        return decompile_bytecode(getscriptbytecode_ref(decompile_target), decompile_options);
    end;
end;
local cached_decompile_input = decompile_input ;
local function protected_decompile_input(...)
    local string_value_080, string_value_081 = xpcall(cached_decompile_input, function(run_with_decompiler_lock)
        return tostring(run_with_decompiler_lock) .. "\n" .. debug.traceback(nil, 2);
    end, ...);
    if string_value_080 then
        return string_value_081;
    else
        return previous_error_prefix .. ": After: " .. string_value_081;
    end;
end;
local decompiler_is_running = false;
local function run_with_decompiler_lock(param_955)
    while decompiler_is_running do
        if task_wait_ref and running_inside_game then
            task_wait_ref();
        else
            error("Decompiler is already running");
        end;
    end;
    decompiler_is_running = true;
    local diagnostic_value_003 = active_opcode_encoding;
    local diagnostic_value_004 = failed_instruction_count;
    local diagnostic_value_005 = previous_error_prefix;
    local diagnostic_value_006 = previous_warning_prefix;
    local string_value_082 = previous_information_prefix;
    local string_value_083, string_value_084 = xpcall(param_955, function(param_956)
        return tostring(param_956) .. "\n" .. debug.traceback(nil, 2);
    end);
    local string_value_085 = nil;
    if string_value_083 then
        string_value_085 = string_value_084;
    else
        string_value_085 = previous_error_prefix .. ": After: " .. string_value_084;
    end;
    active_opcode_encoding = diagnostic_value_003;
    failed_instruction_count = diagnostic_value_004;
    previous_error_prefix = diagnostic_value_005;
    previous_warning_prefix = diagnostic_value_006;
    previous_information_prefix = string_value_082;
    decompiler_is_running = false;
    return string_value_085;
end;
local function v_strict_types_from_options(v_options)
    if type(v_options) == "table" then
        if v_options.strict ~= nil then
            return v_options.strict == true;
        elseif v_options.strict_types ~= nil then
            return v_options.strict_types == true;
        elseif v_options.strictTypes ~= nil then
            return v_options.strictTypes == true;
        end;
    elseif v_options ~= nil then
        return v_options == true;
    end;
    return true;
end;
local function v_option_bool(v_options, v_name, v_default)
    if type(v_options) == "table" and v_options[v_name] ~= nil then
        return v_options[v_name] == true;
    end;
    return v_default;
end;
local function v_with_strict_types(v_options, v_callback)
    local v_previous_strict_types = strict_type_info_enabled;
    local v_previous_allow_new_type_info_fallback = allow_new_type_info_fallback;
    local v_previous_ignore_unsupported_debug_info = ignore_unsupported_debug_info;
    strict_type_info_enabled = v_strict_types_from_options(v_options);
    allow_new_type_info_fallback = v_option_bool(v_options, "allow_new_type_info_fallback", v_option_bool(v_options, "allow_unknown_type_info_fallback", false));
    ignore_unsupported_debug_info = v_option_bool(v_options, "ignore_unsupported_debug_info", true);
    local v_ok, v_result = xpcall(v_callback, function(v_error)
        return v_error;
    end);
    strict_type_info_enabled = v_previous_strict_types;
    allow_new_type_info_fallback = v_previous_allow_new_type_info_fallback;
    ignore_unsupported_debug_info = v_previous_ignore_unsupported_debug_info;
    if v_ok then
        return v_result;
    else
        error(v_result);
    end;
end;
local function v_count_plain(v_text, v_pattern)
    local v_count = 0;
    local v_position = 1;
    while true do
        local v_start, v_finish = string.find(v_text, v_pattern, v_position, true);
        if not v_start then
            break;
        end;
        v_count = v_count + 1;
        v_position = v_finish + 1;
    end;
    return v_count;
end;
local function v_decompile_quality_score(v_output, v_failed_instruction_count)
    local v_score = 0;
    v_score = v_score + (v_failed_instruction_count or 0) * 1000;
    v_score = v_score + v_count_plain(v_output, "Unknown opcode") * 1000;
    v_score = v_score + v_count_plain(v_output, "Corrupted aux") * 500;
    v_score = v_score + v_count_plain(v_output, "Corrupted bytecode") * 500;
    v_score = v_score + v_count_plain(v_output, "Unknown constant") * 500;
    v_score = v_score + v_count_plain(v_output, "Failed to evaluate expression, replaced with nil") * 50;
    v_score = v_score + v_count_plain(v_output, "Expression was reused") * 50;
    v_score = v_score + v_count_plain(v_output, previous_error_prefix .. ": After:") * 10000;
    local v_quality_load = loadstring or load;
    if v_quality_load and not string.find(v_output, previous_error_prefix .. ": After:", 1, true) then
        local v_quality_ok, v_quality_chunk = pcall(v_quality_load, v_output);
        if not v_quality_ok or not v_quality_chunk then
            v_score = v_score + 10000;
        end;
    end;
    return v_score;
end;
local function v_add_decompiler_summary(v_output, v_options, v_encoding, v_score, v_failed_instruction_count)
    if type(v_options) == "table" and v_options.show_decompiler_summary == false then
        return v_output;
    end;
    local v_unknown = v_count_plain(v_output, "Unknown opcode") + (v_failed_instruction_count or 0);
    local v_corrupted_aux = v_count_plain(v_output, "Corrupted aux");
    local v_nil_fallbacks = v_count_plain(v_output, "Failed to evaluate expression, replaced with nil");
    local v_reused = v_count_plain(v_output, "Expression was reused");
    local v_header = "-- Decompiler diagnostics: encoding=" .. tostring(v_encoding) .. ", score=" .. tostring(v_score) .. ", unknown_opcodes=" .. tostring(v_unknown) .. ", corrupted_aux=" .. tostring(v_corrupted_aux) .. ", nil_fallbacks=" .. tostring(v_nil_fallbacks) .. ", reused_expressions=" .. tostring(v_reused) .. "\n";
    if v_nil_fallbacks > 0 or v_reused > 0 or v_unknown > 0 or v_corrupted_aux > 0 then
        v_header = v_header .. "-- Warning: this output may be semantically incomplete. Review diagnostics before using it.\n";
    end;
    return v_header .. v_output;
end;
decompile_input = function(protected_decompile_target, protected_decompile_options)
    return run_with_decompiler_lock(function()
        return v_with_strict_types(protected_decompile_options, function()
            active_opcode_encoding = "vanilla";
            local vanilla_decompile_result = protected_decompile_input(protected_decompile_target, protected_decompile_options);
            local cached_failed_instruction_count = failed_instruction_count;
            local local_symbol_245 = v_decompile_quality_score(vanilla_decompile_result, cached_failed_instruction_count);
            active_opcode_encoding = "mul227";
            local mul_encoded_decompile_result = protected_decompile_input(protected_decompile_target, protected_decompile_options);
            local cached_failed_instruction_count_001 = failed_instruction_count;
            local condition_value_187 = v_decompile_quality_score(mul_encoded_decompile_result, cached_failed_instruction_count_001);
            if condition_value_187 < local_symbol_245 then
                return v_add_decompiler_summary(mul_encoded_decompile_result, protected_decompile_options, "mul227", condition_value_187, cached_failed_instruction_count_001);
            elseif local_symbol_245 < condition_value_187 then
                return v_add_decompiler_summary(vanilla_decompile_result, protected_decompile_options, "vanilla", local_symbol_245, cached_failed_instruction_count);
            elseif #mul_encoded_decompile_result < #vanilla_decompile_result then
                return v_add_decompiler_summary(mul_encoded_decompile_result, protected_decompile_options, "mul227", condition_value_187, cached_failed_instruction_count_001);
            else
                return v_add_decompiler_summary(vanilla_decompile_result, protected_decompile_options, "vanilla", local_symbol_245, cached_failed_instruction_count);
            end;
        end);
    end);
end;
local function disassemble_input(disassemble_target)
    if type(disassemble_target) == "string" then
        return disassemble_bytecode(disassemble_target);
    else
        assert(getscriptbytecode_ref, "getscriptbytecode was undefined");
        return disassemble_bytecode(getscriptbytecode_ref(disassemble_target));
    end;
end;
local function protected_disassemble_input(...)
    local string_value_086, string_value_087 = xpcall(disassemble_input, function(param_957)
        return tostring(param_957) .. "\n" .. debug.traceback(nil, 2);
    end, ...);
    if string_value_086 then
        return string_value_087;
    else
        return previous_error_prefix .. ": After: " .. string_value_087;
    end;
end;
return {
    decompile = decompile_input,
    disassemble = function(param_958, param_959)
        return run_with_decompiler_lock(function()
            return v_with_strict_types(param_959, function()
                active_opcode_encoding = "vanilla";
                local local_symbol_246 = protected_disassemble_input(param_958, param_959);
                local cached_failed_instruction_count_002 = failed_instruction_count;
                local local_symbol_247 = v_decompile_quality_score(local_symbol_246, cached_failed_instruction_count_002);
                active_opcode_encoding = "mul227";
                local local_symbol_248 = protected_disassemble_input(param_958, param_959);
                local cached_failed_instruction_count_003 = failed_instruction_count;
                local condition_value_188 = v_decompile_quality_score(local_symbol_248, cached_failed_instruction_count_003);
                if condition_value_188 < local_symbol_247 then
                    return local_symbol_248;
                elseif local_symbol_247 < condition_value_188 then
                    return local_symbol_246;
                elseif #local_symbol_248 >= #local_symbol_246 then
                    return local_symbol_248;
                else
                    return local_symbol_246;
                end;
            end);
        end);
    end
};
