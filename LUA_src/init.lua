-- Wait for 2 secs and than run "main.lua" to avoid any Kernel panic
tmr.alarm(0, 5000, 0, function()
	print("Heap : "..node.heap())
	dofile("main.lc") 
end )
