-- Wait for 2 secs and than run "main.lua" to avoid any Kernel panic
tmr.alarm(0, 5000, 0, function()
	print("Heap memory available before compile : "..node.heap())
	node.compile("main.lua")
	print("Heap memory available after compile : "..node.heap())
	dofile("main.lc") 
end )
