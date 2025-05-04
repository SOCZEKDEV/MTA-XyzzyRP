--[[
Obsluga baz danych, interfejs do bazy MySQL realizowany za pomoca natywnego systemu dbConnect

@author Lukasz Biegaj <wielebny@bestplay.pl>
@copyright 2011-2013 Lukasz Biegaj <wielebny@bestplay.pl>
@license Dual GPLv2/MIT
]]--

local SQL_LOGIN = "z"
local SQL_PASSWD = "x"
local SQL_DB = "y"
local SQL_HOST = "tiger.og-servers.net"
local SQL_PORT = 3306

local SQL

local function connect()
    SQL = dbConnect("mysql", string.format("dbname=%s;host=%s;port=%d", SQL_DB, SQL_HOST, SQL_PORT), SQL_LOGIN, SQL_PASSWD, "share=1")
end

local function keepAlive()
    if not SQL then
        connect()
    end
end

addEventHandler("onResourceStart", resourceRoot, function()
    connect()
    setTimer(keepAlive, 30000, 0)
end)

function queryFetchAll(query, ...)
    local qh = dbQuery(SQL, query, ...)
    local result = dbPoll(qh, -1)
    return result
end

function queryFetchOne(query, ...)
    local qh = dbQuery(SQL, query, ...)
    local result = dbPoll(qh, -1)
    return result and result[1] or nil
end

function executeQuery(query, ...)
    dbExec(SQL, query, ...)
end

function insertID()
    local qh = dbQuery(SQL, "SELECT LAST_INSERT_ID() AS id")
    local result = dbPoll(qh, -1)
    return result and result[1] and tonumber(result[1].id) or nil
end

function affectedRows()
    local qh = dbQuery(SQL, "SELECT ROW_COUNT() AS count")
    local result = dbPoll(qh, -1)
    return result and result[1] and tonumber(result[1].count) or nil
end

function getSQLLink()
    return SQL
end
