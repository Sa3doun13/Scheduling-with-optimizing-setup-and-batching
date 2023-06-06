%wip(index, product, current_step, priority, wafers, release_time, due_time).
wip(1,3,1,10,25,0,1638400).
wip(2,3,1,10,25,0,1638400).
wip(3,3,1,10,25,0,1638400).
wip(4,3,1,10,25,0,1638400).

wip(1,4,1,10,25,0,1638400).
wip(2,4,1,10,25,0,1638400).
wip(3,4,1,10,25,0,1638400).

%product(product_name, step_name, area_name, toolgrp_name, pro_time, pro_unit, cascading_interval, min_batch, max_batch, setup_time, setup_name).
product(3, 1, diffusion, diffusion_fe_120, 50, batch, 0, 75, 100, 0, 0).
product(3, 2,  litho, lithotrack_fe_95, 6, wafer, 0, 0, 0, 0, su450_3).
product(3, 3,  implant, implant_128, 8,  wafer, 0, 0, 0, 0, su128_1).
product(3, 4,  litho, lithotrack_fe_95, 14, wafer, 0, 0, 0, 0, su485_3).
product(3, 5,  implant, implant_128, 12, wafer, 0, 0, 0, 0, su128_2).
product(3, 6,  litho, lithotrack_fe_95, 10, wafer, 0, 0, 0, 0, 0).
product(3, 7,  implant, implant_128, 5,  wafer, 0, 0, 0, 0, su128_1).
product(3, 8,  implant, implant_128, 11, wafer, 0, 0, 0, 0, su128_2).
product(3, 9,  diffusion, diffusion_fe_120, 50, batch, 0, 75, 100, 0, 0).
product(3, 10, litho, lithotrack_fe_95, 8,  wafer, 0, 0, 0, 0, su450_3).


product(4, 1, diffusion, diffusion_fe_120, 50, batch, 0, 75, 100, 0, 0).
product(4, 2,  implant, implant_128, 8,  wafer, 0, 0, 0, 0, su128_2).
product(4, 3,  implant, implant_128, 12,  wafer, 0, 0, 0, 0, 0).
product(4, 4,  litho, lithotrack_fe_95, 7,  wafer, 0, 0, 0, 0, su485_3).
product(4, 5,  litho, lithotrack_fe_95, 9, wafer, 0, 0, 0, 0, 0).
product(4, 6,  implant, implant_128, 6, wafer, 0, 0, 0, 0, 0).
product(4, 7,  litho, lithotrack_fe_95, 5,  wafer, 0, 0, 0, 0, su450_3).
product(4, 8,  implant, implant_128, 11, wafer, 0, 0, 0, 0, su128_1).
product(4, 9,  diffusion, diffusion_fe_120, 50, batch, 0, 75, 100, 0, 0).
product(4, 10, litho, lithotrack_fe_95, 8,  wafer, 0, 0, 0, 0, 0).

%tool(area_name, tool_grp_name, machine_number, cascading_tool, batching_tool, batch_unit, load_time, unload_time).
tool(implant, implant_128, 1, 1, 60, 60).
tool(implant, implant_128, 2, 1, 60, 60).
tool(implant, implant_128, 3, 1, 60, 60).

tool(litho, lithotrack_fe_95, 1, 0, 60, 60).
tool(litho, lithotrack_fe_95, 2, 0, 60, 60).
tool(litho, lithotrack_fe_95, 3, 0, 60, 60).

tool(diffusion, diffusion_fe_120, 1, 0, 60, 60).
tool(diffusion, diffusion_fe_120, 2, 0, 60, 60).
tool(diffusion, diffusion_fe_120, 3, 0, 60, 60).

%pm(pm_event_name, group_name, pm_type, max, pm_duration, min).
pm(implant_128_mn, implant_128, counter_based, 100, 30, 75).
pm(implant_128_qt, implant_128, counter_based, 150, 42, 125).
pm(lithotrack_fe_95_wk, lithotrack_fe_95, time_based, 120, 35, 100).
pm(lithotrack_fe_95_mn, lithotrack_fe_95, time_based, 150, 45, 125).

pm(diffusion_fe_120_mn, diffusion_fe_120, time_based, 125, 35, 100).
pm(diffusion_fe_120_qt, diffusion_fe_120, time_based, 150, 45, 125).

setup_change(implant_128,su128_1,50,4).
setup_change(implant_128,su128_2,50,4).

setup_change(lithotrack_fe_95,su450_3,30,0).
setup_change(lithotrack_fe_95,su485_3,30,0).
