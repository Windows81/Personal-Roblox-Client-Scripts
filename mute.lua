exec(
	'force-obj-prop', 'Volume',
		function(o) return o:isA 'Sound' and o.Parent.Name ~= 'HumanoidRootPart' end,
		false)
