

local ngx_log         = ngx.log
local cc              = cc
local debug_traceback = debug.traceback
local error           = error
local string_format   = string.format
local string_rep      = string.rep
local tostring        = tostring



--------------------------------------------------------------------------------
-- throw fucntion error location
-- eg: cc.throw("xxxxx") or cc.throw("this is test:[%d]", 3)
function cc.throw(fmt, ...)
    local msg
    if #{...} == 0 then
        msg = fmt
    else
        msg = string_format(fmt, ...)
    end
    error(msg, 2)
end



--------------------------------------------------------------------------------
-- log tag:ngx.NOTICE, ngx.ERR
-- eg: cc.printinfo("test") or cc.printerror("[%d]")
function cc.printinfo(fmt, ...)
    assert('function'~=type(fmt), "format is function")
    local content
    if 'boolean' == type(fmt) then
        content = tostring(fmt)
    elseif 'number' == type(fmt) then
        content = tostring(fmt)
    elseif 'string' == type(fmt) then
        content = string_format(fmt, ...)
    end

    local function _t(s)
        local a = string.trim(s)
        local b = string.split(a, '\n')[3]
        local c = string.trim(b)
        return string.split(c, ' ')[1]
    end
    local location = _t(debug_traceback())

    ngx_log(ngx["NOTICE"], string_format("- \"%s\" = {\n-    %s\n}\n", location, content))
end

function cc.printerror(fmt, ...)
    local content = string_format(fmt, ...)
    local function _t(s)
        local a = string.trim(s)
        local b = string.split(a, '\n')[3]
        local c = string.trim(b)
        return string.split(c, ' ')[1]
    end
    local location = _t(debug_traceback())

    ngx_log(ngx["ERR"], string_format("- \"%s\" = {\n-    %s\n}\n", location, content))
end


--------------------------------------------------------------------------------
-- dump table data to log
-- exmaple: cc.dump(table)
function cc.dump(value, desciption, nesting)
    if type(nesting) ~= "number" then nesting = 3 end

    local lookupTable = {}
    local result      = {}

    local function _v(v)
        if type(v) == "string" then
            v = "\"" .. v .. "\""
        end
        return tostring(v)
    end

    local function _t(s)
        local a = string.trim(s)
        local b = string.split(a, '\n')[3]
        local c = string.trim(b)
        return string.split(c, ' ')[1]
    end
    if nil == desciption then
        desciption = _t(debug_traceback())
    end


    local function _dump(value, desciption, indent, nest, keylen)
        desciption = desciption or "<var>"
        local spc = ""
        if type(keylen) == "number" then
            spc = string_rep(" ", keylen - string.len(_v(desciption)))
        end
        if type(value) ~= "table" then
            result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
        elseif lookupTable[value] then
            result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
        else
            lookupTable[value] = true
            if nest > nesting then
                result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
            else
                result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
                local indent2 = indent.."    "
                local keys = {}
                local keylen = 0
                local values = {}
                for k, v in pairs(value) do
                    keys[#keys + 1] = k
                    local vk = _v(k)
                    local vkl = string.len(vk)
                    if vkl > keylen then keylen = vkl end
                    values[k] = v
                end
                table.sort(keys, function(a, b)
                    if type(a) == "number" and type(b) == "number" then
                        return a < b
                    else
                        return tostring(a) < tostring(b)
                    end
                end)
                for i, k in ipairs(keys) do
                    _dump(values[k], k, indent2, nest + 1, keylen)
                end
                result[#result +1] = string.format("%s}", indent)
            end
        end
    end
    _dump(value, desciption, "- ", 1)

    local str = ''
    table.foreach(result, function(_, v)
        str = str .. v .. '\n'
    end)
    ngx.log(ngx.NOTICE, str)
end
