local objs = _G.EXEC_ARGS[1]
if typeof(objs) ~= 'table' then objs = _G.EXEC_ARGS end
for i, g in next, objs do g:destroy() end
