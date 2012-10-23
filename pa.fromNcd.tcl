
# PlanAhead Launch Script for Post PAR Floorplanning, created by Project Navigator

create_project -name ledplay -dir "Z:/Documents/Source/github/ledplay/planAhead_run_1" -part xc3s500evq100-4
set srcset [get_property srcset [current_run -impl]]
set_property design_mode GateLvl $srcset
set_property edif_top_file "Z:/Documents/Source/github/ledplay/ledplay.ngc" [ get_property srcset [ current_run ] ]
add_files -norecurse { {Z:/Documents/Source/github/ledplay} }
set_property target_constrs_file "pins.ucf" [current_fileset -constrset]
add_files [list {pins.ucf}] -fileset [get_property constrset [current_run]]
link_design
read_xdl -file "Z:/Documents/Source/github/ledplay/ledplay.ncd"
if {[catch {read_twx -name results_1 -file "Z:/Documents/Source/github/ledplay/ledplay.twx"} eInfo]} {
   puts "WARNING: there was a problem importing \"Z:/Documents/Source/github/ledplay/ledplay.twx\": $eInfo"
}
