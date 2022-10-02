local objs = _G.EXEC_ARGS[1]
if typeof(objs) ~= 'table' then objs = _G.EXEC_ARGS end
for i, o in next, objs do if typeof(o) == 'Instance' then o:destroy() end end
