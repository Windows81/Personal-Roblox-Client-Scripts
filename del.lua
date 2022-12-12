local objs = _E and _E.ARGS[1] or {}
if typeof(objs) ~= 'table' then objs = _E.ARGS end
for i, o in next, objs do if typeof(o) == 'Instance' then o:destroy() end end
