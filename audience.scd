(
// Run this block to setup the enviroment;
var dir = thisProcess.nowExecutingPath.dirname;
~audienceMode = true;
(dir +/+ "study_of_collaborative_algorithm.scd").load;
(dir +/+ "performance_window.scd").load;

~updateOSCDefs.value([(
	// sine sound
	name: \sine,
), (
	// noise sound
	name: \noise,
),  (
	// Build up queue
	name: \buildUp,
)
])
)